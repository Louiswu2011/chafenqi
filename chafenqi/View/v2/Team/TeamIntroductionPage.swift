//
//  TeamIntroductionPage.swift
//  chafenqi
//
//  Created by 刘易斯 on 2024/12/24.
//

import Foundation
import SwiftUI
import Inject
import AlertToast

struct TeamIntroductionPage: View {
    @ObserveInjection var inject
    
    @ObservedObject var team: CFQTeam
    @ObservedObject var user: CFQNUser
    @ObservedObject var alertToastModel = AlertToastModel.shared
    
    @State private var searchText: String = ""
    @State private var searchTeam: TeamBasicInfo? = nil
    
    @State private var showCreateSheet: Bool = false
    @State private var showConfirmApplyAlert: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                TextField("输入团队代码...", text: $searchText)
                Spacer()
                Button {
                    search()
                } label: {
                    Text("加入")
                }
                .disabled(searchText.count != 8)
            }
            .padding([.top, .horizontal])
            List {
                ForEach(team.list.sorted { $0.lastActivityAt > $1.lastActivityAt }.filter { $0.promotable }, id: \.id) { team in
                    Section {
                        TeamIntroductionEntryView(info: team) {
                            onApply(teamId: team.id, message: "")
                        }
                    }
                }
            }
        }
        .enableInjection()
        .navigationTitle("加入或创建团队")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showCreateSheet.toggle()
                } label: {
                    Label("创建团队", systemImage: "plus")
                }
            }
        }
        .disableAutocorrection(true)
        .autocapitalization(.none)
        .sheet(isPresented: $showCreateSheet) {
            TeamIntroductionCreateView(user: user, showForm: $showCreateSheet)
        }
        .refreshable {
            team.refresh(user: user)
        }
        .alert("申请加入", isPresented: $showConfirmApplyAlert) {
            Button("取消", role: .cancel) { searchTeam = nil }
            Button("确定") {
                if let info = searchTeam {
                    onApply(teamId: info.id, message: "")
                }
            }
        } message: {
            if let info = searchTeam {
                Text(info.displayName)
            }
        }
    }
    
    func search() {
        searchTeam = team.list.filter { $0.teamCode == searchText }.first
        if searchTeam != nil {
            showConfirmApplyAlert = true
        } else {
            alertToastModel.toast = AlertToast(displayMode: .hud, type: .error(.red), title: "未找到团队")
        }
        searchText = ""
    }
    
    func onApply(teamId: Int, message: String) {
        Task {
            let result = await CFQTeamServer.applyForTeam(authToken: user.jwtToken, game: user.currentMode, teamId: teamId, message: message)
            if result.isEmpty {
                alertToastModel.toast = AlertToast(displayMode: .hud, type: .complete(.green), title: "已发送申请", subTitle: "请注意同一时间申请数量")
            } else {
                alertToastModel.toast = AlertToast(displayMode: .hud, type: .error(.red), title: "发送申请失败", subTitle: result)
            }
        }
    }
}

struct TeamIntroductionEntryView: View {
    let info: TeamBasicInfo
    let onApply: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(info.displayName)
                .bold()
            Divider()
            Group {
                HStack {
                    Text("最近活动日期")
                    Spacer()
                    Text(DateTool.ymdhmsDateString(from: TimeInterval(info.lastActivityAt)))
                }
                HStack {
                    Text("团队方针")
                    Text(info.style)
                }
                HStack {
                    Text("团队介绍")
                    Text(info.remarks)
                        .lineLimit(2)
                }
            }
            .font(.callout)
            HStack {
                Spacer()
                Button {
                    onApply()
                } label: {
                    Text("申请加入")
                }
            }
        }
    }
}

struct TeamIntroductionCreateView: View {
    @ObservedObject var user: CFQNUser
    @ObservedObject var alertToastModel = AlertToastModel.shared
    @Binding var showForm: Bool
    
