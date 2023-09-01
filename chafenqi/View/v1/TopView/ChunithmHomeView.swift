//
//  HomeView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/8.
//

import SwiftUI
import AlertToast

enum LoadStatus {
    case error(errorText: String)
    case loading(hint: String)
    case complete, notLogin, loadFromCache, empty
}

struct ChunithmHomeView: View {
    @State private var isLoading = true
    
    @State private var showingSettings = false
    @State private var showingMaximumRating = false
    @State private var showingCompletionToast = false
    @State private var showingErrorToast = false
    
    @State private var status: LoadStatus = .loading(hint: "获取用户数据中...")
    
    @State private var userInfo = ChunithmUserData.shared
    @State private var b30 = ArraySlice<ScoreEntry>()
    
    @State private var previousToken = ""
    
    @State private var decodedLoadedSongs: Array<ChunithmSongData> = []
    
    @State private var totalChartCount = 0
    @State private var firstAppear = true
    
    @AppStorage("settingsChunithmCoverSource") var coverSource = 0
    @AppStorage("loadedChunithmSongs") var loadedSongs: Data = Data()
    @AppStorage("didChunithmSongListLoaded") var didSongListLoaded = false
    
    @AppStorage("chartIDMap") var mapData = Data()
    
    @AppStorage("userNickname") var accountNickname = ""
    @AppStorage("userAccountName") var accountName = ""
    @AppStorage("userToken") var token = ""
    @AppStorage("userChunithmInfoData") var userInfoData = Data()
    
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
                .navigationBarTitle("")
            case .loadFromCache:
                VStack {
                    ProgressView()
                    Text("加载缓存中...")
                        .padding()
                }
                .navigationBarTitle("")
            case .complete:
                ScrollView{
                    VStack {
                        HStack {
                            ZStack {
                                CutCircularProgressView(progress: showingMaximumRating ? 1 : userInfo.getRelativeR10Percentage(), lineWidth: 10, width: 70, color: ChafenqiColor.secondary)
                                
                                Text(showingMaximumRating ? "\(b30[0].rating, specifier: "%.2f")" : "\(userInfo.getAvgR10(), specifier: "%.2f")")
                                    .foregroundColor(ChafenqiColor.secondary)
                                    .textFieldStyle(.roundedBorder)
                                    .font(.title3)
                                
                                Text("R10")
                                    .padding(.top, 60)
                            }
                            .padding()
                            .padding(.top, 50)
                            
                            ZStack {
                                CutCircularProgressView(progress: showingMaximumRating ? 1 : userInfo.getRelativePercentage(), lineWidth: 14, width: 100, color: Color.red)
                                
                                Text(showingMaximumRating ? "\(userInfo.getMaximumRating(), specifier: "%.2f")" : "\(userInfo.rating, specifier: "%.2f")")
                                    .foregroundColor(Color.red)
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
                                CutCircularProgressView(progress: showingMaximumRating ? 1 : userInfo.getAvgB30() / 17.30, lineWidth: 10, width: 70, color: ChafenqiColor.auxilary)
                                
                                Text("\(userInfo.getAvgB30(), specifier: "%.2f")")
                                    .foregroundColor(ChafenqiColor.auxilary)
                                    .textFieldStyle(.roundedBorder)
                                    .font(.title3)
                                
                                Text("B30")
                                    .padding(.top, 60)
                            }
                            .padding()
                            .padding(.top, 50)
                        }
                        
                        // Basic Info
                        VStack {
                            Text("总游玩谱面：" + String(userInfo.records.best.count) + "/" + String(totalChartCount))
                        }
                        
                        // B30
                        HStack {
                            Text("B30")
                                .font(.title2)
                                .padding()
                            
                            Spacer()
                        }
                        
                        ScrollView(.horizontal) {
                            LazyHGrid(rows: rows, spacing: 5) {
                                ForEach(0..<b30.count) { i in
                                    NavigationLink {
                                        ChunithmDetailView(song: decodedLoadedSongs.filter{ $0.musicId == b30[i].musicId }[0])
                                    } label: {
                                        ChunithmMiniView(song: b30[i])
                                    }.buttonStyle(.plain)
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
                        }
                        
                        ScrollView(.horizontal) {
                            LazyHGrid(rows: rows, spacing: 5) {
                                ForEach(0..<userInfo.records.r10.count) { i in
                                    NavigationLink {
                                        ChunithmDetailView(song: decodedLoadedSongs.filter{ $0.musicId == userInfo.records.r10[i].musicId }[0])
                                    } label: {
                                        ChunithmMiniView(song: userInfo.records.r10[i])
                                    }.buttonStyle(.plain)
                                }
                            }
                        }
                        .frame(height: 210)
                        .padding(.horizontal)
                        
                        Button {
                            Task {
                                await refreshUserInfo()
                            }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                            Text("刷新缓存")
                        }.padding()
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
                .navigationBarTitle("")
            case .notLogin:
                VStack {
                    Text("未登录查分器，请前往设置登录")
                        .padding()
                }
                .navigationBarTitle("")
            case .empty:
                VStack {
                    Text("暂无游玩数据！")
                        .padding()
                    Button {
                        status = .loading(hint: "获取用户数据中...")
                        userInfoData = Data()
                        Task {
                            await loadUserInfo()
                        }
                    } label: {
                        Text("刷新")
                    }
                    
                }
                .navigationBarTitle("")
            }
            
        }
        .toast(isPresenting: $showingErrorToast, duration: 2, tapToDismiss: true) {
            AlertToast(displayMode: .alert, type: .error(.red), title: "发生错误")
        }
        .onAppear {
            if (mapData.isEmpty) { getChartIDMap() }
            
            if (!didLogin) {
                status = .notLogin
            } else {
                if (userInfoData.isEmpty) {
                    status = .loading(hint: "获取用户数据中...")
                } else {
                    if (!userInfo.isRecordDataEmpty()){
                        status = .loadFromCache
                    } else {
                        status = .loading(hint: "获取用户数据中...")
                    }
                }
                
                Task {
                    await loadUserInfo()
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    previousToken = token
                    showingSettings.toggle()
                }) {
                    Image(systemName: "gear")
                }.sheet(isPresented: $showingSettings) {
                    SettingsView()
                }
            }
        }
        .navigationTitle(!accountNickname.isEmpty ? "\(accountNickname)的个人资料" : "查分器NEW")
        .onChange(of: showingSettings) { value in
            if(!value) {
                if (didLogin){
                    Task {
                        if (token != previousToken) {
                            await refreshUserInfo()
                        }
                    }
                } else {
                    status = .notLogin
            }
            }
        }
    }

