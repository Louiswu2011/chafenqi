//
//  MaimaiHomeView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/3.
//

import SwiftUI
import AlertToast

struct MaimaiHomeView: View {
    @AppStorage("settingsChunithmCoverSource") var coverSource = 0
    @AppStorage("loadedMaimaiChartStats") var loadedStats: Data = Data()
    @AppStorage("loadedMaimaiSongs") var loadedSongs: Data = Data()
    @AppStorage("loadedMaimaiRanking") var loadedRanking: Data = Data()
    
    @AppStorage("userNickname") var accountNickname = ""
    @AppStorage("userAccountName") var accountName = ""
    @AppStorage("userToken") var token = ""
    
    @AppStorage("userMaimaiInfoData") var userInfoData = Data()
    @AppStorage("userMaimaiProfileData") var userProfileData = Data()
    
    @AppStorage("didCachedMaimaiData") var didCached = false
    @AppStorage("didLogin") var didLogin = false
    
    @State private var firstAppear = true
    
    @State private var showingSettings = false
    @State private var showingTotalCharts = false
    @State private var showingErrorToast = false
    
    @State private var decodedSongList: Array<MaimaiSongData> = []
    @State private var decodedChartStats: Dictionary<String, Array<MaimaiChartStat>> = [:]
    @State private var decodedRanking: Array<MaimaiPlayerRating> = []
    
    @State private var userInfo = MaimaiPlayerRecord.shared
    @State private var userProfile = MaimaiPlayerProfile.shared
    
    @State private var pastRating = 0
    @State private var currentRating = 0
    @State private var rawRating = 0
    
    @State private var totalPlayedCharts = 0
    @State private var totalCharts = 0
    
    @State private var avgAchievement = 0.0
    
    @State private var ranking = 0
    
    @State private var pastSlice = ArraySlice<MaimaiRecordEntry>()
    @State private var currentSlice = ArraySlice<MaimaiRecordEntry>()
    
    @State private var status = LoadStatus.notLogin
    
    @State private var previousToken = ""
    
    private var rows = [
        GridItem(),
        GridItem()
    ]
    
    var body: some View {
        ZStack {
            switch (status) {
            case .complete:
                ScrollView {
                    VStack {
                        HStack {
                            HStack {
                                Text("Rating")
                                    .font(.system(size: 20))
                                VStack {
                                    Text(String(rawRating + userInfo.additionalRating))
                                        .font(.system(size: 20))
                                        .bold()
                                    Text(verbatim: "(\(rawRating)+\(userInfo.additionalRating))")
                                        .font(.system(size: 15))
                                }
                            }
                            
                            HStack {
                                Text("Avg%")
                                    .font(.system(size: 20))
                                VStack {
                                    Text("\(avgAchievement, specifier: "%.4f")%")
                                        .font(.system(size: 20))
                                        .bold()
                                    Text(verbatim: "(\(totalPlayedCharts)条记录)")
                                        .font(.system(size: 15))
                                }
                            }
                        }
                        .padding(.vertical)
                        
                        if(ranking != 0) {
                            Text("Rating全国排名: #\(ranking)")
                        }
                        
                        HStack {
                            Text("旧版本 - R" + String(pastRating))
                                .font(.title2)
                                .padding()
                            
                            Spacer()
                            
                        }
                        
                        ScrollView(.horizontal) {
                            LazyHGrid(rows: rows, spacing: 5) {
                                ForEach(0..<pastSlice.count) { i in
                                    NavigationLink {
                                        MaimaiDetailView(song: decodedSongList.filter { Int($0.musicId)! == pastSlice[i].musicId }[0])
                                    } label: {
                                        MaimaiMiniView(song: pastSlice[i])
                                    }.buttonStyle(.plain)
                                }
                            }
                        }
                        .frame(height: 210)
                        .padding(.horizontal)
                        
                        HStack {
                            Text("新版本 - R" + String(currentRating))
                                .font(.title2)
                                .padding()
                            
                            Spacer()
                            
                        }
                        
                        ScrollView(.horizontal) {
                            LazyHGrid(rows: rows, spacing: 5) {
                                ForEach(0..<currentSlice.count) { i in
                                    NavigationLink {
                                        MaimaiDetailView(song: decodedSongList.filter { Int($0.musicId)! == currentSlice[i].musicId }[0])
                                    } label: {
                                        MaimaiMiniView(song: currentSlice[i])
                                    }.buttonStyle(.plain)
                                }
                            }
                        }
                        .frame(height: 210)
                        .padding(.horizontal)
                        
                        Button {
                            Task {
                                resetCache()
                                await prepareData()
                            }
                        } label: {
                            Image(systemName: "arrow.clockwise")
                            Text("刷新缓存")
                        }.padding()
                    }
                    
                }
            case let .loading(hint: hint):
                VStack {
                    ProgressView()
                        .padding()
                    Text(hint)
                }
                .navigationBarTitle("")
            case .loadFromCache, .notLogin:
                VStack {
                    Text("未登录查分器，请前往设置登录")
                }
                .navigationBarTitle("")
            case .error(errorText: let errorText):
                VStack {
                    Text(errorText)
                        .padding()
                    Button {
                        resetCache()
                        Task {
                            await prepareData()
                        }
                    } label: {
                        Text("重试")
                    }
                }
                .navigationBarTitle("")
            case .empty:
                VStack {
                    Text("暂无游玩数据！")
                        .padding()
                    Button {
                        resetCache()
                        Task {
                            await prepareData()
                        }
                    } label: {
                        Text("刷新")
                    }
                }
                .navigationBarTitle("")
            }
        }
        .onAppear {
            Task {
                await prepareData()
            }
        }
        .navigationTitle(didLogin ? "\(userProfile.nickname)的个人资料" : "查分器DX")
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
        .onChange(of: showingSettings) { value in
            if(!value) {
                if token != previousToken {
                    resetCache()
                }
                Task {
                    await prepareData()
                }
            }
        }
        .toast(isPresenting: $showingErrorToast, duration: 2, tapToDismiss: true) {
            AlertToast(displayMode: .alert, type: .error(.red), title: "发生错误")
        }
        
    }
    
