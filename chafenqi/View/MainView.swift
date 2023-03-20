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

enum LoadStatus {
    case loading(hint: String)
    case error(errorText: String)
    case complete, notLogin, empty
}

struct MainView: View {
    @AppStorage("favList") var favList = "0;"
    @AppStorage("settingsCurrentMode") var mode = 0 // 0: Chunithm NEW, 1: maimaiDX
    @AppStorage("firstTimeLaunch") var firstTime = true
    
    @ObservedObject var toastManager = AlertToastManager.shared
    @ObservedObject var user = CFQUser.loadFromCache()
    
    @State private var searchText = ""
    @State private var searchSeletedItem = ""
    @State private var showingLoginView = false
    
    @State private var showingWelcome = false
    
    @State private var status: LoadStatus = .loading(hint: "加载数据中...")
    
    @Binding var currentTab: TabIdentifier
    
    var body: some View {
        ZStack {
            if(user.didLogin) {
                ZStack {
                    switch (status) {
                    case .loading(hint: let hint):
                        VStack {
                            ProgressView()
                            Text(hint)
                                .padding()
                        }
                    case .complete:
                        TabView(selection: $currentTab) {
                            NavigationView {
                                HomeTopView(user: user)
                            }
                            .tabItem {
                                Image(systemName: "house.fill")
                                Text("主页")
                            }
                            .tag(TabIdentifier.home)
                            
                            //            NavigationView {
                            //                RecentView()
                            //            }
                            //            .tabItem {
                            //                Image(systemName: "clock")
                            //                Text("最近")
                            //            }
                            //            .tag(TabIdentifier.recent)
                            
                            NavigationView {
                                SongListView(user: user)
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
                    case .notLogin:
                        NavigationView {
                            NavigationLink {
                                SettingsView(user: user)
                            } label: {
                                Text("点击此处登录查分器")
                            }
                        }
                    case .error(errorText: let errorText):
                        VStack {
                            Text("错误")
                                .padding()
                            Text(errorText)
                        }
                    default:
                        VStack {
                            Text("加载出错")
                                .padding()
                            Button {
                                
                            } label: {
                                Text("重试")
                            }
                        }
                    }
                }
                .onAppear {
                    if (firstTime) {
                        showingWelcome.toggle()
                        firstTime.toggle()
                    }
                    
                    Task {
                        do {
                            if (user.didLogin) {
                                try await user.loadFromToken(token: user.token)
                                if (user.data.shouldReload) {
                                    user.data = try await CFQPersistentData.loadFromCacheOrRefresh()
                                }
                                status = .complete
                            } else {
                                status = .notLogin
                            }
                        } catch {
                            status = .error(errorText: error.localizedDescription)
                        }
                    }
                }
            } else {
                NavigationView {
                    NavigationLink {
                        SettingsView(user: user)
                    } label: {
                        Text("点击此处登录查分器")
                    }
                }
            }
        }
        .sheet(isPresented: $showingWelcome) {
            if #available(iOS 15.0, *) {
                WelcomeTabView(isShowingWelcome: $showingWelcome)
                    .interactiveDismissDisabled(true)
            } else {
                WelcomeTabView(isShowingWelcome: $showingWelcome)
                    .presentation(isModal: true)
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(currentTab: .constant(.home))
    }
}
