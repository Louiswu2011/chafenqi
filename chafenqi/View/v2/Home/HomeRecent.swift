//
//  RecentSpotlightCardView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/3/10.
//

import SwiftUI

struct HomeRecent: View {
    @ObservedObject var user: CFQNUser
    
    let prompt = ["最近一首", "新纪录", "高分"]
    
    var body: some View {
        VStack {
            HStack {
                Text("最近动态")
                    .font(.system(size: 20))
                    .bold()
                Spacer()
                
                NavigationLink {
                    RecentListView(user: user)
                } label: {
                    Text("显示全部")
                        .font(.system(size: 18))
                }
            }
            if (user.currentMode == 0) {
                if (user.chunithm.isNotEmpty) {
                    let recommended = expandChunithmRecommended(orig: user.chunithm.custom.recommended)
                    ForEach(recommended, id: \.0) { identifier, entry in
                        let prompt = recommendPrompts[identifier]!
                        NavigationLink {
                            RecentDetail(user: user, chuEntry: entry)
                        } label: {
                            HStack {
                                SongCoverView(coverURL: ChunithmDataGrabber.getSongCoverUrl(source: user.chunithmCoverSource, musicId: String(entry.associatedSong!.musicID)), size: 65, cornerRadius: 5, diffColor: chunithmLevelColor[entry.levelIndex])
                                    .padding(.trailing, 5)
                                Spacer()
                                VStack {
                                    HStack {
                                        Text(entry.timestamp.customDateString)
                                        Spacer()
                                        Text(prompt)
                                            .bold()
                                    }
                                    Spacer()
                                    HStack(alignment: .bottom) {
                                        Text(entry.title)
                                            .font(.system(size: 17))
                                            .lineLimit(2)
                                        Spacer()
                                        Text("\(entry.score)")
                                            .font(.system(size: 21))
                                            .bold()
                                    }
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            } else {
                if (user.maimai.isNotEmpty) {
                    let recommended = expandMaimaiRecommended(orig: user.maimai.custom.recommended)
                    ForEach(recommended, id: \.0) { identifier, entry in
                        let prompt = recommendPrompts[identifier]!
                        NavigationLink {
                            RecentDetail(user: user, maiEntry: entry)
                        } label: {
                            HStack {
                                SongCoverView(coverURL: MaimaiDataGrabber.getSongCoverUrl(source: user.maimaiCoverSource, coverId: entry.associatedSong?.coverId ?? 0), size: 65, cornerRadius: 5, diffColor: maimaiLevelColor[entry.levelIndex])
                                    .padding(.trailing, 5)
                                Spacer()
                                VStack {
                                    HStack {
                                        Text(entry.timestamp.customDateString)
                                        Spacer()
                                        Text(prompt)
                                            .bold()
                                    }
                                    Spacer()
                                    HStack(alignment: .bottom) {
                                        Text(entry.associatedSong?.title ?? "")
                                            .font(.system(size: 17))
                                            .lineLimit(2)
                                        Spacer()
                                        Text("\(entry.achievements, specifier: "%.4f")%")
                                            .font(.system(size: 21))
                                            .bold()
                                    }
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding()
    }
    
    
    func expandChunithmRecommended(orig: [CFQChunithm.RecentScoreEntry: String]) -> [(String, CFQChunithm.RecentScoreEntry)] {
        var r: [CFQChunithm.RecentScoreEntry] = []
        var recommended: [(String, CFQChunithm.RecentScoreEntry)] = []
        for entry in orig.keys {
            r.append(entry)
        }
        r = r.sorted {
            recommendWeights[orig[$0]!]! > recommendWeights[orig[$1]!]!
        }
        for entry in r {
            recommended.append((orig[entry]!, entry))
        }
        return Array(recommended.prefix(3))
    }
    
    func expandMaimaiRecommended(orig: [UserMaimaiRecentScoreEntry: String]) -> [(String, UserMaimaiRecentScoreEntry)] {
        var r: [UserMaimaiRecentScoreEntry] = []
        var recommended: [(String, UserMaimaiRecentScoreEntry)] = []
        for entry in orig.keys {
            r.append(entry)
        }
        r = r.sorted {
            recommendWeights[orig[$0]!]! > recommendWeights[orig[$1]!]!
        }
        for entry in r {
            recommended.append((orig[entry]!, entry))
        }
        return Array(recommended.prefix(3))
    }
}

struct HomeRecent_Previews: PreviewProvider {
    static var previews: some View {
        HomeRecent(user: CFQNUser())
    }
}

