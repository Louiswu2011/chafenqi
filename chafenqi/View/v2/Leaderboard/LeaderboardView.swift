//
//  LeaderboardView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2024/06/29.
//

import SwiftUI

struct LeaderboardEntryData: Identifiable {
    var id = UUID()
    var index: Int
    var uid: Int
    var username: String
    var nickname: String
    var info: String
    var extraInfo: Any?
}

struct LeaderboardView: View {
    @ObservedObject var user: CFQNUser
    
    @State private var currentIndex: Int = 0
    
    @State private var chuRatingLeaderboard: ChunithmRatingLeaderboard = []
    @State private var chuTotalPlayedLeaderboard: ChunithmTotalPlayedLeaderboard = []
    @State private var chuTotalScoreLeaderboard: ChunithmTotalScoreLeaderboard = []
    @State private var chuFirstLeaderboard: ChunithmFirstLeaderboard = []
    
    @State private var maiRatingLeaderboard: MaimaiRatingLeaderboard = []
    @State private var maiTotalPlayedLeaderboard: MaimaiTotalPlayedLeaderboard = []
    @State private var maiTotalScoreLeaderboard: MaimaiTotalScoreLeaderboard = []
    @State private var maiFirstLeaderboard: MaimaiFirstLeaderboard = []
    
    @State private var ratingLeaderboardData: Array<LeaderboardEntryData> = []
    @State private var totalPlayedLeaderboardData: Array<LeaderboardEntryData> = []
    @State private var totalScoreLeaderboardData: Array<LeaderboardEntryData> = []
    @State private var firstLeaderboardData: Array<LeaderboardEntryData> = []
    
    @State private var doneLoadingChunithmRatingLeaderboard = false
    @State private var doneLoadingChunithmTotalPlayedLeaderboard = false
    @State private var doneLoadingChunithmTotalScoreLeaderboard = false
    @State private var doneLoadingChunithmFirstLeaderboard = false
    
