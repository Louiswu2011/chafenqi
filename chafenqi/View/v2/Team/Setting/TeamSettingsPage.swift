//
//  TeamSettingsPage.swift
//  chafenqi
//
//  Created by Louis Wu on 2024/12/30.
//

import Foundation
import SwiftUI
import Inject
import AlertToast

struct TeamSettingsPage: View {
    @Environment(\.dismiss) var dismiss
    @ObserveInjection var inject
    
    @ObservedObject var team: CFQTeam
    @ObservedObject var user: CFQNUser
    @ObservedObject var alertToastModel = AlertToastModel.shared
    
    @State var promotable: Bool = false
    
    @State var courseName: String = ""
    @State var courseHealth: Int = 0
    
    @State var showRotateTeamCodeConfirmAlert: Bool = false
    @State var showDisbandTeamConfirmAlert: Bool = false
    
    var body: some View {
        let promotableToggle = Binding {
            promotable
        } set: { newValue in
            Task {
                let result = await updatePromotable(newValue: newValue)
                if result {
                    promotable = newValue
                }
            }
        }
        
        Form {
            Section {
                SettingsInfoLabelButton(title: "团队名称", message: team.current.info.displayName) {
                    
                }
                SettingsInfoLabelButton(title: "团队方针", message: team.current.info.style) {
                    
                }
                SettingsInfoLabelButton(title: "团队介绍", message: team.current.info.remarks) {
                    
                }
                Toggle(isOn: promotableToggle) {
                    Text("可被搜索")
                }
            } header: {
                Text("基本信息")
            } footer: {
                VStack(alignment: .leading) {
                    Text("团队名称在30天内仅能更改一次")
                    Text("最后修改时间：" + DateTool.ymdhmsDateString(from: TimeInterval(team.current.info.nameLastModifiedAt)))
                }
            }
            
            Section {
                NavigationLink {
                    TeamCourseSettingView(team: team, user: user)
                } label: {
                    Text("组曲")
                }
            }
            
            Section {
                NavigationLink {
                    TeamMemberSettingView(team: team, user: user)
                } label: {
                    HStack {
                        Text("成员")
                        Spacer()
                        Text("\(team.current.members.count)")
                            .foregroundStyle(Color.secondary)
                    }
                }
                
                NavigationLink {
                    TeamPendingMemberSettingView(team: team, user: user)
                } label: {
                    HStack {
                        Text("待加入成员")
                        Spacer()
                        Text("\(team.current.pendingMembers.count)")
                            .foregroundStyle(Color.secondary)
                    }
                }
            } header: {
                Text("成员管理")
            }
            
            Section {
                Button {
                    showRotateTeamCodeConfirmAlert.toggle()
                } label: {
                    Text("重新生成团队代码...")
                }
                Button {
                    showDisbandTeamConfirmAlert.toggle()
                } label: {
                    Text("解散...")
                        .foregroundStyle(Color.red)
                }
            } header: {
                Text("高级")
            }
        }
        .enableInjection()
        .onAppear {
            promotable = team.current.info.promotable
        }
        .navigationTitle("团队设置")
        .navigationBarTitleDisplayMode(.inline)
        .alert("更新团队代码", isPresented: $showRotateTeamCodeConfirmAlert) {
            Button("取消", role: .cancel) {}
            Button("确定") {
                onRotateTeamCode()
            }
        } message: {
            Text("确认要更新团队代码吗？更新后将无法通过原有的团队代码加入该团队。")
        }
        .alert("解散团队", isPresented: $showDisbandTeamConfirmAlert) {
            Button("取消", role: .cancel) {}
            Button("确定", role:. destructive) {
                onDisbandTeam()
            }
        } message: {
            Text("确认要解散团队吗？该操作无法撤销。")
        }
    }
    
    func updatePromotable(newValue: Bool) async -> Bool {
        return await CFQTeamServer.adminUpdateTeamPromotable(authToken: user.jwtToken, game: user.currentMode, teamId: team.current.info.id, promotable: newValue)
    }
    
    func onRotateTeamCode() {
        Task {
            let result = await CFQTeamServer.adminRotateTeamCode(authToken: user.jwtToken, game: user.currentMode, teamId: team.current.info.id)
            if result {
                alertToastModel.toast = AlertToast(displayMode: .hud, type: .complete(.green), title: "更新团队代码成功", subTitle: "请返回团队信息页查看")
                team.refresh(user: user)
            } else {
                alertToastModel.toast = AlertToast(displayMode: .hud, type: .error(.red), title: "更新团队代码失败", subTitle: "未知错误，请联系开发者")
            }
        }
    }
    
    func onDisbandTeam() {
        Task {
            let result = await CFQTeamServer.adminDisbandTeam(authToken: user.jwtToken, game: user.currentMode, teamId: team.current.info.id)
            if result {
                alertToastModel.toast = AlertToast(displayMode: .hud, type: .complete(.green), title: "解散成功")
                team.refresh(user: user)
                dismiss()
            } else {
                alertToastModel.toast = AlertToast(displayMode: .hud, type: .error(.red), title: "解散失败", subTitle: "未知错误，请联系开发者")
            }
        }
    }
}
