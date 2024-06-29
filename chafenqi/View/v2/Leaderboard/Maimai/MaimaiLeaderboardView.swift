//
//  RatingLeaderboardView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2024/06/29.
//

import Foundation
import SwiftUI

struct MaimaiRatingLeaderboardView: View {
    var leaderboard: MaimaiRatingLeaderboard
    
    var body: some View {
        if leaderboard.isEmpty {
            Text("暂无数据")
        } else {
            ZStack {
                ScrollView(.vertical) {
                    LazyVStack(alignment: .center ,spacing: 20) {
                        ForEach(Array(zip(leaderboard.indices, leaderboard)), id: \.0) { index, item in
                            MaimaiRatingLeaderboardEntryView(index: index, item: item)
                        }
                    }
                }
            }
        }
    }
}

struct MaimaiRatingLeaderboardEntryView: View {
    var index: Int
    var item: MaimaiRatingLeaderboardEntry
    
    var body: some View {
        HStack {
            Text(verbatim: "#\(index + 1)")
                .frame(width: 55)
            Text(item.nickname.transformingHalfwidthFullwidth())
            Spacer()
            
            HStack {
                Text(verbatim: "\(item.rating)")
            }
        }
        .padding(.horizontal)
    }
}

struct MaimaiTotalScoreLeaderboardView: View {
    var leaderboard: MaimaiTotalScoreLeaderboard
    
    var body: some View {
        if leaderboard.isEmpty {
            Text("暂无数据")
        } else {
            ZStack {
                ScrollView(.vertical) {
                    LazyVStack(alignment: .center ,spacing: 20) {
                        ForEach(Array(zip(leaderboard.indices, leaderboard)), id: \.0) { index, item in
                            MaimaiTotalScoreLeaderboardEntryView(index: index, item: item)
                        }
                    }
                }
            }
        }
    }
}

struct MaimaiTotalScoreLeaderboardEntryView: View {
    var index: Int
    var item: MaimaiTotalScoreLeaderboardEntry
    
    var body: some View {
        HStack {
            Text(verbatim: "#\(index + 1)")
                .frame(width: 55)
            Text(item.nickname.transformingHalfwidthFullwidth())
            Spacer()
            
            HStack {
                Text("\(item.totalAchievements, specifier: "%.4f")%")
            }
        }
        .padding(.horizontal)
    }
}

struct MaimaiTotalPlyedLeaderboardView: View {
    var leaderboard: MaimaiTotalPlayedLeaderboard
    
    var body: some View {
        if leaderboard.isEmpty {
            Text("暂无数据")
        } else {
            ZStack {
                ScrollView(.vertical) {
                    LazyVStack(alignment: .center ,spacing: 20) {
                        ForEach(Array(zip(leaderboard.indices, leaderboard)), id: \.0) { index, item in
                            MaimaiTotalPlayedLeaderboardEntryView(index: index, item: item)
                        }
                    }
                }
            }
        }
    }
}

struct MaimaiTotalPlayedLeaderboardEntryView: View {
    var index: Int
    var item: MaimaiTotalPlayedLeaderboardEntry
    
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
