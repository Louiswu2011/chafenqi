//
//  TeamInfoPage.swift
//  chafenqi
//
//  Created by 刘易斯 on 2024/12/24.
//

import Foundation
import SwiftUI

struct TeamInfoPage: View {
    @ObservedObject var team: CFQTeam
    @ObservedObject var user: CFQNUser
    
    let items = [
        TabBarItem(title: "成员", unselectedIcon: "person.2", selectedIcon: "person.2.fill"),
        TabBarItem(title: "动态", unselectedIcon: "clock", selectedIcon: "clock.fill"),
        TabBarItem(title: "组曲挑战", unselectedIcon: "list.bullet.rectangle", selectedIcon: "list.bullet.rectangle.fill"),
        TabBarItem(title: "留言板", unselectedIcon: "message", selectedIcon: "message.fill")
    ]
    @Namespace var namespace
    
    @State private var leaderNickname: String = ""
    @State private var currentIndex: Int = 0
    
    var body: some View {
        VStack {
            VStack(spacing: 10) {
                Text(team.current.info.displayName)
                    .bold()
                Divider()
                HStack(spacing: 10) {
                    TeamInfoCard(icon: "magnifyingglass", content: team.current.info.teamCode, subtitle: "团队代码")
                    TeamInfoCard(icon: "calendar.badge.clock", content: "\(team.current.info.activeDays())天", subtitle: "活动天数")
                }
                HStack(spacing: 10) {
                    TeamInfoCard(icon: "chart.bar.fill", content: "\(team.current.info.currentActivityPoints)", subtitle: "本月积分")
                    TeamInfoCard(icon: "person.crop.circle.fill", content: leaderNickname, subtitle: "队长")
                    TeamInfoCard(icon: "person.3.fill", content: "\(team.current.members.count)人", subtitle: "团队人数")
                }
                VStack {
                    Text(team.current.info.remarks)
                    Text("团队介绍")
                        .font(.caption)
                }
            }
            .padding([.horizontal, .top])
            Divider()
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(Array(zip(items.indices, items)), id: \.0) { index, item in
                            TeamTabBarComponent(currentIndex: $currentIndex, proxy: proxy, namespace: namespace.self, index: index, title: item.title, unselectedIcon: item.unselectedIcon, selectedIcon: item.selectedIcon)
                        }
                    }
                }
                .onChange(of: currentIndex) { value in
                    withAnimation {
                        proxy.scrollTo(currentIndex)
                    }
                }
            }
            TabView(selection: $currentIndex) {
                TeamMemberView(team: team)
                    .tag(0)
                TeamActivityView(team: team)
                    .tag(1)
                TeamCourseView(team: team, user: user)
                    .tag(2)
                TeamBulletinView(team: team, user: user)
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationTitle("队伍信息")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if let leader = team.current.members.first(where: { $0.userId == team.current.info.leaderUserId }) {
                leaderNickname = leader.nickname.transformingHalfwidthFullwidth()
            } else {
                leaderNickname = "未知"
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    team.refresh(user: user)
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                if user.userId == team.current.info.leaderUserId {
                    NavigationLink {
                        TeamSettingsPage(team: team, user: user)
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
            
        }
    }
}

struct TeamInfoCard: View {
    var icon: String
    var content: String
    var subtitle: String
    
    @State private var expanded = false
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: icon)
                Text(content)
                    .bold()
                    .lineLimit(1)
            }
            if expanded {
                Text(subtitle)
                    .font(.caption)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .padding(.vertical, 2)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .shadow(radius: 2)
                .foregroundColor(.systemsBackground)
        )
        .onTapGesture {
            withAnimation {
                expanded.toggle()
            }
        }
    }
}

struct TeamTabBarComponent: View {
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var currentIndex: Int
    var proxy: ScrollViewProxy
    let namespace: Namespace.ID
    
    var index: Int
    var title: String
    var unselectedIcon: String
    var selectedIcon: String
    
    var body: some View {
        Button {
            withAnimation(.spring) {
                currentIndex = index
                proxy.scrollTo(index)
            }
        } label: {
            VStack {
                HStack {
                    Image(systemName: currentIndex == index ? selectedIcon : unselectedIcon)
                    Text(title)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                if currentIndex == index {
                    (colorScheme == .light ? Color.black : Color.white)
                        .frame(height: 2)
                        .matchedGeometryEffect(id: "underline", in: namespace, properties: .frame)
                } else {
                    Color.clear
                        .frame(height: 2)
                }
            }
            .animation(.spring, value: currentIndex)
        }
        .buttonStyle(.plain)
    }
}
