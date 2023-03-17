//
//  HomeTopView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/3/9.
//

import SwiftUI

struct HomeTopView: View {
    @AppStorage("userChunithmInfoData") var userInfoData = Data()
    @AppStorage("userToken") var token = ""
    
    @State private var loadStatus: LoadStatus = .loading(hint: "加载中...")
    
    @State private var chunithmUserData = ChunithmUserData.shared
    
    @State private var overpower = 0.0
    
    var body: some View {
        Group {
            switch (loadStatus) {
            case .complete:
                ScrollView {
                    NamePlateView()
                    
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
                                    .font(.system(size: 20))
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
                                
                            } label: {
                                Text("显示详情")
                                    .font(.system(size: 20))
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
                    
                    Text("Overpower: \(overpower, specifier: "%.2f")")
                        .padding()
                }
            case .loading:
                Text("loading...")
            default:
                Text("loading...")
            }
        }
        .onAppear {
            Task {
                do {
                    userInfoData = try await ChunithmDataGrabber.getUserRecord(token: token)
                    chunithmUserData = try JSONDecoder().decode(ChunithmUserData.self, from: userInfoData)
                    overpower = chunithmUserData.getOverpower()
                    
                    loadStatus = .complete
                } catch {
                    
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
