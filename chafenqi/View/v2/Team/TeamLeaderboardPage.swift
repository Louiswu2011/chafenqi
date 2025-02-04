//
//  TeamLeaderboardPage.swift
//  chafenqi
//
//  Created by Louis Wu on 2025/01/03.
//

import Foundation
import SwiftUI
import Inject

struct TeamLeaderboardPage: View {
    @ObserveInjection var inject
    
    @ObservedObject var team: CFQTeam
    @ObservedObject var user: CFQNUser
    
    let currentDate = Date.now
    
    var body: some View {
        let dateComponents = Calendar(identifier: .gregorian).dateComponents([.year, .month], from: currentDate)
        let start = DateTool.shared.yyyymmddTransformer.string(from: Date().startOfMonth)
        let end = DateTool.shared.yyyymmddTransformer.string(from: Date().endOfMonth)
        VStack {
            if team.isLoading {
                ProgressView()
            } else {
                VStack {
                    Text(verbatim: "\(dateComponents.year ?? 2025) 第\(dateComponents.month ?? 1)赛季")
                        .bold()
                    Text("\(start) ~ \(end)")
                        .font(.footnote)
                }
                Divider()
                ScrollView {
                    LazyVStack {
                        ForEach(Array(zip(team.sortedList.indices, team.sortedList)), id: \.0) { index, team in
                            TeamLeaderboardEntry(team: team, rank: index + 1)
                        }
                    }
                }
            }
        }
        .enableInjection()
        .navigationTitle("团队排行榜")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation {
                        team.refresh(user: user)
                    }
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                }
            }
        }
    }
}

struct TeamLeaderboardEntry: View {
    let team: TeamBasicInfo
    let rank: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("#\(rank)")
                    .if(rank <= 3) { text in
                        text.bold()
                    }
                    .if(rank == 1) { text in
                        text.foregroundColor(leaderboardGoldColor)
                    }
                    .if(rank == 2) { text in
                        text.foregroundColor(leaderboardSilverColor)
                    }
                    .if(rank == 3) { text in
                        text.foregroundColor(leaderboardBronzeColor)
                    }
                Text(team.displayName)
                    .if(rank <= 3) { text in
                        text.bold()
                    }
                    .lineLimit(1)
                Spacer()
                Text(team.currentActivityPoints > 0 ? "\(team.currentActivityPoints)Pt" : "暂未参加")
            }
            Text("\(team.remarks)")
                .font(.footnote)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
}
