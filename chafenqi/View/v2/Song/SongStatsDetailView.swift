//
//  SongStatsView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2024/06/15.
//

import SwiftUI
import AlertToast
import SwiftUICharts

struct SongStatsDetailView: View {
    var maiSong: MaimaiSongData?
    var chuSong: ChunithmMusicData?
    
    var maiRecord: UserMaimaiRecentScoreEntry?
    var chuRecord: UserChunithmRecentScoreEntry?
    
    var maiRecords: UserMaimaiRecentScores?
    var chuRecords: UserChunithmRecentScores?
    
    var diff: Int
    
    @Environment(\.managedObjectContext) var context
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var user: CFQNUser
    @ObservedObject var alertToast = AlertToastModel.shared
    
    @State var coverUrl = URL(string: "http://127.0.0.1")!
    @State var title = ""
    @State var artist = ""
    @State var diffLabel = ""
    @State var diffLabelColor = Color.black
    
    @State var maiStat = CFQMusicStat()
    @State var chuStat = CFQMusicStat()
    
    @State var chuLeaderboard: CFQChunithmLeaderboard = []
    @State var maiLeaderboard: CFQMaimaiLeaderboard = []
    
    @State var doneLoadingStat = false
    @State var doneLoadingLeaderboard = false
    
    @State var currentTab = 0
    
    var body: some View {
        VStack {
            HStack {
                SongCoverView(coverURL: coverUrl, size: 120, cornerRadius: 10, withShadow: false)
                    .overlay(RoundedRectangle(cornerRadius: 10)
                        .stroke(colorScheme == .dark ? .white.opacity(0.33) : .black.opacity(0.33), lineWidth: 1))
                    .padding(.leading)
                    .contextMenu {
                        Button {
                            Task {
                                let fetchRequest = CoverCache.fetchRequest()
                                fetchRequest.predicate = NSPredicate(format: "imageUrl == %@", coverUrl.absoluteString)
                                let matches = try? context.fetch(fetchRequest)
                                if let match = matches?.first?.image, let image = UIImage(data: match) {
                                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                                    alertToast.toast = AlertToast(displayMode: .hud, type: .complete(.green), title: "保存成功")
                                }
                            }
                        } label: {
                            Label("保存到相册", systemImage: "square.and.arrow.down")
                        }
                    }
                VStack {
                    HStack(alignment: .center) {
                        Spacer()
                        Text(diffLabel.uppercased())
                            .foregroundColor(diffLabelColor)
                            .fontWeight(.bold)
                    }
                    .padding(.trailing)
                    Spacer()
                    HStack {
                        VStack(alignment: .leading) {
                            Text(title)
                                .font(.title)
                                .bold()
                                .lineLimit(2)
                                .minimumScaleFactor(0.8)
                                .contextMenu {
                                    Button {
                                        UIPasteboard.general.string = title
                                        alertToast.toast = AlertToast(displayMode: .hud, type: .complete(.green), title: "已复制到剪贴板")
                                    } label: {
                                        Text("复制")
                                    }
                                }
                            
                            Text(artist)
                                .font(.title2)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        Spacer()
                    }
                    .padding(.leading)
                }
            }
            .frame(height: 120)
            
            VStack {
                TabBarView(currentIndex: $currentTab.animation(.spring))
                
                TabView(selection: $currentTab) {
                    if let song = chuSong {
                        SongLeaderboardView(doneLoading: $doneLoadingLeaderboard, username: user.username, chuLeaderboard: chuLeaderboard)
                            .tag(0)
                        SongStatView(doneLoading: $doneLoadingStat, chuStat: chuStat, chuEntry: chuRecord, chuSong: song, diff: diff)
                            .tag(1)
                        if !(chuRecords?.isEmpty ?? false) {
                            SongEntryListView(user: user, chuRecords: chuRecords)
                                .tag(2)
                        } else {
                            SongEmptyEntryView()
                                .tag(2)
                        }
                    } else if let song = maiSong {
                        SongLeaderboardView(doneLoading: $doneLoadingLeaderboard, username: user.username, maiLeaderboard: maiLeaderboard)
                            .tag(0)
                        SongStatView(doneLoading: $doneLoadingStat, maiStat: maiStat, maiSong: song, diff: diff)
                            .tag(1)
                        if !(maiRecords?.isEmpty ?? false) {
                            SongEntryListView(user: user, maiRecords: maiRecords)
                                .tag(2)
                        } else {
                            SongEmptyEntryView()
                                .tag(2)
                        }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
        .onAppear {
            loadVar()
        }
        .navigationTitle("排行榜与统计数据")
    }
    
    func loadVar() {
        if let song = chuSong {
            Task {
                chuStat = await CFQStatsServer.fetchMusicStat(authToken: user.jwtToken, mode: 0, musicId: song.musicID, diffIndex: diff)
                doneLoadingStat = true
            }
            Task {
                chuLeaderboard = await CFQStatsServer.fetchChunithmLeaderboard(authToken: user.jwtToken, musicId: song.musicID, diffIndex: diff)
                doneLoadingLeaderboard = true
            }
            coverUrl = ChunithmDataGrabber.getSongCoverUrl(source: 0, musicId: String(song.musicID))
            title = song.title
            artist = song.artist
            diffLabel = chunithmLevelLabel[diff] ?? ""
            diffLabelColor = chunithmLevelColor[diff] ?? .systemsBackground
        } else if let song = maiSong {
            Task {
                maiLeaderboard = await CFQStatsServer.fetchMaimaiLeaderboard(authToken: user.jwtToken, musicId: song.musicId, type: song.type, diffIndex: diff)
                doneLoadingLeaderboard = true
            }
            Task {
                maiStat = await CFQStatsServer.fetchMusicStat(authToken: user.jwtToken, mode: 1, musicId: song.coverId, diffIndex: diff, type: song.type)
                doneLoadingStat = true
            }
            coverUrl = MaimaiDataGrabber.getSongCoverUrl(source: 1, coverId: song.coverId)
            title = song.title
            artist = song.basicInfo.artist
            diffLabel = maimaiLevelLabel[diff] ?? ""
            diffLabelColor = maimaiLevelColor[diff] ?? .systemsBackground
            // TODO: Add maimai stats fetcher
        }
    }
}
