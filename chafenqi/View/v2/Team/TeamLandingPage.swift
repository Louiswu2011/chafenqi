//
//  TeamLandingPage.swift
//  chafenqi
//
//  Created by 刘易斯 on 2024/12/24.
//

import Foundation
import SwiftUI

struct TeamLandingPage: View {
    @ObservedObject var team: CFQTeam
    @ObservedObject var user: CFQNUser
    
    var body: some View {
        VStack {
            if team.isLoading {
                ProgressView() {
                    Text("加载中...")
                }
            } else {
                if team.currentTeamId != nil, team.current.info.displayName != "" {
                    TeamInfoPage(team: team, user: user)
                } else {
                    TeamIntroductionPage(team: team, user: user)
                }
            }
        }
        .onAppear {
            team.refresh(user: user)
        }
    }
}
