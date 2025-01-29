//
//  TeamMemberSetting.swift
//  chafenqi
//
//  Created by Louis Wu on 2024/12/31.
//

import Foundation
import SwiftUI
import Inject
import AlertToast

struct TeamMemberSettingView: View {
    @ObserveInjection var inject
    
    @ObservedObject var team: CFQTeam
    @ObservedObject var user: CFQNUser
    @ObservedObject var alertToastModel = AlertToastModel.shared
    
    @State private var selectedMember: TeamMember? = nil
    @State private var showTransferConfirmAlert: Bool = false
    @State private var showDeleteConfirmAlert: Bool = false
    
    var body: some View {
        List {
            ForEach(team.current.members, id: \.userId) { member in
                let isLeader = member.userId == team.current.info.leaderUserId
                TeamMemberSettingEntryView(member: member, isLeader: isLeader)
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button {
                            selectedMember = member
                            showDeleteConfirmAlert.toggle()
                        } label: {
                            Text("移除")
                        }
                        .tint(Color.red)
                        
                        if !isLeader {
                            Button {
                                selectedMember = member
                                showTransferConfirmAlert.toggle()
                            } label: {
                                Text("转让")
                            }
                            .tint(Color.blue)
                        }
                    }
            }
        }
        .enableInjection()
        .navigationTitle("成员")
        .navigationBarTitleDisplayMode(.inline)
        .alert("转让队长", isPresented: $showTransferConfirmAlert) {
            Button("取消", role: .cancel) { selectedMember = nil }
            Button("确定", role: .destructive) {
                guard let member = selectedMember else { return }
                onTransferLeader(member: member)
            }
        } message: {
            Text("确定要转让队长吗？该操作无法撤销。")
        }
        .alert("移除成员", isPresented: $showDeleteConfirmAlert) {
            Button("取消", role: .cancel) { selectedMember = nil }
            Button("确定", role: .destructive) {
                guard let member = selectedMember else { return }
                onKickMember(member: member)
            }
        } message: {
            Text("确定要移除成员吗？该操作无法撤销。")
        }
    }
    
    func onTransferLeader(member: TeamMember) {
        selectedMember = nil
        Task {
            let result = await CFQTeamServer.adminTransferOwnership(authToken: user.jwtToken, game: user.currentMode, teamId: team.current.info.id, newLeaderUserId: member.userId)
            if result.isEmpty {
                alertToastModel.toast = AlertToast(displayMode: .hud, type: .complete(Color.green), title: "转让成功")
                team.refresh(user: user)
            } else {
                alertToastModel.toast = AlertToast(displayMode: .hud, type: .error(Color.red), title: "转让失败", subTitle: result)
            }
        }
    }
    
    func onKickMember(member: TeamMember) {
        selectedMember = nil
        Task {
            let result = await CFQTeamServer.adminKickMember(authToken: user.jwtToken, game: user.currentMode, teamId: team.current.info.id, memberId: member.userId)
            if result.isEmpty {
                alertToastModel.toast = AlertToast(displayMode: .hud, type: .complete(Color.green), title: "移除成功")
                team.refresh(user: user)
            } else {
                alertToastModel.toast = AlertToast(displayMode: .hud, type: .error(Color.red), title: "移除失败", subTitle: result)
            }
        }
    }
}

struct TeamMemberSettingEntryView: View {
    let member: TeamMember
    let isLeader: Bool
    
    var body: some View {
        VStack {
            HStack {
                Text(member.nickname.transformingHalfwidthFullwidth())
                    .bold()
                Spacer()
                Text(isLeader ? "队长" : "普通成员")
                    .foregroundStyle(Color.secondary)
            }
            Divider()
            Group {
                HStack {
                    Text("游玩次数：")
                    Spacer()
                    Text("\(member.playCount)")
                }
                HStack {
                    Text("加入时间：")
                    Spacer()
                    Text(DateTool.ymdhmsDateString(from: TimeInterval(member.joinAt)))
                }
                HStack {
                    Text("最后游玩时间：")
                    Spacer()
                    Text(DateTool.ymdhmsDateString(from: TimeInterval(member.lastActivityAt)))
                }
            }
            .font(.callout)
        }
    }
}
