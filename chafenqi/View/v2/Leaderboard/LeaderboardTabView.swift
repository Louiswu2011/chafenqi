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
        TabBarItem(title: "游玩曲目数", unselectedIcon: "chart.pie", selectedIcon: "chart.pie.fill")
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
