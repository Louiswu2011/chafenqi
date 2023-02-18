//
//  ContentView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/6.
//

import SwiftUI
import AlertToast

let maimaiLevelColor = [
    0: Color(red: 128 / 255, green: 216 / 255, blue: 98 / 255),
    1: Color(red: 242 / 255, green: 218 / 255, blue: 71 / 255),
    2: Color(red: 237 / 255, green: 127 / 255, blue: 132 / 255),
    3: Color(red: 176 / 255, green: 122 / 255, blue: 238 / 255),
    4: Color(red: 206 / 255, green: 164 / 255, blue: 251 / 255)
]

let chunithmLevelColor = [
    0: Color(red: 73 / 255, green: 166 / 255, blue: 137 / 255),
    1: Color(red: 237 / 255, green: 123 / 255, blue: 33 / 255),
    2: Color(red: 205 / 255, green: 85 / 255, blue: 77 / 255),
    3: Color(red: 171 / 255, green: 104 / 255, blue: 249 / 255),
    4: Color(red: 32 / 255, green: 32 / 255, blue: 32 / 255)
]

struct MainView: View {
    @AppStorage("favList") var favList = "0;"
    @AppStorage("settingsCurrentMode") var mode = 0 // 0: Chunithm NEW, 1: maimaiDX
    
    @ObservedObject var toastManager = AlertToastManager.shared
    
    @State private var searchText = ""
    @State private var searchSeletedItem = ""
    @State private var showingLoginView = false
    
    @State private var showingPastedToast = false
    
    @Binding var currentTab: TabIdentifier
    
    var body: some View {
        TabView(selection: $currentTab) {
            NavigationView {
                if (mode == 0) {
                    ChunithmHomeView()
                } else {
                    MaimaiHomeView()
                }
            }
            .tabItem {
                Image(systemName: "house.fill")
                Text("主页")
            }
            .tag(TabIdentifier.home)
            
            NavigationView {
                RecentView()
            }
            .tabItem {
                Image(systemName: "clock")
                Text("最近")
            }
            
            NavigationView {
                SongListView()
            }
            .tabItem {
                Image(systemName: "music.note.list")
                Text("歌曲")
            }
            .tag(TabIdentifier.list)
            
            NavigationView {
                ToolView()
            }
            .tabItem {
                Image(systemName: "shippingbox.fill")
                Text("工具")
            }
            .tag(TabIdentifier.tool)
            .toast(isPresenting: $toastManager.showingUpdaterPasted, duration: 2, tapToDismiss: true) {
                AlertToast(displayMode: .hud, type: .complete(.green), title: "已复制到剪贴板")
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(currentTab: .constant(.home))
    }
}
