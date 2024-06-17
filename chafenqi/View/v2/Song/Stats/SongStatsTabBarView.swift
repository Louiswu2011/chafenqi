//
//  SongStatsTabBarView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2024/06/17.
//

import Foundation
import SwiftUI

struct TabBarItem {
    var title: String
    var unselectedIcon: String
    var selectedIcon: String
}

struct TabBarView: View {
    @Binding var currentIndex: Int
    @Namespace var namespace
    
    var items = [
        TabBarItem(title: "排行榜", unselectedIcon: "chart.bar", selectedIcon: "chart.bar.fill"),
        TabBarItem(title: "统计信息", unselectedIcon: "chart.pie", selectedIcon: "chart.pie.fill"),
        TabBarItem(title: "游玩记录", unselectedIcon: "clock", selectedIcon: "clock.fill")
    ]
    
    var body: some View {
        HStack {
            ForEach(Array(zip(items.indices, items)), id: \.0) { index, item in
                TabBarComponent(currentIndex: $currentIndex, namespace: namespace.self, index: index, title: item.title, unselectedIcon: item.unselectedIcon, selectedIcon: item.selectedIcon)
            }
        }
        .padding(.horizontal)
        .frame(height: 60)
    }
}

struct TabBarComponent: View {
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
        }
        .buttonStyle(.plain)
    }
}
