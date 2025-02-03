//
//  CFQTeam.swift
//  chafenqi
//
//  Created by 刘易斯 on 2024/12/25.
//

import Foundation

class CFQTeam: ObservableObject {
    @Published var isLoading: Bool = false
    
    @Published var currentTeamId: Int? = nil
    @Published var current: TeamInfo = TeamInfo.empty
    
    @Published var list: [TeamBasicInfo] = []
    @Published var sortedList: [TeamBasicInfo] = []
    
    func refresh(user: CFQNUser) {
        Task {
            let currentTeamId = await CFQTeamServer.fetchCurrentTeam(authToken: user.jwtToken, game: user.currentMode)
            let allTeams = await fetchAllTeams(token: user.jwtToken, mode: user.currentMode)
            if let currentTeamId = currentTeamId {
                let currentTeam = await CFQTeamServer.fetchTeamInfo(authToken: user.jwtToken, game: user.currentMode, teamId: currentTeamId)
                if let currentTeam = currentTeam {
                    DispatchQueue.main.async {
                        self.currentTeamId = currentTeamId
                        self.current = currentTeam
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.current = TeamInfo.empty
                }
            }
            DispatchQueue.main.async {
                self.list = allTeams
                self.sortedList = allTeams.sorted { $0.currentActivityPoints > $1.currentActivityPoints }
                self.isLoading = false
            }
        }
    }
    
    func fetchAllTeams(token: String, mode: Int) async -> [TeamBasicInfo] {
        return await CFQTeamServer.fetchAllTeamInfos(authToken: token, game: mode)
    }
}
