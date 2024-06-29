//
//  LeaderboardTabView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2024/06/29.
//

import SwiftUI

struct LeaderboardTabView: View {
    @Binding var currentIndex: Int
    @Namespace var namespace
    
    let items = [
        TabBarItem(title: "Rating", unselectedIcon: "chart.bar", selectedIcon: "chart.bar.fill"),
        TabBarItem(title: "总分", unselectedIcon: "chart.bar.doc.horizontal", selectedIcon: "chart.bar.doc.horizontal.fill"),
        TabBarItem(title: "游玩曲目数", unselectedIcon: "chart.pie", selectedIcon: "chart.pie.fill"),
        TabBarItem(title: "榜一取得数", unselectedIcon: "1.circle", selectedIcon: "1.circle.fill")
    ]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(Array(zip(items.indices, items)), id: \.0) { index, item in
                    LeaderboardTabBarComponent(currentIndex: $currentIndex, namespace: namespace.self, index: index, title: item.title, unselectedIcon: item.unselectedIcon, selectedIcon: item.selectedIcon)
                }
            }
        }
        .frame(height: 60)
    }
}

struct LeaderboardTabBarComponent: View {
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var currentIndex: Int
    let namespace: Namespace.ID
    
    var index: Int
    var title: String
    var unselectedIcon: String
    var selectedIcon: String
    
    var body: some View {
        Button {
            withAnimation(.spring) {
                currentIndex = index
            }
        } label: {
            VStack {
                Spacer()
                HStack {
                    Image(systemName: currentIndex == index ? selectedIcon : unselectedIcon)
                    Text(title)
                }
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
            .padding(.horizontal)
        }
        .buttonStyle(.plain)
    }
}