    func prepareData() async {
        guard token != "" || didLogin else { status = .notLogin; return }
        if (pastSlice.isEmpty) { didCached = false }
        guard !didCached else { status = .complete; return }

        await loadUserData()
        
    }
    
    func loadUserData() async {
        status = .loading(hint: "加载数据中...")
        if (userInfoData.isEmpty) {
            do {
                try await getUserInfoData()
            } catch {
                status = .error(errorText: "用户数据加载失败")
                return
            }
        }
        do {
            userInfo = try JSONDecoder().decode(MaimaiPlayerRecord.self, from: userInfoData)
        } catch {
            status = .error(errorText: "用户数据解析失败")
            return
        }
        
        
        if (userProfileData.isEmpty) {
            do {
                try await getUserProfileData()
            } catch {
                status = .error(errorText: "用户资料加载失败")
                return
            }
        }
        do {
            userProfile = try JSONDecoder().decode(MaimaiPlayerProfile.self, from: userProfileData)
        } catch {
            status = .error(errorText: "用户资料解析失败")
            return
        }
        
        if (loadedSongs.isEmpty) {
            do {
                try await getSongListData()
            } catch {
                status = .error(errorText: "歌曲列表加载失败")
                return
            }
        }
        do {
            decodedSongList = try JSONDecoder().decode(Array<MaimaiSongData>.self, from: loadedSongs)
        } catch {
            status = .error(errorText: "歌曲列表解析失败")
            return
        }
        
        if (loadedStats.isEmpty) {
            do {
                try await getChartStatsData()
            } catch {
                status = .error(errorText: "歌曲信息加载失败")
                return
            }
        }
        do {
            decodedChartStats = try JSONDecoder().decode(Dictionary<String, Array<MaimaiChartStat>>.self, from: loadedStats)
        } catch {
            status = .error(errorText: "歌曲信息解析失败")
            return
        }
        
        if (loadedRanking.isEmpty) {
            do {
                try await getRankingData()
            } catch {
                status = .error(errorText: "排行榜信息加载失败")
                return
            }
        }
        do {
            decodedRanking = try JSONDecoder().decode(Array<MaimaiPlayerRating>.self, from: loadedRanking)
        } catch {
            status = .error(errorText: "排行榜信息解析失败")
            return
        }
        
        if userInfo.isRecordEmpty() {
            status = .empty
            return
        }
        
        calculateData()
        
        status = .complete
        didCached = true
    }
    
    func getUserInfoData() async throws {
        userInfoData = try await MaimaiDataGrabber.getPlayerRecord(token: token)
    }
    
    func getUserProfileData() async throws {
        userProfileData = try await MaimaiDataGrabber.getPlayerProfile(token: token)
    }
    
    func getSongListData() async throws {
        loadedSongs = try await MaimaiDataGrabber.getMusicData()
    }
    
    func getChartStatsData() async throws {
        loadedStats = try await MaimaiDataGrabber.getChartStat()
    }
    
    func getRankingData() async throws {
        loadedRanking = try! await MaimaiDataGrabber.getRatingRanking()
    }
    
    func calculateData() {
        pastSlice = userInfo.getPastSlice(songData: decodedSongList)
        currentSlice = userInfo.getCurrentSlice(songData: decodedSongList)
        
        pastRating = pastSlice.reduce(0) { $0 + $1.rating }
        currentRating = currentSlice.reduce(0) { $0 + $1.rating }
        rawRating = pastRating + currentRating
        
        totalCharts = decodedSongList.reduce(0) {
            $0 + $1.charts.count
        }
        totalPlayedCharts = userInfo.records.count
        
        avgAchievement = userInfo.records.reduce(0.0) {
            $0 + $1.achievements / Double(userInfo.records.count)
        }
        
        decodedRanking.sort {
            $0.rating > $1.rating
        }
        ranking = (decodedRanking.firstIndex(where: {
            $0.username == userProfile.username
        }) ?? -1) + 1
    }
    
    func resetCache() {
        didCached = false
        userInfoData = Data()
        userProfileData = Data()
        loadedSongs = Data()
        loadedStats = Data()
        ranking = 0
    }
}


struct MaimaiHomeView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(currentTab: .constant(.home))
    }
}
