//
//  TeamInfoPage.swift
//  chafenqi
//
//  Created by 刘易斯 on 2024/12/24.
//

import Foundation
import SwiftUI

struct TeamInfoPage: View {
    var team: TeamInfo
    
    @State private var leaderNickname: String = ""
    
    var body: some View {
        VStack {
            Text(team.info.displayName)
                .bold()
            Divider()
            HStack {
                TeamInfoCard(icon: "magnifyingglass", content: team.info.teamCode, subtitle: "团队代码")
                TeamInfoCard(icon: "calendar.badge.clock", content: "\(team.info.activeDays())", subtitle: "活动天数")
            }
            HStack {
                TeamInfoCard(icon: "chart.bar.fill", content: "\(team.info.currentActivityPoints)", subtitle: "本月积分")
                TeamInfoCard(icon: "person.crop.circle.fill", content: leaderNickname, subtitle: "队长")
                TeamInfoCard(icon: "person.3.fill", content: "\(team.members.count)人", subtitle: "团队人数")
            }
            Text(team.info.remarks)
            Divider()
        }
        .navigationTitle("队伍信息")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let leader = leader() {
                leaderNickname = leader.nickname.transformingHalfwidthFullwidth()
            } else {
                leaderNickname = "未知"
            }
        }
    }
    
    func leader() -> TeamMember? {
        return team.members.first {
            $0.userId == team.info.leaderUserId
        }
    }
}

struct TeamInfoCard: View {
    var icon: String
    var content: String
    var subtitle: String
    
    @State private var expanded = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .shadow(radius: 2)
            
            VStack {
                HStack {
                    Image(systemName: icon)
                    Text(content)
                        .bold()
                }
                if expanded {
                    Text(subtitle)
                }
            }
        }
        .onTapGesture {
            withAnimation {
                expanded.toggle()
            }
        }
    }
}
