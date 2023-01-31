//
//  HomeView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/8.
//

import SwiftUI
import RefreshableScrollView
import AlertToast

enum LoadStatus {
    case error(errorText: String)
    case loading(hint: String)
    case complete, empty, loadFromCache
}

struct HomeView: View {
    @State private var isLoading = true
    
    @State private var showingSettings = false
    @State private var showingMaximumRating = false
    @State private var showingCompletionToast = false
    
    @State private var status: LoadStatus = .loading(hint: "获取用户数据中...")
    
    @State private var userInfo = UserData()
    @State private var b30 = ArraySlice<ScoreEntry>()
    
    @AppStorage("settingsCoverSource") var coverSource = "Github"
    
    @AppStorage("userNickname") var accountNickname = ""
    @AppStorage("userAccountName") var accountName = ""
    @AppStorage("userToken") var token = ""
    @AppStorage("userInfoData") var userInfoData = Data()
    
    @AppStorage("didLogin") var didLogin = false
    
    private var rows = [
        GridItem(),
        GridItem()
    ]
    
    var body: some View {
        ZStack {
            switch status {
            case .loading(let hint):
                VStack {
                    ProgressView()
                    Text(hint)
                        .padding()
                }
            case .loadFromCache:
                VStack {
                    ProgressView()
                    Text("加载缓存中...")
                        .padding()
                }
            case .complete:
                ScrollView{
                    VStack {
                        HStack {
                            ZStack {
                                CutCircularProgressView(progress: showingMaximumRating ? 1 : userInfo.getRelativeR10Percentage(), lineWidth: 10, width: 70, color: Color.indigo)
                                
                                Text(showingMaximumRating ? "\(b30[0].rating, specifier: "%.2f")" : "\(userInfo.getAvgR10(), specifier: "%.2f")")
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
                                
                                Text("\(userInfo.getAvgB30(), specifier: "%.2f")")
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
                                    SongMiniInfoView(song: b30[i])
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
                        
                        
                        Text("封面来源：\(coverSource)")
                            .padding()
                    }
                    
                }
                
                
                
            case let .error(text):
                VStack {
                    Text(text)
                        .padding()
                    Button {
                        status = .loading(hint: "获取用户数据中...")
                        userInfoData = Data()
                        Task {
                            await loadUserInfo()
                        }
                    } label: {
                        Text("重试")
                    }
                    
                }
            case .empty:
                VStack {
                    Text("未登录查分器，请前往设置登录")
                        .padding()
                }
            }
            
        }
        .task {
            if (!didLogin) {
                status = .empty
            } else {
                if (userInfoData.isEmpty) {
                    status = .loading(hint: "获取用户数据中...")
                } else {
                    status = .loadFromCache
                }
                
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
                    SettingsView(coverSource: coverSource, showingSettings: $showingSettings)
                }
            }
        }
        .navigationTitle(!accountNickname.isEmpty ? "\(accountNickname)的个人资料" : "查分器NEW")
        .onChange(of: showingSettings) { value in
            if(!value) {
                Task {
                    await refreshUserInfo()
                }
            }
        }
    }
    
    func refreshUserInfo() async {
        guard didLogin else {
            status = .empty
            return
        }
        
        status = .loading(hint: "获取用户数据中...")
        userInfoData = Data()
        await loadUserInfo()
    }
    
    func loadUserInfo() async {
        guard didLogin && !token.isEmpty else { return }
        
        let decoder = JSONDecoder()
        
        switch status {
        case .loading:
            do {
                accountNickname = try await ProbeDataGrabber.getUserNickname(username: accountName)
                userInfoData = try await ProbeDataGrabber.getUserRecord(token: token)
                
                status = .loading(hint: "加载数据中...")
                userInfo = try decoder.decode(UserData.self, from: userInfoData)
                userInfo.records.best.sort {
                    $0.rating > $1.rating
                }
                b30 = userInfo.records.best.prefix(upTo: 30)
                
                status = .complete
            } catch {
                print(error)
                status = .error(errorText: error.localizedDescription)
            }
            
        case .loadFromCache:
            do {
                userInfo = try decoder.decode(UserData.self, from: userInfoData)
                userInfo.records.best.sort {
                    $0.rating > $1.rating
                }
                b30 = userInfo.records.best.prefix(upTo: 30)
                status = .complete
            } catch {
                print(error)
                status = .error(errorText: error.localizedDescription)
            }

        case .complete, .error(errorText: _), .empty:
            break
        }
    }
}



struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
