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
    
    @ObservedObject var user: CFQUser
    
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
                                    RecentView(user: user)
                                } label: {
                                    Text("显示全部")
                                        .font(.system(size: 18))
                                }
                                .disabled(user.currentMode == 0 ? user.chunithm == nil : user.maimai == nil)
                            }
                            .padding(.horizontal)
                            
                            
                            HStack {
                                if ((user.currentMode == 1 && user.maimai == nil) || (user.currentMode == 0 && user.chunithm == nil)) {
                                    Text("暂无数据")
                                        .padding()
                                } else {
                                    RecentSpotlightView(user: user)
                                }
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
                                    Text("显示全部")
                                        .font(.system(size: 18)) 
                                }
                                .disabled(user.currentMode == 0 ? user.chunithm == nil : user.maimai == nil)
                            }
                            .padding(.horizontal)
                            
                            ScrollView(.horizontal) {
                                if(user.currentMode == 1 && user.maimai != nil) {
                                    RatingAnalysisView(user: user)
                                }
                            }
                            .padding()
                        }
                        
                        Group {
                            HStack {
                                Text("好友动态")
                                    .font(.system(size: 20))
                                    .bold()
                                Spacer()
                                
                            }
                            .padding(.horizontal)
                            
                            VStack {
                                Text("敬请期待")
                                    .padding(.top)
                            }
                            .padding([.horizontal, .bottom])
                        }
                    }
                case .loading(let prompt):
                    VStack {
                        ProgressView()
                            .padding()
                        Text(prompt)
                    }
                case .notLogin:
                    Text("未登录，请在设置中登录账号")
                case .error(let errorText):
                    VStack {
                        Text(errorText)
                        Button {
                            Task {
                                do {
                                    loadStatus = .loading(hint: "加载中")
                                    try await user.refresh()
                                    
                                    loadStatus = .complete
                                } catch {
                                    loadStatus = .error(errorText: "哎呀，出错了")
                                }
                            }
                        } label: {
                            Text("重试")
                        }
                    }
                default:
                    Text("未登录，请在设置中登录账号")
                }
            } else {
                Text("未登录，请在设置中登录账号")
            }
        }
        .onAppear {
            if (user.didLogin) {
                loadStatus = .complete
            } else {
                loadStatus = .notLogin
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
                        await refreshByUser()
                    }
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
        .onOpenURL { url in
            if let action = url.action {
                switch action {
                case .refresh:
                    // Refresh user info
                    Task {
                        await refreshByUser()
                    }
                }
            }
        }
    }
    
    func refreshByUser() async {
        do {
            loadStatus = .loading(hint: "加载中")
            try await user.refresh()
            
            loadStatus = .complete
        } catch {
            loadStatus = .error(errorText: "哎呀，出错了")
        }
    }
}

struct HomeTopView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(user: .loadFromCache(), currentTab: .constant(.home))
    }
}
