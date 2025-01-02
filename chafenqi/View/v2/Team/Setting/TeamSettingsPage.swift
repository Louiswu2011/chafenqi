//
//  TeamSettingsPage.swift
//  chafenqi
//
//  Created by Louis Wu on 2024/12/30.
//

import Foundation
import SwiftUI
import Inject

struct TeamSettingsPage: View {
    @ObserveInjection var inject
    
    @ObservedObject var team: CFQTeam
    @ObservedObject var user: CFQNUser
    
    @State var promotable: Bool = false
    
    @State var courseName: String = ""
    @State var courseHealth: Int = 0
    
    
    
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
                Text("团队名称在30天内仅能更改一次")
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
                    
                } label: {
                    Text("重新生成团队代码...")
                }
                Button {
                    
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
    }
    
    func updatePromotable(newValue: Bool) async -> Bool {
        return await CFQTeamServer.adminUpdateTeamPromotable(authToken: user.jwtToken, game: user.currentMode, teamId: team.current.info.id, promotable: newValue)
    }
}
