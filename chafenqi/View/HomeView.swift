//
//  HomeView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/8.
//

import SwiftUI

enum LoadStatus {
    case error(errorText: String)
    case loading, complete
}

struct HomeView: View {
    @State private var isLoading = true
    
    @State private var showingSettings = false
    @State private var showingMaximumRating = false
    
    @State private var status: LoadStatus = .loading
    
    @State private var userInfo: UserScoreData = UserScoreData()
    
    @SceneStorage("userInfoData") var userInfoData: Data = Data()
    
    @AppStorage("settingsCoverSource") var coverSource = ""
    @AppStorage("userAccountId") var accountId = ""
    @AppStorage("userAccountName") var accountName = ""
    
    private var rows = [
        GridItem(),
        GridItem()
    ]
    
    var body: some View {
        ZStack {
            switch status {
            case .loading:
                VStack {
                    ProgressView()
                    Text("载入数据中...")
                        .padding()
                }
            case .complete:
                ScrollView(.vertical) {
                    VStack {
                        HStack {
                            ZStack {
                                CutCircularProgressView(progress: showingMaximumRating ? 1 : userInfo.getRelativeR10Percentage(), lineWidth: 10, width: 70, color: Color.indigo)
                                
                                Text("\(userInfo.getAvgR10(), specifier: "%.2f")")
                                    .foregroundColor(Color.indigo)
                                    .textFieldStyle(.roundedBorder)
                                    .font(.title3)
                                
                                Text("R10")
                                    .padding(.top, 60)
                            }
                            .padding()
                            .padding(.top, 50)
                            
                            ZStack {
                                CutCircularProgressView(progress: showingMaximumRating ? 1 : userInfo.getRelativePercentage(), lineWidth: 14, width: 100, color: Color.pink)
                                
                                Text(showingMaximumRating ? "\(userInfo.getMaximumRating(), specifier: "%.2f")" : "\(userInfo.rating, specifier: "%.2f")")
                                    .foregroundColor(Color.pink)
                                    .textFieldStyle(.roundedBorder)
                                    .font(.title)
                                    .transition(.opacity)
                                
                                Text(showingMaximumRating ? "MAX" : "Rating")
                                    .padding(.top, 70)
                            }
                            .padding()
                            .onTapGesture {
                                showingMaximumRating.toggle()
                            }
                            
                            ZStack {
                                // TODO: get max
                                CutCircularProgressView(progress: showingMaximumRating ? 1 : userInfo.getAvgB30() / 17.30, lineWidth: 10, width: 70, color: Color.cyan)
                                
                                Text(showingMaximumRating ? "17.30" : "\(userInfo.getAvgB30(), specifier: "%.2f")")
                                    .foregroundColor(Color.cyan)
                                    .textFieldStyle(.roundedBorder)
                                    .font(.title3)
                                
                                Text("B30")
                                    .padding(.top, 60)
                            }
                            .padding()
                            .padding(.top, 50)
                        }
                        
                        // B30
                        HStack {
                            Text("B30")
                                .font(.title2)
                                .padding()
                            
                            Spacer()
                            
                            Button {
                                
                            } label: {
                                Image(systemName: "arrow.right")
                            }
                            .padding()
                        }
                        
                        ScrollView(.horizontal) {
                            LazyHGrid(rows: rows, spacing: 5) {
                                ForEach(0..<30) { i in
                                    SongMiniInfoView(song: userInfo.records.b30[i])
                                        // .padding(5)
                                }
                            }
                        }
                        .frame(height: 210)
                        .padding(.horizontal)
                        
                        // R10
                        HStack {
                            Text("R10")
                                .font(.title2)
                                .padding()
                            
                            Spacer()
                            
                            Button {
                                
                            } label: {
                                Image(systemName: "arrow.right")
                            }
                            .padding()
                        }
                        
                        ScrollView(.horizontal) {
                            LazyHGrid(rows: rows, spacing: 5) {
                                ForEach(0..<10) { i in
                                    SongMiniInfoView(song: userInfo.records.r10[i])
                                        // .padding(5)
                                }
                            }
                        }
                        .frame(height: 210)
                        .padding(.horizontal)
                        
                        
                        Text("目前封面来源：\(coverSource)")
                            .padding()
                        
                        Button {
                            status = .loading
                            userInfoData = Data()
                            Task {
                                await loadUserInfo()
                            }
                        } label: {
                            Text("刷新")
                        }
                    }
                }
                .refreshable {
                    await refreshUserInfo()
                }
                
                
            case let .error(text):
                VStack {
                    Text(text)
                        .padding()
                    Button {
                        status = .loading
                        userInfoData = Data()
                        Task {
                            await loadUserInfo()
                        }
                    } label: {
                        Text("重试")
                    }
                    
                }
            }
        }
        .task {
            if (accountId.isEmpty && accountName.isEmpty) {
                showingSettings.toggle()
            } else {
                await loadUserInfo()
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingSettings.toggle()
                }) {
                    Image(systemName: "gear")
                }.sheet(isPresented: $showingSettings) {
                    SettingsView(coverSource: coverSource)
                }
            }
        }
        .navigationTitle("\(userInfo.nickname)的个人资料")
        .onChange(of: showingSettings) { value in
            if(!value) {
                Task {
                    await refreshUserInfo()
                }
            }
        }
    }
    
    func refreshUserInfo() async {
        status = .loading
        userInfoData = Data()
        await loadUserInfo()
    }
    
    func loadUserInfo() async {
        // guard userInfoData.isEmpty else { return }
        
        switch status {
        case .loading:
            do {
                try await userInfoData =  JSONEncoder().encode(accountId != "" ? ProbeDataGrabber.getUserInfo(id: accountId) : ProbeDataGrabber.getUserInfo(username: accountName))
                userInfo = try! JSONDecoder().decode(UserScoreData.self, from: userInfoData)
                status = .complete
            } catch CFQError.invalidResponseError(response: _) {
                status = .error(errorText: "用户不存在")
            } catch {
                status = .error(errorText: "网络连接超时")
            }
        case .complete:
            break
        case .error(errorText: _):
            break
        }
    }
}



struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
