//
//  TeamLandingPage.swift
//  chafenqi
//
//  Created by 刘易斯 on 2024/12/24.
//

import Foundation
import SwiftUI

struct TeamLandingPage: View {
    @ObservedObject var user: CFQNUser
    
    @State private var isLoading = true
    @State private var currentTeam: Int? = nil
    @State private var teamInfo: TeamInfo? = nil
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView() {
                    Text("加载中...")
                }
            } else {
                if currentTeam != nil, let teamInfo = teamInfo {
                    TeamInfoPage(team: teamInfo)
                } else {
                    TeamIntroductionPage()
                }
            }
        }
        .onAppear {
            Task {
                isLoading = true
                currentTeam = await CFQTeamServer.fetchCurrentTeam(authToken: user.jwtToken, game: user.currentMode)
                if let currentTeam = currentTeam {
                    teamInfo = await CFQTeamServer.fetchTeamInfo(authToken: user.jwtToken, game: user.currentMode, teamId: currentTeam)
                }
                isLoading = false
            }
        }
    }
}