    @State private var doneLoadingMaimaiRatingLeaderboard = false
    @State private var doneLoadingMaimaiTotalPlayedLeaderboard = false
    @State private var doneLoadingMaimaiTotalScoreLeaderboard = false
    @State private var doneLoadingMaimaiFirstLeaderboard = false
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                LeaderboardTabView(proxy: proxy, currentIndex: $currentIndex.animation(.spring))
                    .padding(.bottom, 5)
                    .onChange(of: currentIndex) { value in
                        withAnimation {
                            proxy.scrollTo(currentIndex)
                        }
                    }
            }
            TabView(selection: $currentIndex) {
                if user.currentMode == 0 {
                    LeaderboardScrollView(doneLoading: $doneLoadingChunithmRatingLeaderboard, data: $ratingLeaderboardData)
                        .tag(0)
                        .onChange(of: doneLoadingChunithmRatingLeaderboard) { value in
                            if value && !chuRatingLeaderboard.isEmpty {
                                ratingLeaderboardData = chuRatingLeaderboard.enumerated().map { (index, entry) in
                                    LeaderboardEntryData(index: index, uid: entry.uid, username: entry.username, nickname: entry.nickname, info: String(format: "%.2f", entry.rating))
                                }
                            }
                        }
                    LeaderboardScrollView(doneLoading: $doneLoadingChunithmTotalScoreLeaderboard, data: $totalScoreLeaderboardData)
                        .tag(1)
                        .onChange(of: doneLoadingChunithmTotalScoreLeaderboard) { value in
                            if value && !chuTotalScoreLeaderboard.isEmpty {
                                totalScoreLeaderboardData = chuTotalScoreLeaderboard.enumerated().map { (index, entry) in
                                    LeaderboardEntryData(index: index, uid: entry.uid, username: entry.username, nickname: entry.nickname, info: String(entry.totalScore))
                                }
                            }
                        }
                    LeaderboardScrollView(doneLoading: $doneLoadingChunithmTotalPlayedLeaderboard, data: $totalPlayedLeaderboardData)
                        .tag(2)
                        .onChange(of: doneLoadingChunithmTotalPlayedLeaderboard) { value in
                            if value && !chuTotalPlayedLeaderboard.isEmpty {
                                totalPlayedLeaderboardData = chuTotalPlayedLeaderboard.enumerated().map { (index, entry) in
                                    LeaderboardEntryData(index: index, uid: entry.uid, username: entry.username, nickname: entry.nickname, info: String(entry.totalPlayed))
                                }
                            }
                        }
                    LeaderboardScrollView(doneLoading: $doneLoadingChunithmFirstLeaderboard, data: $firstLeaderboardData)
                        .tag(3)
                        .onChange(of: doneLoadingChunithmFirstLeaderboard) { value in
                            if value && !chuFirstLeaderboard.isEmpty {
                                firstLeaderboardData = chuFirstLeaderboard.enumerated().map { (index, entry) in
                                    LeaderboardEntryData(index: index, uid: entry.uid, username: entry.username, nickname: entry.nickname, info: String(entry.firstCount), extraInfo: entry.firstMusics)
                                }
                            }
                        }
                } else if user.currentMode == 1 {
                    LeaderboardScrollView(doneLoading: $doneLoadingMaimaiRatingLeaderboard, data: $ratingLeaderboardData)
                        .tag(0)
                        .onChange(of: doneLoadingMaimaiRatingLeaderboard) { value in
                            if value && !maiRatingLeaderboard.isEmpty {
                                ratingLeaderboardData = maiRatingLeaderboard.enumerated().map { (index, entry) in
                                    LeaderboardEntryData(index: index, uid: entry.uid, username: entry.username, nickname: entry.nickname, info: String(entry.rating))
                                }
                            }
                        }
                    LeaderboardScrollView(doneLoading: $doneLoadingMaimaiTotalScoreLeaderboard, data: $totalScoreLeaderboardData)
                        .tag(1)
                        .onChange(of: doneLoadingMaimaiTotalScoreLeaderboard) { value in
                            if value && !maiTotalScoreLeaderboard.isEmpty {
                                totalScoreLeaderboardData = maiTotalScoreLeaderboard.enumerated().map { (index, entry) in
                                    LeaderboardEntryData(index: index, uid: entry.uid, username: entry.username, nickname: entry.nickname, info: String(format: "%.4f", entry.totalAchievements) + "%")
                                }
                            }
                        }
                    LeaderboardScrollView(doneLoading: $doneLoadingMaimaiTotalPlayedLeaderboard, data: $totalPlayedLeaderboardData)
                        .tag(2)
                        .onChange(of: doneLoadingMaimaiTotalPlayedLeaderboard) { value in
                            if !maiTotalPlayedLeaderboard.isEmpty {
                                totalPlayedLeaderboardData = maiTotalPlayedLeaderboard.enumerated().map { (index, entry) in
                                    LeaderboardEntryData(index: index, uid: entry.uid, username: entry.username, nickname: entry.nickname, info: String(entry.totalPlayed))
                                }
                            }
                        }
                    LeaderboardScrollView(doneLoading: $doneLoadingMaimaiFirstLeaderboard, data: $firstLeaderboardData)
                        .tag(3)
                        .onChange(of: doneLoadingMaimaiFirstLeaderboard) { value in
                            if value && !maiFirstLeaderboard.isEmpty {
                                firstLeaderboardData = maiFirstLeaderboard.enumerated().map { (index, entry) in
                                    LeaderboardEntryData(index: index, uid: entry.uid, username: entry.username, nickname: entry.nickname, info: String(entry.firstCount))
                                }
                            }
                        }
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationTitle("排行榜")
        .navigationBarTitleDisplayMode(.inline)
        .id(user.currentMode)
        .onAppear {
            loadVar()
        }
    }
    
    func loadVar() {
        if user.currentMode == 0 {
            // Chunithm
            Task {
                if !doneLoadingChunithmRatingLeaderboard {
                    await chuRatingLeaderboard = CFQStatsServer.fetchTotalLeaderboard(authToken: user.jwtToken, game: .Chunithm, type: ChunithmRatingLeaderboard.self) ?? []
                    doneLoadingChunithmRatingLeaderboard = true
                }
            }
            Task {
                if !doneLoadingChunithmTotalScoreLeaderboard {
                    await chuTotalScoreLeaderboard = CFQStatsServer.fetchTotalLeaderboard(authToken: user.jwtToken, game: .Chunithm, type: ChunithmTotalScoreLeaderboard.self) ?? []
                    doneLoadingChunithmTotalScoreLeaderboard = true
                }
            }
            Task {
                if !doneLoadingChunithmTotalPlayedLeaderboard {
                    await chuTotalPlayedLeaderboard = CFQStatsServer.fetchTotalLeaderboard(authToken: user.jwtToken, game: .Chunithm, type: ChunithmTotalPlayedLeaderboard.self) ?? []
                    doneLoadingChunithmTotalPlayedLeaderboard = true
                }
            }
            Task {
                if !doneLoadingChunithmFirstLeaderboard {
                    await chuFirstLeaderboard = CFQStatsServer.fetchTotalLeaderboard(authToken: user.jwtToken, game: .Chunithm, type: ChunithmFirstLeaderboard.self) ?? []
                    doneLoadingChunithmFirstLeaderboard = true
                }
            }
        } else if user.currentMode == 1 {
            // Maimai
            Task {
                if !doneLoadingMaimaiRatingLeaderboard {
                    maiRatingLeaderboard = await CFQStatsServer.fetchTotalLeaderboard(authToken: user.jwtToken, game: .Maimai, type: MaimaiRatingLeaderboard.self) ?? []
                    doneLoadingMaimaiRatingLeaderboard = true
                }
            }
            Task {
                if !doneLoadingMaimaiTotalScoreLeaderboard {
                    maiTotalScoreLeaderboard = await CFQStatsServer.fetchTotalLeaderboard(authToken: user.jwtToken, game: .Maimai, type: MaimaiTotalScoreLeaderboard.self) ?? []
                    doneLoadingMaimaiTotalScoreLeaderboard = true
                }
            }
            Task {
                if !doneLoadingMaimaiTotalPlayedLeaderboard {
                    maiTotalPlayedLeaderboard = await CFQStatsServer.fetchTotalLeaderboard(authToken: user.jwtToken, game: .Maimai, type: MaimaiTotalPlayedLeaderboard.self) ?? []
                    doneLoadingMaimaiTotalPlayedLeaderboard = true
                }
            }
            Task {
                if !doneLoadingMaimaiFirstLeaderboard {
                    maiFirstLeaderboard = await CFQStatsServer.fetchTotalLeaderboard(authToken: user.jwtToken, game: .Maimai, type: MaimaiFirstLeaderboard.self) ?? []
                    doneLoadingMaimaiFirstLeaderboard = true
                }
            }
        }
    }
}

