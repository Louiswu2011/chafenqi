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
    @State private var status: LoadStatus = .loading
    @State private var userInfo: UserScoreData = UserScoreData()
    
    @SceneStorage("userInfoData") var userInfoData: Data = Data()
    
    @AppStorage("settingsCoverSource") var coverSource = "Github"
    @AppStorage("userAccountId") var accountId = ""
    @AppStorage("userAccountName") var accountName = ""
    
    
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
                                CutCircularProgressView(progress: 0.7, lineWidth: 10, width: 70, color: Color.indigo)
                                
                                Text("16.85")
                                    .foregroundColor(Color.indigo)
                                    .textFieldStyle(.roundedBorder)
                                    .font(.title3)
                                
                                Text("R10")
                                    .padding(.top, 60)
                            }
                            .padding()
                            .padding(.top, 50)
                            
                            ZStack {
                                CutCircularProgressView(progress: 0.8, lineWidth: 14, width: 100, color: Color.pink)
                                
                                Text("\(userInfo.rating, specifier: "%.2f")")
                                    .foregroundColor(Color.pink)
                                    .textFieldStyle(.roundedBorder)
                                    .font(.title)
                                
                                Text("Rating")
                                    .padding(.top, 70)
                            }
                            .padding()
                            
                            ZStack {
                                CutCircularProgressView(progress: 0.4, lineWidth: 10, width: 70, color: Color.cyan)
                                
                                Text("16.04")
                                    .foregroundColor(Color.cyan)
                                    .textFieldStyle(.roundedBorder)
                                    .font(.title3)
                                
                                Text("B40")
                                    .padding(.top, 60)
                            }
                            .padding()
                            .padding(.top, 50)
                        }
                        
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
        .navigationTitle("主页")
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
        guard userInfoData.isEmpty else { return }
        
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
