//
//  ContentView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/6.
//

import SwiftUI


struct MainView: View {
    @AppStorage("favList") var favList = "0;"
    @AppStorage("settingsCurrentMode") var mode = 0 // 0: Chunithm NEW, 1: maimaiDX
    
    @State private var searchText = ""
    @State private var searchSeletedItem = ""
    // @State private var shouldShowDetail = false
    // @State private var searchForBothGames = false
    @State private var showingLoginView = false
    
    var body: some View {
        TabView {
            NavigationView {
                if (mode == 0) {
                    HomeView()
                } else {
                    MaimaiHomeView()
                }
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("主页")
            }
            
            NavigationView {
                SongListView()
            }
            .tabItem {
                Image(systemName: "music.note.list")
                Text("歌曲")
            }
            
            NavigationView {
                ToolView()
            }
            .tabItem {
                Image(systemName: "shippingbox.fill")
                Text("工具")
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
