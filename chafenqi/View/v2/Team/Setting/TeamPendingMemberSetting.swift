//
//  TeamPendingMemberSetting.swift
//  chafenqi
//
//  Created by Louis Wu on 2024/12/31.
//

import Foundation
import SwiftUI
import Inject
import AlertToast

struct TeamPendingMemberSettingView: View {
    @ObserveInjection var inject
    
    @ObservedObject var team: CFQTeam
    @ObservedObject var user: CFQNUser
    @ObservedObject var alertToastModel = AlertToastModel.shared
    
    @State private var selectedPendingMember: TeamPendingMember? = nil
    @State private var showAcceptConfirmAlert: Bool = false
    @State private var showRejectConfirmAlert: Bool = false
    
    var body: some View {
        VStack {
            if team.current.pendingMembers.isEmpty {
                Text("暂未收到加入申请")
                    .padding(.bottom, 5)
                Button {
                    team.refresh(user: user)
                } label: {
                    Label("刷新", systemImage: "arrow.clockwise")
                }
            } else {
                List {
                    ForEach(team.current.pendingMembers.sorted { $0.timestamp > $1.timestamp }, id: \.userId) { pendingMember in
                        TeamPendingMemberSettingEntryView(pendingMember: pendingMember)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button {
                                    selectedPendingMember = pendingMember
                                    showRejectConfirmAlert.toggle()
                                } label: {
                                    Text("拒绝")
                                }
                                .tint(Color.red)
                                
                                Button {
                                    selectedPendingMember = pendingMember
                                    showAcceptConfirmAlert.toggle()
                                } label: {
                                    Text("允许")
                                }
                                .tint(Color.blue)
                            }
                    }
                }
            }
        }
        .enableInjection()
        .alert("拒绝申请", isPresented: $showRejectConfirmAlert) {
            Button("取消", role: .cancel) { selectedPendingMember = nil }
            Button("确认", role: .destructive) {
                guard let member = selectedPendingMember else { return }
                onRejectPendingMember(pendingMember: member)
            }
        } message: {
            Text("确认要拒绝该申请吗？")
        }
        .alert("接受申请", isPresented: $showAcceptConfirmAlert) {
            Button("取消", role: .cancel) { selectedPendingMember = nil }
            Button("确认", role: .destructive) {
                guard let member = selectedPendingMember else { return }
                onAcceptPendingMember(pendingMember: member)
            }
        } message: {
            Text("确认要接受该申请吗？")
        }
    }
    
    func onAcceptPendingMember(pendingMember: TeamPendingMember) {
        selectedPendingMember = nil
        Task {
            let result = await CFQTeamServer.adminAcceptMember(authToken: user.jwtToken, game: user.currentMode, teamId: team.current.info.id, pendingMemberId: pendingMember.userId)
            if result.isEmpty {
                alertToastModel.toast = AlertToast(displayMode: .hud, type: .complete(.green), title: "已接受该申请")
                team.refresh(user: user)
            } else {
                alertToastModel.toast = AlertToast(displayMode: .hud, type: .error(.red), title: "接受申请失败", subTitle: result)
            }
        }
    }
    
    func onRejectPendingMember(pendingMember: TeamPendingMember) {
        selectedPendingMember = nil
        Task {
            let result = await CFQTeamServer.adminRejectMember(authToken: user.jwtToken, game: user.currentMode, teamId: team.current.info.id, pendingMemberId: pendingMember.userId)
            if result.isEmpty {
                alertToastModel.toast = AlertToast(displayMode: .hud, type: .complete(.green), title: "已拒绝该申请")
                team.refresh(user: user)
            } else {
                alertToastModel.toast = AlertToast(displayMode: .hud, type: .error(.red), title: "拒绝申请失败", subTitle: result)
            }
        }
    }
}

struct TeamPendingMemberSettingEntryView: View {
    let pendingMember: TeamPendingMember
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(pendingMember.nickname.transformingHalfwidthFullwidth())
                .bold()
            Divider()
            Group {
                HStack {
                    Text("Rating：")
                    Spacer()
                    Text(pendingMember.rating)
                }
                HStack {
                    Text("申请时间：")
                    Spacer()
                    Text(DateTool.ymdhmsDateString(from: TimeInterval(pendingMember.timestamp)))
                }
            }
            .font(.callout)
        }
    }
}
