//
//  ContentView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/6.
//

import SwiftUI
import AlertToast

let maimaiLevelColor = [
    0: Color(red: 128, green: 216, blue: 98),
    1: Color(red: 242, green: 218, blue: 71),
    2: Color(red: 237, green: 127, blue: 132),
    3: Color(red: 176, green: 122, blue: 238),
    4: Color(red: 206, green: 164, blue: 251)
]

let chunithmLevelColor = [
    0: Color(red: 73, green: 166, blue: 137),
    1: Color(red: 237, green: 123, blue: 33),
    2: Color(red: 205, green: 85, blue: 77),
    3: Color(red: 171, green: 104, blue: 249),
    4: Color(red: 32, green: 32, blue: 32)
]

struct MainView: View {
    @AppStorage("favList") var favList = "0;"
    @AppStorage("settingsCurrentMode") var mode = 0 // 0: Chunithm NEW, 1: maimaiDX
    @AppStorage("firstTimeLaunch") var firstTime = true
    
    @ObservedObject var toastManager = AlertToastManager.shared
    
    @State private var searchText = ""
    @State private var searchSeletedItem = ""
    @State private var showingLoginView = false
    
    @State private var showingWelcome = false
    
    @Binding var currentTab: TabIdentifier
    
    var body: some View {
        TabView(selection: $currentTab) {
            NavigationView {
                HomeTopView()
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
            .tag(TabIdentifier.recent)
            
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
        }.sheet(isPresented: $showingWelcome) {
            if #available(iOS 15.0, *) {
                WelcomeTabView(isShowingWelcome: $showingWelcome)
                    .interactiveDismissDisabled(true)
            } else {
                WelcomeTabView(isShowingWelcome: $showingWelcome)
                    .presentation(isModal: true)
            }
        }
        .onAppear {
            if (firstTime) {
                showingWelcome.toggle()
                firstTime.toggle()
            }
        }
            
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(currentTab: .constant(.home))
    }
}