    func loadUserInfo() async {
        guard didLogin && !token.isEmpty else { return }
        
        switch status {
        case .loading:
            do {
                try await downloadUserData()
                
                status = .loading(hint: "加载数据中...")
                try prepareRecords()
                
                try await loadSongList()
                totalChartCount = getTotalChartCount()
                
                // For now
                try removeWEChart()
                
                if userInfo.isRecordDataEmpty() {
                    status = .empty
                } else {
                    status = .complete
                }
            } catch {
                break
            }
            
        case .loadFromCache:
            do {
                try prepareRecords()
                try await loadSongList()
                if (totalChartCount == 0) {
                    totalChartCount = getTotalChartCount()
                }
                
                status = .complete
            } catch {
                print(error)
                status = .error(errorText: error.localizedDescription)
            }
            
        case .complete, .error(errorText: _), .notLogin, .empty:
            break
        }
    }
    
    
    func loadSongList() async throws {
        if (loadedSongs.isEmpty) {
            didSongListLoaded = false
            do {
                try await loadedSongs = JSONEncoder().encode(ChunithmDataGrabber.getSongDataSetFromServer())
                didSongListLoaded.toggle()
                decodedLoadedSongs = try! JSONDecoder().decode(Array<ChunithmSongData>.self, from: loadedSongs)
            } catch {
                print(error)
                status = .error(errorText: "加载歌曲列表失败")
                showingErrorToast.toggle()
                throw CFQError.LoadingError
            }
        } else if(decodedLoadedSongs.isEmpty) {
            do {
                decodedLoadedSongs = try JSONDecoder().decode(Array<ChunithmSongData>.self, from: loadedSongs)
            } catch {
                print(error)
                status = .error(errorText: "解析歌曲列表失败")
                showingErrorToast.toggle()
                throw CFQError.LoadingError
            }
        } else {
            didSongListLoaded = true
        }
    }
    
    func downloadUserData() async throws {
        do {
            accountNickname = try await ChunithmDataGrabber.getUserNickname(username: accountName)
            userInfoData = try await ChunithmDataGrabber.getUserRecord(token: token)
        } catch {
            print(error)
            status = .error(errorText: "加载用户数据失败")
            throw CFQError.LoadingError
        }
    }
    
    func prepareRecords() throws {
        do {
            let decoder = JSONDecoder()
            userInfo = try decoder.decode(ChunithmUserData.self, from: userInfoData)
            userInfo.records.best.sort {
                $0.rating > $1.rating
            }
            let length = userInfo.records.best.count > 29 ? 30 : userInfo.records.best.count
            b30 = userInfo.records.best.prefix(upTo: length)
            
            if accountNickname == "" { accountNickname = accountName }
        } catch {
            print(error)
            status = .error(errorText: "解析用户数据失败")
            throw CFQError.LoadingError
        }
    }
    
    func refreshUserInfo() async {
        guard didLogin else {
            status = .notLogin
            return
        }
        
        status = .loading(hint: "获取用户数据中...")
        resetCache()
        
        await loadUserInfo()
    }
    
    func resetCache() {
        userInfoData = Data()
        loadedSongs = Data()
        totalChartCount = 0
        mapData = Data()
    }
    
    func removeWEChart() throws {
        do {
            var decoded = try JSONDecoder().decode(Array<ChunithmSongData>.self, from: loadedSongs)
            decoded = decoded.filter { $0.constant != [0.0, 0.0, 0.0, 0.0, 0.0, 0.0] && $0.constant != [0.0] }
            loadedSongs = try JSONEncoder().encode(decoded)
            decodedLoadedSongs = decoded
        } catch {
            print(error)
            status = .error(errorText: "加载歌曲列表失败")
            throw CFQError.LoadingError
        }
    }
    
    func getTotalChartCount() -> Int {
        var total = 0
        decodedLoadedSongs.forEach { song in
            total += song.charts.count
        }
        return total
    }
    
    func getChartIDMap() {
        guard mapData.isEmpty else { return }
        
        let path = Bundle.main.url(forResource: "IdMap", withExtension: "json")
        mapData = try! Data(contentsOf: path!)
    }
}



struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(currentTab: .constant(.home))
    }
}
