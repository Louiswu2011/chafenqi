//
//  HomeTeam.swift
//  chafenqi
//
//  Created by 刘易斯 on 2024/12/24.
//

import Foundation
import SwiftUI
import Inject

struct HomeTeam: View {
    @ObserveInjection var inject
    @ObservedObject var team: CFQTeam
    @ObservedObject var user: CFQNUser
    
    var body: some View {
        HStack {
            NavigationLink {
                TeamLandingPage(team: team, user: user)
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(user.currentMode == 0 ?
                              user.homeUseCurrentVersionTheme ? nameplateThemedChuniGradientStyle : nameplateDefaultChuniGradientStyle :
                                user.homeUseCurrentVersionTheme ? nameplateThemedMaiGradientStyle : nameplateDefaultMaiGradientStyle
                        )
                    Label(team.current.info.displayName.isEmpty ? "加入或创建团队" : team.current.info.displayName, systemImage: "person.3.fill")
                        .foregroundColor(.black)
                        .padding(5)
                }
            }
            NavigationLink {
                TeamLeaderboardPage(team: team, user: user)
            } label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(user.currentMode == 0 ?
                              user.homeUseCurrentVersionTheme ? nameplateThemedChuniGradientStyle : nameplateDefaultChuniGradientStyle :
                                user.homeUseCurrentVersionTheme ? nameplateThemedMaiGradientStyle : nameplateDefaultMaiGradientStyle
                        )
                    Label("团队排行榜", systemImage: "chart.bar.fill")
                        .foregroundColor(.black)
                        .padding(5)
                }
            }
        }
        .enableInjection()
        .padding(.horizontal)
        .lineLimit(1)
    }
}
