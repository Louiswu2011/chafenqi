//
//  TeamCourseSetting.swift
//  chafenqi
//
//  Created by Louis Wu on 2024/12/31.
//

import Foundation
import SwiftUI
import Inject

struct TeamCourseSettingView: View {
    let healthChoice = ["1", "10", "50", "100", "200", "无限制"]
    
    @ObserveInjection var inject
    
    @ObservedObject var team: CFQTeam
    @ObservedObject var user: CFQNUser
    
    @State var courseName: String = ""
    @State var courseHealth: String = ""
    
    @State var courseTrack1: TeamCourseTrack? = nil
    @State var courseTrack2: TeamCourseTrack? = nil
    @State var courseTrack3: TeamCourseTrack? = nil
    
    var body: some View {
        let courseNameInput = Binding {
            courseName
        } set: { newValue in
            
        }
        
        let courseHealthInput = Binding {
            courseHealth
        } set: { newValue in
            
        }
        
        Form {
            Section {
                SettingsInfoLabelButton(title: "组曲名称", message: courseName) {
                    
                }
                Picker("生命值", selection: courseHealthInput) {
                    ForEach(healthChoice, id: \.hashValue) { health in
                        Text(health)
                            .tag(health)
                    }
                }
                .pickerStyle(.menu)
            } header: {
                Text("基本信息")
            }
            
            Section {
                SettingsInfoLabelButton(title: "TRACK 1", message: getTrackInfo(track: courseTrack1)) {
                    
                }
                SettingsInfoLabelButton(title: "TRACK 2", message: getTrackInfo(track: courseTrack2)) {
                    
                }
                SettingsInfoLabelButton(title: "TRACK 3", message: getTrackInfo(track: courseTrack3)) {
                    
                }
            } header: {
                Text("歌曲配置")
            }
            
            Section {
                Button {
                    
                } label: {
                    Text("应用更改")
                }
            } footer: {
                Text("组曲在30天内仅能更改一次，更新后将会重置当前排行榜")
            }
        }
        .navigationTitle("组曲")
        .navigationBarTitleDisplayMode(.inline)
        .enableInjection()
        .onAppear {
            courseName = team.current.info.courseName.isEmpty ? "暂未设置" : team.current.info.courseName
            courseHealth = team.current.info.courseHealth == -1 ? "无限制" : String(team.current.info.courseHealth)
            
            if let tracks = team.current.info.courseTracks() {
                courseTrack1 = tracks[0]
                courseTrack2 = tracks[1]
                courseTrack3 = tracks[2]
            }
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

struct TeamSettingMusicSelectionView: View {
    @State private var keyword: String = ""
    
    @Binding var selectedMusicId: Int
    @Binding var selectedDifficultyIndex: Int
    
    var body: some View {
        ScrollView {
            LazyVStack {
                
            }
        }
        .searchable(text: $keyword, prompt: Text("输入标题..."))
    }
}
