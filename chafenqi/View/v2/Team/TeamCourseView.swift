//
//  TeamCourseView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2024/12/25.
//

import Foundation
import SwiftUI
import Inject

struct TeamCourseView: View {
    @ObserveInjection var inject
    
    @ObservedObject var team: CFQTeam
    @ObservedObject var user: CFQNUser
    
    @State var courseTrackInfos: [(String, String, String, URL, Color)] = []
    @State var playCount: Int = 0
    @State var passCount: Int = 0
    
    var body: some View {
        VStack {
            if team.current.info.courseName.isEmpty {
                if user.userId == team.current.info.leaderUserId {
                    Text("暂未设置组曲，请在团队设置中添加")
                } else {
                    Text("队长暂未设置组曲")
                }
            } else {
                ScrollView {
                    VStack {
                        Text(team.current.info.courseName)
                            .bold()
                        
                        if !courseTrackInfos.isEmpty {
                            VStack {
                                TeamCourseMusicEntryView(index: 0, info: courseTrackInfos[0])
                                TeamCourseMusicEntryView(index: 1, info: courseTrackInfos[1])
                                TeamCourseMusicEntryView(index: 2, info: courseTrackInfos[2])
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Text("游玩人数：")
                        Text("\(playCount)")
                            .bold()
                        Spacer()
                        Text("通过人数：")
                        Text("\(passCount)")
                            .bold()
                    }
                    .font(.callout)
                    .padding(.horizontal)
                    
                    Divider()
                }
            }
        }
        .enableInjection()
        .onAppear {
            if let tracks = team.current.info.courseTracks() {
                courseTrackInfos = tracks.compactMap { getTrackInfo(track: $0) }
            }
            
            playCount = team.current.courseRecords.count
            passCount = team.current.courseRecords.filter { $0.cleared }.count
        }
    }
    
    func getTrackInfo(track: TeamCourseTrack?) -> (String, String, String, URL, Color)? {
        guard let track = track else { return nil }
        var title: String
        var artist: String
        var url: URL
        
        if user.currentMode == 0 {
            if let music = user.data.chunithm.musics.first(where: { $0.musicID == track.musicId }) {
                title = music.title
                artist = music.artist
                url = music.coverURL
            } else { return nil }
        } else {
            if let music = user.data.maimai.songlist.first(where: { $0.musicId == track.musicId }) {
                title = music.title
                artist = music.basicInfo.artist
                url = music.coverURL
            } else { return nil }
        }
        let difficulty = if user.currentMode == 0 {
            chunithmLevelLabel[track.levelIndex] ?? ""
        } else {
            maimaiLevelLabel[track.levelIndex] ?? ""
        }
        guard let diffColor = (user.currentMode == 0 ? chunithmLevelColor : maimaiLevelColor)[track.levelIndex] else { return nil }
        
        return (title, artist, difficulty, url, diffColor)
    }
}

struct TeamCourseMusicEntryView: View {
    @Environment(\.colorScheme) var colorScheme
    
    let index: Int
    let info: (String, String, String, URL, Color)
    
    var body: some View {
        HStack {
            HStack {
                SongCoverView(coverURL: info.3, size: 80, cornerRadius: 10, withShadow: false)
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(colorScheme == .dark ? .white.opacity(0.33) : .black.opacity(0.33), lineWidth: 1))
                VStack(alignment: .leading) {
                    HStack {
                        Text("TRACK \(index + 1)")
                        Spacer()
                        Text(info.2)
                            .foregroundStyle(info.4)
                    }
                    Spacer()
                    Text(info.0)
                        .bold()
                    Text(info.1)
                        .font(.caption)
                }
            }
        }
    }
}
