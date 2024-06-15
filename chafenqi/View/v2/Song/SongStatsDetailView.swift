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
                    SongLeaderboardView(doneLoading: $doneLoadingLeaderboard, username: user.username, chuLeaderboard: chuLeaderboard)
                        .tag(0)
                    SongStatView(doneLoading: $doneLoadingStat, chuStat: chuStat)
                        .tag(1)
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
        }
    }
}

struct SongLeaderboardView: View {
    @Binding var doneLoading: Bool
    var username: String
    
    // TODO: Add Maimai leaderboard
    var chuLeaderboard: CFQChunithmLeaderboard?
    
    var body: some View {
        if doneLoading {
            if let leaderboard = chuLeaderboard {
                ChunithmLeaderboardView(leaderboard: leaderboard, username: username)
            } else {
                Text("哎呀，还没有人游玩过该难度！")
            }
        } else {
            ProgressView()
        }
    }
}

struct SongStatView: View {
    @Binding var doneLoading: Bool
    
    // TODO: Add Maimai stat
    var chuStat: CFQChunithmMusicStatEntry?
    
    var body: some View {
        if doneLoading {
            if let entry = chuStat {
                ChunithmSongStatView(entry: entry)
            } else {
                Text("哎呀，还没有人游玩过该难度！")
            }
        } else {
            ProgressView()
        }
    }
}

struct ChunithmLeaderboardView: View {
    var leaderboard: CFQChunithmLeaderboard
    var username: String
    
    var body: some View {
        ZStack {
            ScrollView(.vertical) {
                LazyVStack(alignment: .center ,spacing: 20) {
                    ForEach(Array(zip(leaderboard.indices, leaderboard)), id: \.0) { index, item in
                        ChunithmLeaderboardItemView(index: index, item: item, shouldHighlight: item.username == self.username)
                    }
                }
            }
            .padding(.horizontal)
            
            let userEntry = leaderboard.first { predicate in
                predicate.username == self.username
            }
            let userIndex = leaderboard.firstIndex { predicate in
                predicate.username == self.username
            }
            if let entry = userEntry, let index = userIndex {
                VStack {
                    Spacer()
                    VStack {
                        Color.black
                            .frame(height: 2)
                        ChunithmLeaderboardItemView(index: index, item: entry, shouldHighlight: true)
                            .padding([.bottom, .leading, .trailing])
                            .padding(.top, 5)
                    }
                    .background(Color.systemsBackground)
                }
            }
        }
    }
}

struct ChunithmSongStatView: View {
    var entry: CFQChunithmMusicStatEntry
    
    let ranks = ["SSS+", "SSS", "SS+", "SS", "S+", "S", "其他"]
    
    var body: some View {
        VStack(alignment: .center) {
            HStack(alignment: .center) {
                Text("游玩人数：\(entry.totalPlayed)")
                Spacer()
                Text("平均分数：\(entry.totalScore / Double(entry.totalPlayed), specifier: "%.0f")")
            }
            
            HStack {
                let data = makeData()
                
                DoughnutChart(chartData: data)
                    .touchOverlay(chartData: data, specifier: "%.0f")
                    .headerBox(chartData: data)
                    .frame(idealWidth: 200, idealHeight: 200)
                    .id(data.id)
                    .padding(.horizontal)
                    .padding(.bottom)
                
                HStack {
                    VStack(alignment: .leading) {
                        let splits = [entry.ssspSplit, entry.sssSplit, entry.sspSplit, entry.ssSplit, entry.spSplit, entry.sSplit, entry.otherSplit]
                        ForEach(ranks, id: \.self) { rank in
                            let index = ranks.firstIndex(of: rank) ?? 0
                            Text("\(rank)")
                                .foregroundColor(chunithmRankColor[index] ?? Color.primary) +
                            Text("：") +
                            Text("\(splits[index])")
                        }
                    }
                    VStack(alignment: .trailing) {
                        Text("拟合定数")
                        Text("Coming soon")
                            .fontWeight(.bold)
                            .padding(.bottom)
                        
                        Text("最高分")
                        Text("\(entry.highestScore, specifier: "%.0f")")
                            .fontWeight(.bold)
                    }
                }
            }
            Spacer()
        }
        .padding()
    }
    
