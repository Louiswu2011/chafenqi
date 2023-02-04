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
    
    @AppStorage("userNickname") var accountNickname = ""
    @AppStorage("userAccountName") var accountName = ""
    @AppStorage("userToken") var token = ""
    @AppStorage("userMaimaiInfoData") var userInfoData = Data()
    
    @AppStorage("didCachedMaimaiData") var didCached = false
    @AppStorage("didLogin") var didLogin = false
    
    @State private var firstAppear = true
    
    @State private var showingSettings = false
    @State private var showingTotalCharts = false
    
    @State private var decodedSongList: Array<MaimaiSongData> = []
    @State private var decodedChartStats: Dictionary<String, Array<MaimaiChartStat>> = [:]
    @State private var userInfo = MaimaiPlayerRecord()
    
    @State private var pastRating = 0
    @State private var currentRating = 0
    @State private var rawRating = 0
    
    @State private var totalPlayedCharts = 0
    @State private var totalCharts = 0
    
    @State private var avgAchievement = 0.0
    
    @State private var pastSlice = ArraySlice<MaimaiRecordEntry>()
    @State private var currentSlice = ArraySlice<MaimaiRecordEntry>()
    
    @State private var status = LoadStatus.empty
    
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
//                            ZStack {
//                                CutCircularProgressView(progress: 0.6, lineWidth: 10, width: 70, color: Color.indigo)
//
//                                Text(String(pastRating))
//                                    .foregroundColor(Color.indigo)
//                                    .textFieldStyle(.roundedBorder)
//                                    .font(.title3)
//
//                                Text("Prev")
//                                    .padding(.top, 60)
//                            }
//                            .padding()
//                            .padding(.top, 50)
                            

                            HStack {
                                VStack {
                                    Text("Rating")
                                        .font(.title2)
                                    Text(String(rawRating + userInfo.additionalRating))
                                        .font(.title3)
                                }
                                
                            }
                            .padding([.horizontal, .top])
                            
                            
//                            ZStack {
//                                CutCircularProgressView(progress: showingTotalCharts ? 1 : Double(totalPlayedCharts) / Double(totalCharts), lineWidth: 8, width: 50, color: Color.pink)
//
//                                Text(String(showingTotalCharts ? totalCharts : totalPlayedCharts))
//                                    .foregroundColor(Color.pink)
//                                    .textFieldStyle(.roundedBorder)
//                                    .font(.title)
//                                    .transition(.opacity)
//
//                                Text(showingTotalCharts ? "总谱面" : "已游玩")
//                                    .font(.system(size: 20))
//                                    .padding(.top, 70)
//                            }
//                            .padding()
//                            .onTapGesture {
//                                showingTotalCharts.toggle()
//                            }
                            
                            
//                            ZStack {
//                                // TODO: get max
//                                CutCircularProgressView(progress: 0.3, lineWidth: 10, width: 70, color: Color.cyan)
//
//                                Text(String(currentRating))
//                                    .foregroundColor(Color.cyan)
//                                    .textFieldStyle(.roundedBorder)
//                                    .font(.title3)
//
//                                Text("New")
//                                    .padding(.top, 60)
//                            }
//                            .padding()
//                            .padding(.top, 50)
                        }
                        
                        HStack {
                            Text("旧版本 - R" + String(pastRating))
                                .font(.title2)
                                .padding()
                            
                            Spacer()
                            
                            
                            NavigationLink {
                                
                            } label: {
                                Image(systemName: "arrow.right")
                            }.padding()
                            
                        }
                        
                        ScrollView(.horizontal) {
                            LazyHGrid(rows: rows, spacing: 5) {
                                ForEach(0..<25) { i in
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
                            
                            
                            NavigationLink {
                                
                            } label: {
                                Image(systemName: "arrow.right")
                            }.padding()
                            
                        }
                        
                        ScrollView(.horizontal) {
                            LazyHGrid(rows: rows, spacing: 5) {
                                ForEach(0..<15) { i in
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
                    }
                }
            case let .loading(hint: hint):
                VStack {
                    ProgressView()
                        .padding()
                    Text(hint)
                }
            case .loadFromCache, .empty:
                VStack {
                    Text("未登录查分器，请前往设置登录")
                }
            case .error(errorText: let errorText):
                VStack {
                    ProgressView()
                        .padding()
                    Text(errorText)
                }
            }
        }
        .task {
            guard token != "" else { status = .empty; return }
            if (pastSlice.isEmpty) { didCached = false }
            guard !didCached else { status = .complete; return }

            do {
                try await loadUserData()
            } catch {
                status = .error(errorText: error.localizedDescription)
            }
            
            
        }
        .navigationTitle(didLogin ? "LOUIS的个人资料" : "查分器DX")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    previousToken = token
                    showingSettings.toggle()
                }) {
                    Image(systemName: "gear")
                }.sheet(isPresented: $showingSettings) {
                    SettingsView(showingSettings: $showingSettings)
                }
            }
        }
        .onChange(of: showingSettings) { value in
            if(!value) {
                if (token != previousToken) {
                    resetCache()
                }
            }
        }
        
    }
    
    func loadUserData() async throws {
        if (userInfoData.isEmpty){
            status = .loading(hint: "获取用户数据中...")
            userInfoData = try await MaimaiDataGrabber.getPlayerRecord(token: token)
        }
        userInfo = try! JSONDecoder().decode(MaimaiPlayerRecord.self, from: userInfoData)
        
        if (loadedSongs.isEmpty){
            status = .loading(hint: "获取谱面列表中...")
            loadedSongs = try await MaimaiDataGrabber.getMusicData()
        }
        decodedSongList = try! JSONDecoder().decode(Array<MaimaiSongData>.self, from: loadedSongs)
        
        if (loadedStats.isEmpty){
            status = .loading(hint: "加载谱面数据中...")
            loadedStats = try await MaimaiDataGrabber.getChartStat()
        }
        decodedChartStats = try! JSONDecoder().decode(Dictionary<String, Array<MaimaiChartStat>>.self, from: loadedStats)
        
        status = .loading(hint: "加载用户数据中...")
        calculateData()
        
        status = .complete
        didCached = true
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
    }
    
    func resetCache() {
        didCached = false
    }
}


struct MaimaiHomeView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
