//
//  TeamInfoPage.swift
//  chafenqi
//
//  Created by 刘易斯 on 2024/12/24.
//

import Foundation
import SwiftUI
import AlertToast
import Inject

struct TeamInfoPage: View {
    @ObserveInjection var inject
    
    @ObservedObject var team: CFQTeam
    @ObservedObject var user: CFQNUser
    
    @ObservedObject var alertToastModel = AlertToastModel.shared
    
    let items = [
        TabBarItem(title: "成员", unselectedIcon: "person.2", selectedIcon: "person.2.fill"),
        TabBarItem(title: "动态", unselectedIcon: "clock", selectedIcon: "clock.fill"),
        TabBarItem(title: "组曲挑战", unselectedIcon: "list.bullet.rectangle", selectedIcon: "list.bullet.rectangle.fill"),
        TabBarItem(title: "留言板", unselectedIcon: "message", selectedIcon: "message.fill")
    ]
    @Namespace var namespace
    
    @State private var leaderNickname: String = ""
    @State private var currentIndex: Int = 0
    
    @State private var showLeaveTeamConfirmDialog: Bool = false
    @State private var showHelpSheet: Bool = false
    
    @State private var navigateToSettings: Bool = false
    
    var body: some View {
        VStack {
            VStack(spacing: 10) {
                Text(team.current.info.displayName)
                    .bold()
                Divider()
                HStack(spacing: 10) {
                    TeamInfoCard(icon: "magnifyingglass", content: team.current.info.teamCode, subtitle: "团队代码")
                    TeamInfoCard(icon: "chart.bar.fill", content: "\(team.current.info.currentActivityPoints)", subtitle: "本月积分")
                }
                HStack(spacing: 10) {
                    TeamInfoCard(icon: "calendar.badge.clock", content: "\(team.current.info.activeDays())天", subtitle: "活动天数")
                    TeamInfoCard(icon: "person.crop.circle.fill", content: leaderNickname, subtitle: "队长")
                    TeamInfoCard(icon: "person.3.fill", content: "\(team.current.members.count)人", subtitle: "团队人数")
                }
                VStack {
                    Text("团队介绍")
                        .font(.caption)
                    ScrollView {
                        Text(team.current.info.remarks)
                            .font(.footnote)
                    }
                    .frame(maxHeight: 50)
                }
            }
            .padding([.horizontal, .top])
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
        .navigationTitle("团队信息")
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
                Menu {
                    Button {
                        showHelpSheet.toggle()
                    } label: {
                        Label("帮助", systemImage: "questionmark.circle")
                    }
                    if user.userId == team.current.info.leaderUserId {
                        Button {
                            navigateToSettings.toggle()
                        } label: {
                            Label("管理团队", systemImage: "gear")
                        }
                    } else {
                        Button(role: .destructive) {
                            showLeaveTeamConfirmDialog = true
                        } label: {
                            Label("退出团队...", systemImage: "person.crop.circle.badge.xmark")
                        }
                    }
                } label: {
                    Label("更多", systemImage: "ellipsis.circle")
                }
                .background(
                    NavigationLink(destination: TeamSettingsPage(team: team, user: user), isActive: $navigateToSettings) {
                        EmptyView()
                    }
                )
            }
            
        }
        .alert("退出团队", isPresented: $showLeaveTeamConfirmDialog) {
            Button("取消", role: .cancel) {}
            Button("确定", role:. destructive) {
                onLeaveTeam()
            }
        } message: {
            Text("确认要退出团队吗？该操作无法撤销。")
        }
        .sheet(isPresented: $showHelpSheet) {
            TeamInfoHelpView(showHelpSheet: $showHelpSheet)
        }
        .enableInjection()
    }
    
    func onLeaveTeam() {
        Task {
            let result = await CFQTeamServer.leaveTeam(authToken: user.jwtToken, game: user.currentMode, teamId: team.current.info.id)
            if result.isEmpty {
                alertToastModel.toast = AlertToast(displayMode: .hud, type: .complete(.green), title: "已退出团队")
                team.refresh(user: user)
            } else {
                alertToastModel.toast = AlertToast(displayMode: .hud, type: .error(.red), title: "退出失败", subTitle: result)
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

struct TeamInfoHelpView: View {
    @Binding var showHelpSheet: Bool
    
    var body: some View {
        VStack {
            Text("团队帮助")
                .font(.title)
            
            Spacer()
            
            VStack(spacing: 25) {
                IconWithInfoBlock(imageSystemName: "info.circle", title: "团队信息", message: "位于团队页面上方的团队信息区域，点击任意项目可以显示该项详细信息")
                IconWithInfoBlock(imageSystemName: "person.2", title: "成员列表", message: "显示当前团队成员信息，按照加入时间排序，点击任意成员可显示成员详细信息")
                IconWithInfoBlock(imageSystemName: "clock", title: "团队动态列表", message: "显示团队动态，包括成员变动，团队信息变动及组曲挑战变动等")
                IconWithInfoBlock(imageSystemName: "list.bullet.rectangle", title: "组曲挑战", message: "显示当前团队的组曲挑战，在1PC内按顺序连续游玩指定谱面后上传成绩，即可参与组曲挑战")
                IconWithInfoBlock(imageSystemName: "message", title: "留言板", message: "显示团队留言板，长按以管理自己的留言，队长可长按管理任意留言")
                IconWithInfoBlock(imageSystemName: "ellipsis", title: "更多", message: "当前团队人数上限为20人，团队在订阅会员过期后仍可正常使用，但无法变更团队内的成员")
            }
            
            Spacer()
            
            Button {
                showHelpSheet.toggle()
            } label: {
                Text("关闭")
            }
            .buttonStyle(.borderedProminent)
        }
        .enableInjection()
        .padding()
    }
}
