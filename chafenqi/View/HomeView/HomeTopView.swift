//
//  HomeTopView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/3/9.
//

import SwiftUI

struct HomeTopView: View {
    @AppStorage("userToken") var token = ""
    
    @ObservedObject var data = CFQPersistentData()
    @ObservedObject var user = CFQUser()
    
    @State private var loadStatus: LoadStatus = .loading(hint: "加载中...")
    
    var body: some View {
        Group {
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
                                // TODO: Navigate to RatingDetailView
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
            default:
                Text("loading...")
            }
        }
        .onAppear {
            Task {
                do {
                    try await data.update()
                    await user.loadFromToken(token: token, data: data)
                    
                    loadStatus = .complete
                } catch {
                    loadStatus = .error(errorText: "ERROR")
                }
            }
        }
        .navigationTitle("主页")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    SettingsView(showingSettings: .constant(true))
                } label: {
                    Image(systemName: "gear")
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
