//
//  ContentView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/6.
//

import SwiftUI


struct MainView: View {
    @State private var searchText = ""
    @State private var searchSeletedItem = ""
    // @State private var shouldShowDetail = false
    // @State private var searchForBothGames = false
    @State private var showingLoginView = false
    
    var body: some View {
        TabView {
            NavigationView {
                HomeView()
                    
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("主页")
            }
            
            
            NavigationView {
                RecentView()
            }
            .tabItem {
                Image(systemName: "clock")
                Text("记录")
            }
            
            NavigationView {
                SongListView(searchText: $searchText)
            }
            .searchable(text: $searchText, prompt: "输入歌曲名/作者...")
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .tabItem {
                Image(systemName: "music.note.list")
                Text("歌曲")
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
