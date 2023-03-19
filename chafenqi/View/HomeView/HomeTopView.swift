//
//  HomeTopView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/3/9.
//

import SwiftUI

struct HomeTopView: View {
    @AppStorage("userToken") var token = ""
    @AppStorage("userMaimaiCache") var maimaiCache = Data()
    @AppStorage("userChunithmCache") var chunithmCache = Data()
    
    @ObservedObject var user = CFQUser.loadFromCache()
    
    @State private var loadStatus: LoadStatus = .loading(hint: "加载中...")
    
    var body: some View {
        Group {
            if (user.didLogin) {
                switch (loadStatus) {
                case .complete:
                    ScrollView {
                        NamePlateView(user: user)
                        
                        Group {
                            HStack {
                                Text("最近动态")
                                    .font(.system(size: 20))
                                    .bold()
                                Spacer()
                                
                                NavigationLink {
                                    RecentView()
                                } label: {
                                    Text("显示全部")
                                        .font(.system(size: 18))
                                }
                            }
                            .padding(.horizontal)
                            
                            
                            HStack {
                                
                            }
                            .padding([.horizontal, .bottom])
                            
                            
                        }
                        
                        Group {
                            HStack {
                                Text("Rating分析")
                                    .font(.system(size: 20))
                                    .bold()
                                Spacer()
                                
                                NavigationLink {
                                    RatingDetailView(user: user)
                                } label: {
                                    Text("显示详情")
                                        .font(.system(size: 18))
                                }
                            }
                            .padding(.horizontal)
                            
                            VStack {
                                
                            }
                            .padding([.horizontal, .bottom])
                        }
                        
                        Group {
                            HStack {
                                Text("实力分析")
                                    .font(.system(size: 20))
                                    .bold()
                                Spacer()
                                
                            }
                            .padding(.horizontal)
                            
                            VStack {
                                
                            }
                            .padding([.horizontal, .bottom])
                        }
                    }
                case .loading:
                    VStack {
                        ProgressView()
                            .padding()
                        Text("加载中")
                    }
                case .notLogin:
                    Text("未登录，请在设置中登录账号")
                default:
                    Text("未登录，请在设置中登录账号")
                }
            } else {
                Text("未登录，请在设置中登录账号")
            }
        }
        .onAppear {
            loadStatus = .loading(hint: "加载中...")
            Task {
                do {
                    if (user.didLogin) {
                        if (user.shouldReload) {
                            try await user.loadFromToken(token: token)
                        } else {
                            if (user.data.shouldReload) {
                                user.data = try await CFQPersistentData.loadFromCacheOrRefresh()
                            }
                        }
                        
                        loadStatus = .complete
                    } else {
                        loadStatus = .notLogin
                    }
                } catch {
                    loadStatus = .error(errorText: "ERROR")
                }
            }
        }
        .navigationTitle("主页")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    SettingsView(user: user)
                } label: {
                    Image(systemName: "gear")
                }
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    Task {
                        do {
                            loadStatus = .loading(hint: "加载中")
                            try await user.refresh()
                            
                            loadStatus = .complete
                        } catch {
                            loadStatus = .error(errorText: "ERROR")
                        }
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
    }
}

struct HomeTopView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(currentTab: .constant(.home))
    }
}