struct LeaderboardScrollView: View {
    @Binding var doneLoading: Bool
    @Binding var data: Array<LeaderboardEntryData>
    
    var body: some View {
        ZStack {
            if !doneLoading {
                VStack {
                    ProgressView()
                        .padding(.bottom)
                    Text("加载数据中...")
                }
            } else {
                if !data.isEmpty && data[0].extraInfo != nil {
                    ScrollView(.vertical) {
                        LazyVStack(alignment: .center ,spacing: 20) {
                            ForEach(data) { item in
                                LeaderboardFirstEntryColumn(item: item)
                                    .padding(.horizontal)
                            }
                        }
                    }
                } else {
                    ScrollView(.vertical) {
                        LazyVStack(alignment: .center ,spacing: 20) {
                            ForEach(data) { item in
                                LeaderboardEntryColumn(item: item)
                                    .padding(.horizontal)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct LeaderboardEntryColumn: View {
    var item: LeaderboardEntryData
    
    var body: some View {
        HStack {
            Text(verbatim: "#\(item.index + 1)")
                .frame(width: 55)
            Text(item.nickname.transformingHalfwidthFullwidth())
            Spacer()
            
            HStack {
                Text(item.info)
            }
        }
    }
}

let maiShortenDiffs = ["B", "A", "E", "M", "R"]
let chuShortenDiffs = ["B", "A", "E", "M", "U"]
struct LeaderboardFirstEntryColumn: View {
    @State private var detailed = false
    var item: LeaderboardEntryData
    
    var body: some View {
        HStack {
            Text(verbatim: "#\(item.index + 1)")
                .frame(width: 55)
            Text(item.nickname.transformingHalfwidthFullwidth())
            Spacer()
            if let extraInfo = item.extraInfo {
                if let info = extraInfo as? Array<ChunithmFirstLeaderboardMusicEntry> {
                    if detailed {
                        HStack(alignment: .center) {
                            ForEach(Array(info.getFirstPerDifficulty().enumerated()), id: \.0) { (index, item) in
                                HStack(alignment: .center, spacing: 5) {
                                    Text(chuShortenDiffs[index])
                                        .bold()
                                        .foregroundColor(chunithmLevelColor[index] ?? .black)
                                    Text(verbatim: "\(item)")
                                }
                            }
                        }
                    } else {
                        Text(verbatim: "\(item.info)")
                    }
                } else if let info = extraInfo as? Array<MaimaiFirstLeaderboardMusicEntry> {
                    if detailed {
                        HStack(alignment: .center) {
                            ForEach(Array(info.getFirstPerDifficulty().enumerated()), id: \.0) { (index, item) in
                                HStack(alignment: .center, spacing: 5) {
                                    Text(maiShortenDiffs[index])
                                        .bold()
                                        .foregroundColor(maimaiLevelColor[index] ?? .black)
                                    Text(verbatim: "\(item)")
                                }
                            }
                        }
                    } else {
                        Text(verbatim: "\(item.info)")
                    }
                }
            }
        }
        .onTapGesture {
            withAnimation {
                detailed = !detailed
            }
        }
    }
}


