//
//  LeaderboardView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2024/06/29.
//

import SwiftUI

struct LeaderboardView: View {
    @ObservedObject var user: CFQNUser
    
    @State private var currentIndex: Int = 0
    
    var body: some View {
        VStack {
            LeaderboardTabView(currentIndex: $currentIndex.animation(.spring))
                .padding(.bottom, 5)
            TabView(selection: $currentIndex) {
                if user.currentMode == 0 {
                    ChunithmRatingLeaderboardView(leaderboard: user.chunithm.custom.ratingLeaderboard)
                        .tag(0)
                    ChunithmTotalScoreLeaderboardView(leaderboard: user.chunithm.custom.totalScoreLeaderboard)
                        .tag(1)
                    ChunithmTotalPlayedLeaderboardView(leaderboard: user.chunithm.custom.totalPlayedLeaderboard)
                        .tag(2)
                } else {
                    MaimaiRatingLeaderboardView(leaderboard: user.maimai.custom.ratingLeaderboard)
                        .tag(0)
                    MaimaiTotalScoreLeaderboardView(leaderboard: user.maimai.custom.totalScoreLeaderboard)
                        .tag(1)
                    MaimaiTotalPlyedLeaderboardView(leaderboard: user.maimai.custom.totalPlayedLeaderboard)
                        .tag(2)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationTitle("排行榜")
        .navigationBarTitleDisplayMode(.inline)
    }
}