    @State private var showToast: Bool = false
    @State private var toast = AlertToast(displayMode: .hud, type: .regular)
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                PremiumInfoBlock(imageSystemName: "person.3", title: "成员一览", message: "通过团队代码邀请好友加入团队，并在App内查看成员的Rating和游玩次数等信息。")
                PremiumInfoBlock(imageSystemName: "message", title: "留言板", message: "使用队内的留言板给队友留言。留言对所有人可见。")
                PremiumInfoBlock(imageSystemName: "chart.bar", title: "月间排行", message: "通过在机台上游玩并上传成绩来为团队积攒点数，并参加月间的团队点数排行榜。")
                PremiumInfoBlock(imageSystemName: "list.bullet.rectangle", title: "组曲挑战", message: "队长可以挑选三首歌曲作为团队的组曲挑战。成员在机台按顺序游玩后上传成绩，即可同步到App内，并参加队内排行榜。")
                Spacer()
                Text("注：创建团队需要订阅会员")
                    .foregroundStyle(Color.secondary)
                    .font(.caption)
                NavigationLink {
                    TeamIntroductionCreateFormView(user: user, showForm: $showForm, onSuccess: {
                        alertToastModel.toast = AlertToast(displayMode: .hud, type: .complete(.green), title: "创建成功", subTitle: "刷新以生效")
                        showForm = false
                    }) { result in
                        toast = AlertToast(displayMode: .hud, type: .error(.red), title: "创建失败", subTitle: result)
                        showToast = true
                    }
                } label: {
                    Label("创建团队", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
                .disabled(!user.isPremium)
            }
            .padding()
            .navigationTitle("团队功能介绍")
            .navigationBarTitleDisplayMode(.inline)
        }
        .toast(isPresenting: $showToast, duration: 3, tapToDismiss: true, offsetY: 35) {
            toast
        }
    }
}

struct TextLengthLimiter: View {
    let limit: Int
    @Binding var text: String
    
    var body: some View {
        HStack {
            Text("\(text.count)/\(limit)")
        }
        .foregroundStyle((text.count > limit || text.count == 0) ? Color.red : Color.secondary)
    }
}

struct TeamIntroductionCreateFormView: View {
    @ObservedObject var user: CFQNUser
    
    @Binding var showForm: Bool
    
    @State private var teamName: String = ""
    @State private var teamStyle: String = ""
    @State private var teamRemarks: String = ""
    @State private var promotable: Bool = true
    
    let onSuccess: () -> Void
    let onFailure: (String) -> Void

    var body: some View {
        Form {
            Section {
                TextField("团队名称", text: $teamName)
            } footer: {
                HStack {
                    Spacer()
                    TextLengthLimiter(limit: teamNameLimit, text: $teamName)
                }
            }
            
            Section {
                TextField("团队方针", text: $teamStyle)
            } footer: {
                HStack {
                    Text("例如：自由加入、活跃者优先等")
                    Spacer()
                    TextLengthLimiter(limit: teamStyleLimit, text: $teamStyle)
                }
            }

            Section {
                TextEditor(text: $teamRemarks)
            } header: {
                Text("团队介绍")
            } footer: {
                HStack {
                    Spacer()
                    TextLengthLimiter(limit: teamRemarksLimit, text: $teamRemarks)
                }
            }
            
            Section {
                Toggle("可被搜索", isOn: $promotable)
            }
            
            Section {
                Button {
                    onCreateTeam()
                } label: {
                    Text("创建")
                }
                .disabled(
                    !(teamName.count > 0 && teamName.count <= teamNameLimit) ||
                    !(teamStyle.count > 0 && teamStyle.count <= teamStyleLimit) ||
                    !(teamRemarks.count > 0 && teamRemarks.count <= teamRemarksLimit)
                )
            }
        }
        .navigationTitle("创建团队")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    reset()
                } label: {
                    Text("重置")
                }
            }
        }
        .autocorrectionDisabled()
        .textInputAutocapitalization(.never)
    }
    
    func reset() {
        teamName = ""
        teamStyle = ""
        teamRemarks = ""
        promotable = true
    }
    
    func onCreateTeam() {
        let payload = TeamCreatePayload(game: user.currentMode, displayName: teamName, style: teamStyle, remarks: teamRemarks, promotable: promotable)
        Task {
            let result = await CFQTeamServer.createTeam(authToken: user.jwtToken, payload: payload)
            if result.isEmpty {
                onSuccess()
            } else {
                onFailure(result)
            }
        }
    }
}
