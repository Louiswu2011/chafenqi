//
//  DeltaPlayList.swift
//  chafenqi
//
//  Created by xinyue on 2023/6/2.
//

import SwiftUI

struct DeltaPlayList: View {
    @ObservedObject var user: CFQNUser
    
    @State var chuLog: CFQChunithmRecentScoreEntries?
    @State var maiLog: CFQMaimaiRecentScoreEntries?
    
    var body: some View {
        ScrollView {
            VStack {
                if let chuLog = chuLog {
                    ForEach(chuLog, id: \.timestamp) { entry in
                        NavigationLink {
                            RecentDetail(user: user, chuEntry: entry)
                        } label: {
                            HStack {
                                SongCoverView(coverURL: ChunithmDataGrabber.getSongCoverUrl(source: user.chunithmCoverSource, musicId: String(entry.associatedSong!.musicID)), size: 65, cornerRadius: 5)
                                    .padding(.trailing, 5)
                                Spacer()
                                VStack {
                                    HStack {
                                        Text(entry.timestamp.customDateString)
                                        Spacer()
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
                } else if let maiLog = maiLog {
                    ForEach(maiLog, id: \.timestamp) { entry in
                        NavigationLink {
                            RecentDetail(user: user, maiEntry: entry)
                        } label: {
                            HStack {
                                SongCoverView(coverURL: MaimaiDataGrabber.getSongCoverUrl(source: user.maimaiCoverSource, coverId: getCoverNumber(id: String(entry.associatedSong!.musicId))), size: 65, cornerRadius: 5)
                                    .padding(.trailing, 5)
                                Spacer()
                                VStack {
                                    HStack {
                                        Text(entry.timestamp.customDateString)
                                        Spacer()
                                    }
                                    Spacer()
                                    HStack(alignment: .bottom) {
                                        Text(entry.title)
                                            .font(.system(size: 17))
                                            .lineLimit(2)
                                        Spacer()
                                        Text("\(entry.score, specifier: "%.4f")%")
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
            .padding(.horizontal)
        }
        .navigationTitle("游玩记录")
        .navigationBarTitleDisplayMode(.inline)
    }
}
