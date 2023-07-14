//
//  RecentSpotlightCardView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/3/10.
//

import SwiftUI

struct RecentSpotlightView: View {    
    @ObservedObject var user = CFQUser()
    
    let prompt = ["最近一首", "新纪录", "高分"]
    
    var body: some View {
        VStack {
            if (user.currentMode == 0) {
                if (user.chunithm != nil) {
                    let recents: [(Int?, ChunithmRecentRecord?)] = [(0, user.chunithm!.recent.first), user.chunithm!.recent.getLatestNewRecord(), user.chunithm!.recent.getLatestHighscore()]
                    ForEach(Array(recents.enumerated()), id: \.offset) { index, record in
                        let (recentIndex, entry) = record
                        if (entry != nil && recentIndex != nil) {
                            NavigationLink {
                                RecentDetailView(user: user, chuSong: user.chunithm!.custom.recentSong[recentIndex!], chuRecord: entry!, mode: 0)
                            } label: {
                                HStack {
                                    SongCoverView(coverURL: ChunithmDataGrabber.getSongCoverUrl(source: user.chunithmCoverSource, musicId: entry!.music_id), size: 65, cornerRadius: 5)
                                        .padding(.trailing, 5)
                                    Spacer()
                                    VStack {
                                        HStack {
                                            Text(entry!.getDateString())
                                            Spacer()
                                            Text(prompt[index])
                                                .bold()
                                        }
                                        Spacer()
                                        HStack(alignment: .bottom) {
                                            Text(entry!.title)
                                                .font(.system(size: 17))
                                            Spacer()
                                            Text(entry!.score)
                                                .font(.system(size: 21))
                                                .bold()
                                        }
                                    }
                                }
                                .frame(height: 75)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            } else {
                if (user.maimai != nil) {
                    let recents: [(Int?, MaimaiRecentRecord?)] = [(0, user.maimai!.recent.first), user.maimai!.recent.getLatestNewRecord(), user.maimai!.recent.getLatestHighscore()]
                    ForEach(Array(recents.enumerated()), id: \.offset) { index, record in
                        let (recentIndex, entry) = record
                        if (entry != nil && recentIndex != nil) {
                            NavigationLink {
                                let song = user.maimai!.custom.recentSong[recentIndex!]
                                if (song != nil) {
                                    RecentDetailView(user: user, maiSong: song, maiRecord: entry!, mode: 1)
                                }
                            } label: {
                                HStack {
                                    SongCoverView(coverURL: MaimaiDataGrabber.getSongCoverUrl(source: user.maimaiCoverSource, coverId: getCoverNumber(id: user.maimai!.custom.recentSong[recentIndex!]!.musicId)), size: 65, cornerRadius: 5)
                                        .padding(.trailing, 5)
                                    Spacer()
                                    VStack {
                                        HStack {
                                            Text(entry!.getDateString())
                                            Spacer()
                                            Text(prompt[index])
                                                .bold()
                                        }
                                        Spacer()
                                        HStack(alignment: .bottom) {
                                            Text(entry!.title)
                                                .font(.system(size: 17))
                                            Spacer()
                                            Text(entry!.achievement)
                                                .font(.system(size: 21))
                                                .bold()
                                        }
                                    }
                                }
                                .frame(height: 75)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }
}

struct RecentSpotlightCardView_Previews: PreviewProvider {
    static var previews: some View {
        RecentSpotlightView()
    }
}
