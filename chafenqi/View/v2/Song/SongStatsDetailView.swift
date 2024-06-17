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
    
    var maiRecord: CFQMaimai.RecentScoreEntry?
    var chuRecord: CFQChunithm.RecentScoreEntry?
    
    var maiRecords: CFQMaimaiRecentScoreEntries?
    var chuRecords: CFQChunithmRecentScoreEntries?
    
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
    
    
    @State var chuStat = CFQChunithmMusicStatEntry()
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
                        SongStatView(doneLoading: $doneLoadingStat, chuStat: chuStat, chuSong: song, diff: diff)
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
                        SongStatView(doneLoading: $doneLoadingStat, maiSong: song, diff: diff)
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
                chuStat = await CFQStatsServer.fetchMusicStat(musicId: song.musicID, diffIndex: diff)
                doneLoadingStat = true
            }
            Task {
                chuLeaderboard = await CFQStatsServer.fetchChunithmLeaderboard(musicId: song.musicID, diffIndex: diff)
                doneLoadingLeaderboard = true
            }
            coverUrl = ChunithmDataGrabber.getSongCoverUrl(source: 0, musicId: String(song.musicID))
            title = song.title
            artist = song.artist
            diffLabel = chunithmLevelLabel[diff] ?? ""
            diffLabelColor = chunithmLevelColor[diff] ?? .systemsBackground
        } else if let song = maiSong {
            Task {
                maiLeaderboard = await CFQStatsServer.fetchMaimaiLeaderboard(musicId: Int(song.musicId) ?? 0, type: song.type.uppercased(), diffIndex: diff)
                doneLoadingLeaderboard = true
            }
            Task {
                doneLoadingStat = true
            }
            coverUrl = MaimaiDataGrabber.getSongCoverUrl(source: 1, coverId: getCoverNumber(id: song.musicId))
            title = song.title
            artist = song.basicInfo.artist
            diffLabel = maimaiLevelLabel[diff] ?? ""
            diffLabelColor = maimaiLevelColor[diff] ?? .systemsBackground
            // TODO: Add maimai stats fetcher
        }
    }
}

#Preview {
    ChunithmLeaderboardView(leaderboard: [
        CFQChunithmLeaderboardEntry(id: 1, nickname: "Player1", highscore: 1010000, rankIndex: 13, fullCombo: "alljustice"),
        CFQChunithmLeaderboardEntry(id: 2, nickname: "Player2", highscore: 1010000, rankIndex: 12, fullCombo: "fullcombo"),
        CFQChunithmLeaderboardEntry(id: 3, username: "Player3", nickname: "Player3", highscore: 1003400, rankIndex: 11, fullCombo: ""),
        CFQChunithmLeaderboardEntry(id: 4, nickname: "Player4", highscore: 998888, rankIndex: 10, fullCombo: ""),
        CFQChunithmLeaderboardEntry(id: 5, nickname: "Player5", highscore: 1010000, rankIndex: 9, fullCombo: ""),
        CFQChunithmLeaderboardEntry(id: 6, nickname: "Player6", highscore: 987768, rankIndex: 8, fullCombo: ""),
        CFQChunithmLeaderboardEntry(id: 7, nickname: "Player7", highscore: 970067, rankIndex: 7, fullCombo: ""),
        CFQChunithmLeaderboardEntry(id: 8, nickname: "Player8", highscore: 954466, rankIndex: 6, fullCombo: "")
    ], username: "Player3")
}
