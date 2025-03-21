//
//  SongLeaderboardView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2024/06/17.
//

import Foundation
import SwiftUI

struct SongLeaderboardView: View {
    @Binding var doneLoading: Bool
    var username: String
    
    var maiLeaderboard: CFQMaimaiLeaderboard?
    var chuLeaderboard: CFQChunithmLeaderboard?
    
    var body: some View {
        if doneLoading {
            if let leaderboard = chuLeaderboard {
                ChunithmLeaderboardView(leaderboard: leaderboard, username: username)
                    .analyticsScreen(name: "chunithm_leaderboard_screen")
            } else if let leaderboard = maiLeaderboard {
                MaimaiLeaderboardView(leaderboard: leaderboard, username: username)
                    .analyticsScreen(name: "maimai_leaderboard_screen")
            } else {
                Text("哎呀，还没有人游玩过该难度！")
            }
        } else {
            ProgressView()
        }
    }
}

struct MaimaiLeaderboardView: View {
    var leaderboard: CFQMaimaiLeaderboard
    var username: String
    
    var body: some View {
        ZStack {
            ScrollView(.vertical) {
                LazyVStack(alignment: .center ,spacing: 20) {
                    ForEach(Array(zip(leaderboard.indices, leaderboard)), id: \.0) { index, item in
                        MaimaiLeaderboardItemView(index: index, item: item, shouldHighlight: item.username == self.username)
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
                        Divider()
                        MaimaiLeaderboardItemView(index: index, item: entry, shouldHighlight: true)
                            .padding([.bottom, .leading, .trailing])
                            .padding(.top, 5)
                    }
                    .background(Color.systemsBackground)
                }
            }
        }
    }
}

struct MaimaiLeaderboardItemView: View {
    var index: Int
    var item: CFQMaimaiLeaderboardEntry
    var shouldHighlight: Bool
    
    var body: some View {
        let displayName = item.nickname.isEmpty ? item.username : item.nickname
        
        HStack {
            if shouldHighlight {
                Text(verbatim: "#\(index + 1)")
                    .fontWeight(.bold)
                    .frame(width: 55)
                Text(displayName.transformingHalfwidthFullwidth())
                    .fontWeight(.bold)
                Spacer()
                
                HStack {
                    Text("\(item.achievements, specifier: "%.4f")%")
                        .fontWeight(.bold)
                    GradeBadgeView(grade: item.rateString)
                }
            } else {
                Text(verbatim: "#\(index + 1)")
                    .frame(width: 55)
                Text(displayName.transformingHalfwidthFullwidth())
                Spacer()
                
                HStack {
                    Text("\(item.achievements, specifier: "%.4f")%")
                    GradeBadgeView(grade: item.rateString)
                }
            }
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
                        Divider()
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

struct ChunithmLeaderboardItemView: View {
    var index: Int
    var item: CFQChunithmLeaderboardEntry
    var shouldHighlight: Bool
    
    var body: some View {
        let displayName = item.nickname.isEmpty ? item.username : item.nickname
        
        HStack {
            if shouldHighlight {
                Text(verbatim: "#\(index + 1)")
                    .fontWeight(.bold)
                    .frame(width: 55)
                Text(displayName.transformingHalfwidthFullwidth())
                    .fontWeight(.bold)
                Spacer()
                
                HStack {
                    Text(verbatim: "\(item.score)")
                        .fontWeight(.bold)
                    if item.rankIndex > 7 {
                        GradeBadgeView(grade: chunithmRanks[13 - item.rankIndex])
                    }
                }
            } else {
                Text(verbatim: "#\(index + 1)")
                    .frame(width: 55)
                Text(displayName.transformingHalfwidthFullwidth())
                Spacer()
                
                HStack {
                    Text(verbatim: "\(item.score)")
                    if item.rankIndex > 7 {
                        GradeBadgeView(grade: chunithmRanks[13 - item.rankIndex])
                    }
                }
            }
        }
    }
}
