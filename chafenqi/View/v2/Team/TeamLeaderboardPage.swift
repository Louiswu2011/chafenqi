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
    
    var body: some View {
        List {
            ForEach(team.list, id: \.id) { team in
                
            }
        }
        .enableInjection()
        .navigationTitle("团队排行榜")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            team.refresh(user: user)
        }
    }
}
