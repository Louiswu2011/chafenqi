//
//  TeamSettingsPage.swift
//  chafenqi
//
//  Created by Louis Wu on 2024/12/30.
//

import Foundation
import SwiftUI
import Inject
import Setting

struct TeamSettingsPage: View {
    @ObserveInjection var inject
    
    let healthChoice = ["1", "10", "50", "100", "200", "无限制"]
    
    @ObservedObject var team: CFQTeam
    @ObservedObject var user: CFQNUser

    @State var promotable: Bool = false
    
    @State var courseName: String = ""
    @State var courseHealth: Int = 0
    
    @State var courseTrack1: TeamCourseTrack? = nil
    @State var courseTrack2: TeamCourseTrack? = nil
    @State var courseTrack3: TeamCourseTrack? = nil
    
    var body: some View {
        return SettingStack(embedInNavigationStack: false) {
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
            
            let courseNameInput = Binding {
                courseName
            } set: { newValue in
                
            }
            
            let courseHealthInput = Binding {
                courseHealth
            } set: { newValue in
                
            }
            
            return SettingPage(title: "团队设置") {
                SettingGroup(header: "基本信息", footer: "团队名称在30天内仅能更改一次") {
                    
                    
                    SettingButton(title: "团队名称", indicator: "square.and.pencil") {
                        
                    }
                    SettingButton(title: "团队方针", indicator: "square.and.pencil") {
                        
                    }
                    SettingButton(title: "团队介绍", indicator: "square.and.pencil") {
                        
                    }
                    SettingToggle(title: "可被搜索", isOn: promotableToggle)
                    SettingPage(title: "组曲", selectedChoice: team.current.info.courseName.isEmpty ? "未设置" : team.current.info.courseName) {
                        
                        SettingGroup(header: "基本信息") {
                            SettingButton(title: "组曲名称", indicator: "square.and.pencil") {
                                
                            }
                            SettingPicker(title: "生命值", choices: healthChoice, selectedIndex: courseHealthInput)
                                .pickerDisplayMode(.menu)
                        }
                        
                        SettingGroup(header: "歌曲配置") {
                            SettingPage(title: "TRACK 1", selectedChoice: getTrackInfo(track: courseTrack1)) {
                                
                            }
                            SettingPage(title: "TRACK 2", selectedChoice: getTrackInfo(track: courseTrack2)) {
                                
                            }
                            SettingPage(title: "TRACK 3", selectedChoice: getTrackInfo(track: courseTrack3)) {
                                
                            }
                        }
                        
                        SettingGroup(footer: "组曲在30天内仅能更改一次，更新后将会重置当前排行榜") {
                            SettingButton(title: "应用更改") {
                                
                            }
                        }
                    }
                    .previewIcon("list.bullet.rectangle.fill", color: Color.orange)
                }
                SettingGroup(header: "成员管理") {
                    SettingPage(title: "成员", selectedChoice: "\(team.current.members.count)人") {
                        
                    }
                    .previewIcon("person.2.fill", color: Color.blue)
                    SettingPage(title: "待加入成员", selectedChoice: team.current.pendingMembers.isEmpty ? "暂无" : "\(team.current.pendingMembers.count)人") {
                        
                    }
                    .previewIcon("person.fill.badge.plus", color: Color.green)
                }
                SettingGroup(header: "高级功能") {
                    SettingButton(title: "重新生成团队代码", indicator: "arrow.clockwise") {
                        
                    }
                    SettingButton(title: "解散团队", indicator: "trash") {
                        
                    }
                }
            }
        }
        .enableInjection()
        .onAppear {
            promotable = team.current.info.promotable
            courseHealth = healthChoice.firstIndex(of: String(team.current.info.courseHealth)) ?? 5
            
            if let tracks = team.current.info.courseTracks() {
                courseTrack1 = tracks[0]
                courseTrack2 = tracks[1]
                courseTrack3 = tracks[2]
            }
        }
        
        func getTrackInfo(track: TeamCourseTrack?) -> String {
            guard let track = track else { return "暂未设定" }
            let title = if user.currentMode == 0 {
                user.data.chunithm.musics.first { $0.musicID == track.musicId }?.title ?? ""
            } else {
                user.data.maimai.songlist.first { $0.musicId == track.musicId }?.title ?? ""
            }
            let difficulty = if user.currentMode == 0 {
                chunithmLevelLabel[track.levelIndex] ?? ""
            } else {
                maimaiLevelLabel[track.levelIndex] ?? ""
            }
            
            return "\(title) \(difficulty)"
        }
    }
    
    func updatePromotable(newValue: Bool) async -> Bool {
        return await CFQTeamServer.adminUpdateTeamPromotable(authToken: user.jwtToken, game: user.currentMode, teamId: team.current.info.id, promotable: newValue)
    }
}
