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
    
    @AppStorage("didLogin") var didLogin = false
    
    @State private var showingSettings = false
    
    @State private var decodedSongList: Array<MaimaiSongData> = []
    @State private var decodedChartStats: Dictionary<String, Array<MaimaiChartStat>> = [:]
    
    @State private var status = LoadStatus.loading(hint: "加载用户信息中...")
    
    private var rows = [
        GridItem(),
        GridItem()
    ]
    
    var body: some View {
        ZStack {
            switch (status) {
            case .complete:
                HStack {
                    ZStack {
                        CutCircularProgressView(progress: 0.6, lineWidth: 10, width: 70, color: Color.indigo)
                        
                        Text("12345")
                            .foregroundColor(Color.indigo)
                            .textFieldStyle(.roundedBorder)
                            .font(.title3)
                        
                        Text("R10")
                            .padding(.top, 60)
                    }
                    .padding()
                    .padding(.top, 50)
                    
                    ZStack {
                        CutCircularProgressView(progress: 0.7, lineWidth: 14, width: 100, color: Color.pink)
                        
                        Text("5678")
                            .foregroundColor(Color.pink)
                            .textFieldStyle(.roundedBorder)
                            .font(.title)
                            .transition(.opacity)
                        
                        Text("Rating")
                            .padding(.top, 70)
                    }
                    .padding()
                    
                    
                    ZStack {
                        // TODO: get max
                        CutCircularProgressView(progress: 0.3, lineWidth: 10, width: 70, color: Color.cyan)
                        
                        Text("3234")
                            .foregroundColor(Color.cyan)
                            .textFieldStyle(.roundedBorder)
                            .font(.title3)
                        
                        Text("B30")
                            .padding(.top, 60)
                    }
                    .padding()
                    .padding(.top, 50)
                }
            case let .loading(hint: hint):
                VStack {
                    ProgressView()
                        .padding()
                    Text(hint)
                }
            case .loadFromCache, .empty:
                VStack {
                    ProgressView()
                    Text("Wait a moment...")
                }
            case .error(errorText: let errorText):
                VStack {
                    ProgressView()
                    Text(errorText)
                }
            }
        }
        .task {
            do {
                try await loadUserData()
                status = .complete
            } catch {
                status = .error(errorText: error.localizedDescription)
            }
        }
        .navigationTitle(didLogin ? "LOUIS的个人资料" : "查分器DX")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingSettings.toggle()
                }) {
                    Image(systemName: "gear")
                }.sheet(isPresented: $showingSettings) {
                    SettingsView(showingSettings: $showingSettings)
                }
            }
        }
        
    }
    
    func loadUserData() async throws {
        do {
            loadedStats = try await MaimaiDataGrabber.getChartStat()
            decodedChartStats = try! JSONDecoder().decode(Dictionary<String, Array<MaimaiChartStat>>.self, from: loadedStats)
            
            loadedSongs = try await MaimaiDataGrabber.getMusicData()
            decodedSongList = try! JSONDecoder().decode(Array<MaimaiSongData>.self, from: loadedSongs)
            
            
        } catch {
            print("Failed to load.")
            print(error)
        }
    }
}


struct MaimaiHomeView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
