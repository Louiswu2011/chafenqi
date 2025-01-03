//
//  TeamCourseSetting.swift
//  chafenqi
//
//  Created by Louis Wu on 2024/12/31.
//

import Foundation
import SwiftUI
import Inject
import AlertToast

struct TeamCourseSettingView: View {
    let healthChoice = ["1", "10", "50", "100", "200", "无限制"]
    
    @ObserveInjection var inject
    
    @ObservedObject var team: CFQTeam
    @ObservedObject var user: CFQNUser
    @ObservedObject var toastModel = AlertToastModel.shared
    
    @State var courseName: String = ""
    @State var courseHealth: String = ""
    
    @State var courseTracks: [TeamCourseTrack?] = [nil, nil, nil]
    
    @State var showCourseNameAlert: Bool = false
    @State var courseNameInput: String = ""
    
    @State var showMusicSelectionSheet: Bool = false
    @State var currentTrackIndex: Int = -1
    
    @State var showCourseSubmitAlert: Bool = false
    @State var courseSubmitAlertMessage: String = ""
    
    @State var musicList: [TeamSettingMusicInfo] = []
    
    var body: some View {
        Form {
            Section {
                SettingsInfoLabelButton(title: "组曲名称", message: courseName) {
                    showCourseNameAlert.toggle()
                }
                Picker("生命值", selection: $courseHealth) {
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
                TeamCourseSelectionButton(title: "TRACK 1", info: getTrackInfo(track: courseTracks[0])) {
                    currentTrackIndex = 0
                    showMusicSelectionSheet.toggle()
                }
                TeamCourseSelectionButton(title: "TRACK 2", info: getTrackInfo(track: courseTracks[1])) {
                    currentTrackIndex = 1
                    showMusicSelectionSheet.toggle()
                }
                TeamCourseSelectionButton(title: "TRACK 3", info: getTrackInfo(track: courseTracks[2])) {
                    currentTrackIndex = 2
                    showMusicSelectionSheet.toggle()
                }
            } header: {
                Text("歌曲配置")
            }
            
            Section {
                Button {
                    showCourseSubmitAlert.toggle()
                } label: {
                    Text("应用更改...")
                }
                .disabled(courseName.isEmpty || courseHealth.isEmpty || courseTracks.contains { $0 == nil })
            } footer: {
                Text("组曲在30天内仅能更改一次，更新后将会重置当前排行榜")
            }
        }
        .navigationTitle("组曲")
        .navigationBarTitleDisplayMode(.inline)
        .enableInjection()
        .onAppear {
            loadVar()
        }
        .sheet(isPresented: $showMusicSelectionSheet) {
            TeamSettingMusicSelectionSheet(
                mode: user.currentMode,
                musicList: musicList,
                onSubmit: { musicId, levelIndex in
                    print("Selected \(musicId) \(levelIndex) for TRACK \(currentTrackIndex + 1)")
                    showMusicSelectionSheet.toggle()
                    courseTracks[currentTrackIndex] = TeamCourseTrack(musicId: musicId, levelIndex: levelIndex)
                }
            )
        }
        .alert("输入组曲名称", isPresented: $showCourseNameAlert) {
            TextField("", text: $courseNameInput)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            Button("取消", role: .cancel) {}
            Button("确定", action: submitCourseName)
                .disabled(courseNameInput.isEmpty)
        } message: {}
        .alert("应用更改", isPresented: $showCourseSubmitAlert) {
            Button("取消", role: .cancel) {}
            Button("确定", action: submitCourse)
        } message: {
            Text("确定要应用更改吗？应用后将会重置当前排行榜，且30天内无法再次更改组曲设定。")
        }
    }
    
    
    func submitCourse() {
        guard let track1 = courseTracks[0], let track2 = courseTracks[1], let track3 = courseTracks[2] else { return }
        let newTrack1 = TeamUpdateCoursePayload.CourseEntry(musicId: track1.musicId, levelIndex: track1.levelIndex)
        let newTrack2 = TeamUpdateCoursePayload.CourseEntry(musicId: track2.musicId, levelIndex: track2.levelIndex)
        let newTrack3 = TeamUpdateCoursePayload.CourseEntry(musicId: track3.musicId, levelIndex: track3.levelIndex)
        
        let payload = TeamUpdateCoursePayload(courseName: courseName, courseTrack1: newTrack1, courseTrack2: newTrack2, courseTrack3: newTrack3, courseHealth: courseHealth == "无限制" ? -1 : Int(courseHealth) ?? -1)
        
        Task {
            let result = await CFQTeamServer.adminUpdateTeamCourse(authToken: user.jwtToken, game: user.currentMode, teamId: team.current.info.id, newCourse: payload)
            if !result.isEmpty {
                courseSubmitAlertMessage = result
                toastModel.toast = AlertToast(displayMode: .hud, type: .error(.red), title: "更新组曲失败", subTitle: courseSubmitAlertMessage)
            } else {
                toastModel.toast = AlertToast(displayMode: .hud, type: .complete(.green), title: "更新组曲成功")
                team.refresh(user: user)
                loadVar()
            }
        }
    }
    
    func submitCourseName() {
        courseName = courseNameInput
        courseNameInput = ""
    }
    
    func getMusicList() -> [TeamSettingMusicInfo] {
        return if user.currentMode == 0 {
            user.data.chunithm.musics.map { music in
                TeamSettingMusicInfo(musicId: music.musicID, title: music.title, artist: music.artist, coverUrl: music.coverURL, levels: music.charts.levels)
            }
        } else {
            user.data.maimai.songlist.map { music in
                TeamSettingMusicInfo(musicId: music.musicId, title: music.title, artist: music.basicInfo.artist, coverUrl: music.coverURL, levels: music.level)
            }
        }
    }
    
    func getTrackInfo(track: TeamCourseTrack?) -> (String, String, Color)? {
        guard let track = track else { return nil }
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
        
        guard let diffColor = (user.currentMode == 0 ? chunithmLevelColor : maimaiLevelColor)[track.levelIndex] else { return nil }
        
        return (title, difficulty, diffColor)
    }
    
    func loadVar() {
        musicList = getMusicList()
        courseName = team.current.info.courseName.isEmpty ? "暂未设置" : team.current.info.courseName
        courseHealth = team.current.info.courseHealth == -1 ? "无限制" : String(team.current.info.courseHealth)
        
        if let tracks = team.current.info.courseTracks() {
            courseTracks = tracks
        }
    }
}

struct TeamSettingMusicInfo {
    let musicId: Int
    let title: String
    let artist: String
    let coverUrl: URL
    let levels: [String]
}

struct TeamSettingMusicSelectionSheet: View {
    let mode: Int
    let musicList: [TeamSettingMusicInfo]
    let onSubmit: (Int, Int) -> Void
    
