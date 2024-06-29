//
//  HomeLeaderboard.swift
//  chafenqi
//
//  Created by 刘易斯 on 2024/06/29.
//

import Foundation
import SwiftUI

struct HomeLeaderboard: View {
    @ObservedObject var user: CFQNUser
    
    @State private var rating = ""
    @State private var totalScore = ""
    @State private var totalPlayed = ""
    
    @State private var ratingRank = ""
    @State private var totalScoreRank = ""
    @State private var totalPlayedRank = ""
    
    var body: some View {
        VStack {
            HStack {
                Text("排行榜")
                    .font(.system(size: 20))
                    .bold()
                Spacer()
                
                NavigationLink {
                    LeaderboardView(user: user)
                } label: {
                    Text("显示全部")
                        .font(.system(size: 18))
                }
            }
            .padding(.bottom, 5)
            
            HStack {
                VStack(alignment: .leading) {
                    Text(ratingRank)
                        .font(.system(size: 17))
                        .bold()
                    Text(rating)
                        .font(.system(size: 15))
                    Text("Rating")
                        .font(.caption)
                }
                Spacer()
                VStack(alignment: .leading) {
                    Text(totalScoreRank)
                        .font(.system(size: 17))
                        .bold()
                    Text(totalScore)
                        .font(.system(size: 15))
                    Text("总分")
                        .font(.caption)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text(totalPlayedRank)
                        .font(.system(size: 17))
                        .bold()
                    Text(totalPlayed)
                        .font(.system(size: 15))
                    Text("游玩曲目数")
                        .font(.caption)
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
        .onAppear {
            loadVar()
        }
        .id(user.currentMode)
    }
    
    func loadVar() {
        if user.currentMode == 0 {
            // Chunithm
            let ratingLeaderboard = user.chunithm.custom.ratingLeaderboard
            let totalPlayedLeaderboard = user.chunithm.custom.totalPlayedLeaderboard
            let totalScoreLeaderboard = user.chunithm.custom.totalScoreLeaderboard
            
            let ratingIndex = ratingLeaderboard.firstIndex { entry in
                entry.username == user.username
            }
            if let ratingIndex = ratingIndex {
                let rankInfo = ratingLeaderboard[ratingIndex]
                rating = String(format: "%.2f", rankInfo.rating)
                ratingRank = "#\(ratingIndex)"
            }
            
            let totalPlayedIndex = totalPlayedLeaderboard.firstIndex { entry in
                entry.username == user.username
            }
            if let totalPlayedIndex = totalPlayedIndex {
                let playedInfo = totalPlayedLeaderboard[totalPlayedIndex]
                totalPlayed = String(playedInfo.totalPlayed)
                totalPlayedRank = "#\(totalPlayedIndex)"
            }
            
            let totalScoreIndex = totalScoreLeaderboard.firstIndex { entry in
                entry.username == user.username
            }
            if let totalScoreIndex = totalScoreIndex {
                let scoreInfo = totalScoreLeaderboard[totalScoreIndex]
                totalScore = String(scoreInfo.totalScore)
                totalScoreRank = "#\(totalScoreIndex)"
            }
        } else {
            // Maimai
            let ratingLeaderboard = user.maimai.custom.ratingLeaderboard
            let totalPlayedLeaderboard = user.maimai.custom.totalPlayedLeaderboard
            let totalScoreLeaderboard = user.maimai.custom.totalScoreLeaderboard
            
            let ratingIndex = ratingLeaderboard.firstIndex { entry in
                entry.username == user.username
            }
            if let ratingIndex = ratingIndex {
                let rankInfo = ratingLeaderboard[ratingIndex]
                rating = String(rankInfo.rating)
                ratingRank = "#\(ratingIndex)"
            }
            
            let totalPlayedIndex = totalPlayedLeaderboard.firstIndex { entry in
                entry.username == user.username
            }
            if let totalPlayedIndex = totalPlayedIndex {
                let playedInfo = totalPlayedLeaderboard[totalPlayedIndex]
                totalPlayed = String(playedInfo.totalPlayed)
                totalPlayedRank = "#\(totalPlayedIndex)"
            }
            
            let totalScoreIndex = totalScoreLeaderboard.firstIndex { entry in
                entry.username == user.username
            }
            if let totalScoreIndex = totalScoreIndex {
                let scoreInfo = totalScoreLeaderboard[totalScoreIndex]
                totalScore = String(format: "%.4f", scoreInfo.totalAchievements) + "%"
                totalScoreRank = "#\(totalScoreIndex)"
            }
        }
    }
}
