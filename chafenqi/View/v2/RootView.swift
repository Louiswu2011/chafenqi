//
//  RootView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/5/7.
//

import SwiftUI

struct RootView: View {
    @ObservedObject var user: CFQNUser
    
    var body: some View {
        if (user.didLogin) {
            TabView {
                NavigationView {
                    HomeView(user: user)
                }
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("主页")
                }
                .tag(TabIdentifier.home)
                
                NavigationView {
                    UpdaterRootView(user: user)
                }
                .tabItem {
                    Image(systemName: "paperplane")
                    Text("传分")
                }
                
                NavigationView {
                    SongTopView(user: user)
                }
                .tabItem {
                    Image(systemName: "music.note.list")
                    Text("歌曲")
                }
            }
        } else {
            LoginView(user: user)
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(user: CFQNUser())
    }
}
