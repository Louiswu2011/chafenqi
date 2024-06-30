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
    
    @State private var doneLoadingMaimai = false
    @State private var doneLoadingChunithm = false
    
    @State private var rating = ""
    @State private var totalScore = ""
    @State private var totalPlayed = ""
    @State private var first = ""
    
    @State private var ratingRank = ""
    @State private var totalScoreRank = ""
    @State private var totalPlayedRank = ""
    @State private var firstRank = ""
    
    var body: some View {
        VStack {
            HStack {
                Text("排行榜")
                    .font(.system(size: 20))
                    .bold()
                Spacer()
                
                NavigationLink {
                    if (user.isPremium) {
                        LeaderboardView(user: user)
                    } else {
                        NotPremiumView()
                    }
                } label: {
                    Text("显示全部")
                        .font(.system(size: 18))
                }
            }
            .padding(.bottom, 5)
            
            HStack {
                if (user.currentMode == 0 && doneLoadingChunithm) || (user.currentMode == 1 && doneLoadingMaimai) {
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
                    VStack(alignment: .trailing) {
                        Text(firstRank)
                            .font(.system(size: 17))
                            .bold()
                        Text(first)
                            .font(.system(size: 15))
                        Text("榜一取得数")
                            .font(.caption)
                    }
                } else {
                    ProgressView()
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
        Task {
            if user.currentMode == 0 {
                // Chunithm
                if !doneLoadingChunithm {
                    user.chunithm.custom.ratingRank = await CFQUserServer.fetchLeaderboardRank(authToken: user.jwtToken, type: ChunithmRatingRank.self) ?? ChunithmRatingRank()
                    user.chunithm.custom.totalPlayedRank = await CFQUserServer.fetchLeaderboardRank(authToken: user.jwtToken, type: ChunithmTotalPlayedRank.self) ?? ChunithmTotalPlayedRank()
                    user.chunithm.custom.totalScoreRank = await CFQUserServer.fetchLeaderboardRank(authToken: user.jwtToken, type: ChunithmTotalScoreRank.self) ?? ChunithmTotalScoreRank()
                    user.chunithm.custom.firstRank = await CFQUserServer.fetchLeaderboardRank(authToken: user.jwtToken, type: ChunithmFirstRank.self) ?? ChunithmFirstRank()
                    doneLoadingChunithm = true
                }
                self.ratingRank = "#\(user.chunithm.custom.ratingRank.rank)"
                self.totalPlayedRank = "#\(user.chunithm.custom.totalPlayedRank.rank)"
                self.totalScoreRank = "#\(user.chunithm.custom.totalScoreRank.rank)"
                self.firstRank = "#\(user.chunithm.custom.firstRank.rank)"
                self.rating = String(format: "%.2f", user.chunithm.custom.ratingRank.rating)
                self.totalPlayed = "\(user.chunithm.custom.totalPlayedRank.totalPlayed)"
                self.totalScore = "\(user.chunithm.custom.totalScoreRank.totalScore)"
                self.first = "\(user.chunithm.custom.firstRank.firstCount)"
            } else if user.currentMode == 1 {
                // Maimai
                if !doneLoadingMaimai {
                    user.maimai.custom.ratingRank = await CFQUserServer.fetchLeaderboardRank(authToken: user.jwtToken, type: MaimaiRatingRank.self) ?? MaimaiRatingRank()
                    user.maimai.custom.totalPlayedRank = await CFQUserServer.fetchLeaderboardRank(authToken: user.jwtToken, type: MaimaiTotalPlayedRank.self) ?? MaimaiTotalPlayedRank()
                    user.maimai.custom.totalScoreRank = await CFQUserServer.fetchLeaderboardRank(authToken: user.jwtToken, type: MaimaiTotalScoreRank.self) ?? MaimaiTotalScoreRank()
                    user.maimai.custom.firstRank = await CFQUserServer.fetchLeaderboardRank(authToken: user.jwtToken, type: MaimaiFirstRank.self) ?? MaimaiFirstRank()
                    doneLoadingMaimai = true
                }
                self.ratingRank = "#\(user.maimai.custom.ratingRank.rank)"
                self.totalPlayedRank = "#\(user.maimai.custom.totalPlayedRank.rank)"
                self.totalScoreRank = "#\(user.maimai.custom.totalScoreRank.rank)"
                self.firstRank = "#\(user.maimai.custom.firstRank.rank)"
                self.rating = "\(user.maimai.custom.ratingRank.rating)"
                self.totalPlayed = "\(user.maimai.custom.totalPlayedRank.totalPlayed)"
                self.totalScore = String(format: "%.4f", user.maimai.custom.totalScoreRank.totalAchievements) + "%"
                self.first = "\(user.maimai.custom.firstRank.firstCount)"
            }
        }
    }
}