    func makeData() -> DoughnutChartData {
        let data = PieDataSet(dataPoints: [
            PieChartDataPoint(value: Double(entry.ssspSplit), description: "SSS+", colour: chunithmRankColor[0] ?? Color.accentColor),
            PieChartDataPoint(value: Double(entry.sssSplit), description: "SSS", colour: chunithmRankColor[1] ?? Color.accentColor),
            PieChartDataPoint(value: Double(entry.sspSplit), description: "SS+", colour: chunithmRankColor[2] ?? Color.accentColor),
            PieChartDataPoint(value: Double(entry.ssSplit), description: "SS", colour: chunithmRankColor[3] ?? Color.accentColor),
            PieChartDataPoint(value: Double(entry.spSplit), description: "S+", colour: chunithmRankColor[4] ?? Color.accentColor),
            PieChartDataPoint(value: Double(entry.sSplit), description: "S", colour: chunithmRankColor[5] ?? Color.accentColor),
            PieChartDataPoint(value: Double(entry.otherSplit), description: "其他", colour: chunithmRankColor[6] ?? Color.accentColor)
        ], legendTitle: "")
        
        return DoughnutChartData(
            dataSets: data,
            metadata: ChartMetadata(),
            noDataText: Text("暂无数据"))
    }
}

struct ChunithmLeaderboardItemView: View {
    var index: Int
    var item: CFQChunithmLeaderboardEntry
    var shouldHighlight: Bool
    
    var body: some View {
        HStack {
            if shouldHighlight {
                Text(verbatim: "#\(index + 1)")
                    .fontWeight(.bold)
                    .frame(width: 55)
                Text(item.nickname.transformingHalfwidthFullwidth())
                    .fontWeight(.bold)
                Spacer()
                
                HStack {
                    Text(verbatim: "\(item.highscore)")
                        .fontWeight(.bold)
                    if item.rankIndex > 7 {
                        GradeBadgeView(grade: chunithmRanks[13 - item.rankIndex])
                    }
                }
            } else {
                Text(verbatim: "#\(index + 1)")
                    .frame(width: 55)
                Text(item.nickname.transformingHalfwidthFullwidth())
                Spacer()
                
                HStack {
                    Text(verbatim: "\(item.highscore)")
                    if item.rankIndex > 7 {
                        GradeBadgeView(grade: chunithmRanks[13 - item.rankIndex])
                    }
                }
            }
        }
    }
}

struct TabBarItem {
    var title: String
    var unselectedIcon: String
    var selectedIcon: String
}

struct TabBarView: View {
    @Binding var currentIndex: Int
    @Namespace var namespace
    
    var items = [
        TabBarItem(title: "排行榜", unselectedIcon: "chart.bar", selectedIcon: "chart.bar.fill"),
        TabBarItem(title: "统计信息", unselectedIcon: "chart.pie", selectedIcon: "chart.pie.fill")
    ]
    
    var body: some View {
        HStack {
            ForEach(Array(zip(items.indices, items)), id: \.0) { index, item in
                TabBarComponent(currentIndex: $currentIndex, namespace: namespace.self, index: index, title: item.title, unselectedIcon: item.unselectedIcon, selectedIcon: item.selectedIcon)
            }
        }
        .frame(height: 60)
    }
}

struct TabBarComponent: View {
    @Binding var currentIndex: Int
    let namespace: Namespace.ID
    
    var index: Int
    var title: String
    var unselectedIcon: String
    var selectedIcon: String
    
    var body: some View {
        Button {
            currentIndex = index
        } label: {
            VStack {
                Spacer()
                HStack {
                    Image(systemName: currentIndex == index ? selectedIcon : unselectedIcon)
                    Text(title)
                }
                if currentIndex == index {
                    Color.black
                        .frame(height: 2)
                        .matchedGeometryEffect(id: "underline", in: namespace, properties: .frame)
                } else {
                    Color.clear
                        .frame(height: 2)
                }
            }
            .animation(.spring, value: currentIndex)
        }
        .buttonStyle(.plain)
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