    @Environment(\.colorScheme) var colorScheme
    @ObserveInjection var inject
    
    @State private var filteredList: [TeamSettingMusicInfo] = []
    @State private var searchText: String = ""
    
    @State private var selectedMusicId: Int = 0
    @State private var selectedLevelIndex: Int = 0
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack {
                    ForEach(filteredList, id: \.musicId) { music in
                        HStack {
                            SongCoverView(coverURL: music.coverUrl, size: 80, cornerRadius: 10, withShadow: false)
                                .overlay(RoundedRectangle(cornerRadius: 10)
                                    .stroke(colorScheme == .dark ? .white.opacity(0.33) : .black.opacity(0.33), lineWidth: 1))
                            VStack(alignment: .leading) {
                                Text(music.title)
                                    .font(.system(size: 20))
                                    .bold()
                                    .lineLimit(1)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Text(music.artist)
                                    .font(.system(size: 15))
                                    .lineLimit(1)
                                Spacer()
                                HStack {
                                    ForEach(music.levels.indices, id: \.self) { index in
                                        if let color = (mode == 0 ? chunithmLevelColor : maimaiLevelColor)[index], music.levels[index] != "0" && !music.levels[index].isEmpty {
                                            LevelBlockView(color: color, level: music.levels[index])
                                                .onTapGesture {
                                                    onSubmit(music.musicId, index)
                                                }
                                        }
                                    }
                                }
                                .padding(.bottom, 5)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                    }
                }
            }
            .navigationTitle("选择歌曲和难度")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            filteredList = musicList
        }
        .searchable(text: $searchText, prompt: "搜索标题或曲师...")
        .onSubmit(of: .search) {
            filteredList = musicList.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) || $0.artist.localizedCaseInsensitiveContains(searchText)
            }
        }
        .enableInjection()
    }
}

struct TeamCourseSelectionButton: View {
    let title: String
    let info: (String, String, Color)?
    
    let action: () -> Void
    let lineLimit: Int = 1
    
    var body: some View {
        HStack {
            Button {
                action()
            } label: {
                HStack {
                    Text(title)
                        .layoutPriority(1)
                    Spacer()
                    if let info = info {
                        Text(info.0)
                            .foregroundStyle(Color.gray)
                            .layoutPriority(0)
                        Text(info.1)
                            .layoutPriority(1)
                            .foregroundStyle(info.2)
                    } else {
                        Text("未设置")
                            .foregroundStyle(Color.gray)
                    }
                    Image(systemName: "chevron.right")
                        .layoutPriority(1)
                }
                .lineLimit(lineLimit)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
            }
        }
        .buttonStyle(.plain)
    }
}
