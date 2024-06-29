//
//  ChunithmLeaderboardView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2024/06/29.
//

import SwiftUI

struct ChunithmRatingLeaderboardView: View {
    var leaderboard: ChunithmRatingLeaderboard
    
    var body: some View {
        if leaderboard.isEmpty {
            Text("暂无数据")
        } else {
            ZStack {
                ScrollView(.vertical) {
                    LazyVStack(alignment: .center ,spacing: 20) {
                        ForEach(Array(zip(leaderboard.indices, leaderboard)), id: \.0) { index, item in
                            ChunithmRatingLeaderboardEntryView(index: index, item: item)
                        }
                    }
                }
            }
        }
    }
}

struct ChunithmRatingLeaderboardEntryView: View {
    var index: Int
    var item: ChunithmRatingLeaderboardEntry
    
    var body: some View {
        HStack {
            Text(verbatim: "#\(index + 1)")
                .frame(width: 55)
            Text(item.nickname.transformingHalfwidthFullwidth())
            Spacer()
            
            HStack {
                Text("\(item.rating, specifier: "%.2f")")
            }
        }
        .padding(.horizontal)
    }
}

struct ChunithmTotalScoreLeaderboardView: View {
    var leaderboard: ChunithmTotalScoreLeaderboard
    
    var body: some View {
        if leaderboard.isEmpty {
            Text("暂无数据")
        } else {
            ZStack {
                ScrollView(.vertical) {
                    LazyVStack(alignment: .center ,spacing: 20) {
                        ForEach(Array(zip(leaderboard.indices, leaderboard)), id: \.0) { index, item in
                            ChunithmTotalScoreLeaderboardEntryView(index: index, item: item)
                        }
                    }
                }
            }
        }
    }
}

struct ChunithmTotalScoreLeaderboardEntryView: View {
    var index: Int
    var item: ChunithmTotalScoreLeaderboardEntry
    
    var body: some View {
        HStack {
            Text(verbatim: "#\(index + 1)")
                .frame(width: 55)
            Text(item.nickname.transformingHalfwidthFullwidth())
            Spacer()
            
            HStack {
                Text("\(item.totalScore)")
            }
        }
        .padding(.horizontal)
    }
}

struct ChunithmTotalPlayedLeaderboardView: View {
    var leaderboard: ChunithmTotalPlayedLeaderboard
    
    var body: some View {
        if leaderboard.isEmpty {
            Text("暂无数据")
        } else {
            ZStack {
                ScrollView(.vertical) {
                    LazyVStack(alignment: .center ,spacing: 20) {
                        ForEach(Array(zip(leaderboard.indices, leaderboard)), id: \.0) { index, item in
                            ChunithmTotalPlayedLeaderboardEntryView(index: index, item: item)
                        }
                    }
                }
            }
        }
    }
}

struct ChunithmTotalPlayedLeaderboardEntryView: View {
    var index: Int
    var item: ChunithmTotalPlayedLeaderboardEntry
    
    var body: some View {
        HStack {
            Text(verbatim: "#\(index + 1)")
                .frame(width: 55)
            Text(item.nickname.transformingHalfwidthFullwidth())
            Spacer()
            
            HStack {
                Text("\(item.totalPlayed)")
            }
        }
        .padding(.horizontal)
    }
}
