//
//  RecentView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/18.
//

import SwiftUI

struct RecentView: View {
    @AppStorage("didLogin") var didLogin = false
    
    @AppStorage("settingsChunithmCoverSource") var chunithmCoverSource = 0
    @AppStorage("settingsMaimaiCoverSource") var maimaiCoverSource = 0
    @AppStorage("settingsCurrentMode") var currentMode = 0
    
    @AppStorage("settingsRecentLogEntryCount") var entryCount = "30"
    
    @AppStorage("userAccountName") var accountName = ""
    
    @AppStorage("loadedMaimaiSongs") var loadedMaimaiSongs = Data()
    @AppStorage("loadedChunithmSongs") var loadedChunithmSongs = Data()
    
    @AppStorage("userChunithmRecentData") var chuRecentData = Data()
    @AppStorage("userMaimaiRecentData") var maiRecentData = Data()
    
    @State var chuRecent: Array<ChunithmRecentRecord> = []
    @State var maiRecent: Array<MaimaiRecentRecord> = []
    @State var chuSongs: Array<ChunithmSongData> = []
    @State var maiSongs: Array<MaimaiSongData> = []
    @State var status: LoadStatus = .loading(hint: "加载中...")
    
    var body: some View {
        VStack {
            if(didLogin) {
                switch status {
                case .loading(let hint):
                    VStack {
                        ProgressView()
                            .padding()
                        Text(hint)
                    }
                case .complete:
                    if (currentMode == 0) {
                        if (chuSongs.isEmpty || chuRecent.isEmpty) {
                            VStack{
                                Text("暂无最近记录")
                                    .padding()
                                Text("可通过传分器上传")
                            }
                        } else {
                            List {
                                ForEach(chuRecent.indices) { index in
                                    NavigationLink {
                                        RecentDetailView(chuSong: chuSongs[index], chuRecord: chuRecent[index], mode: 0)
                                    } label: {
                                        RecentBasicView(chunithmSong: chuSongs[index], chunithmRecord: chuRecent[index], mode: 0)
                                    }
                                }
                            }
                        }
                    } else {
                        if (maiSongs.isEmpty || maiRecent.isEmpty) {
                            VStack{
                                Text("暂无最近记录")
                                    .padding()
                                Text("可通过传分器上传")
                            }
                        } else {
                            List {
                                ForEach(maiRecent.indices) { index in
                                    NavigationLink {
                                        RecentDetailView(maiSong: maiSongs[index], maiRecord: maiRecent[index], mode: 1)
                                    } label: {
                                        RecentBasicView(maimaiSong: maiSongs[index], maimaiRecord: maiRecent[index], mode: 1)
                                    }
                                }
                            }
                        }
                    }
                    
                default:
                    VStack{
                        Text("暂无最近记录")
                            .padding()
                        Text("可通过传分器上传")
                    }
                }
            } else {
                Text("请先登录查分器账号！")
            }
        }
        .onAppear {
            Task {
                await getRecentData()
            }
        }
        .navigationTitle("最近记录")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    chuRecentData = Data()
                    maiRecentData = Data()
                    chuSongs = []
                    maiSongs = []
                    chuRecent = []
                    maiRecent = []
                    Task {
                        await getRecentData()
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
    }
    
    func getRecentData() async {
        guard didLogin else {
            status = .notLogin
            return
        }
        status = .loading(hint: "加载中...")
        if (currentMode == 0) {
            guard chuRecent.isEmpty else { status = .complete; return }
            do {
                chuRecentData = try await ChunithmDataGrabber.getRecentData(username: accountName, limit: Int(entryCount) ?? 30)
                if (chuRecent.isEmpty) {
                    chuRecent = try JSONDecoder().decode(Array<ChunithmRecentRecord>.self, from: chuRecentData)
                }
                let chuSongData = try JSONDecoder().decode(Array<ChunithmSongData>.self, from: loadedChunithmSongs)
                
                for (index, entry) in chuRecent.enumerated() {
                    status = .loading(hint: "加载中 \(index + 1)/\(chuRecent.count)")
                    let found = chuSongData.first { data in
                        String(data.musicId) == entry.music_id
                    }
                    guard let unwrapped = found else { continue }
                    chuSongs.append(unwrapped)
                }
                if (chuSongs.isEmpty || chuRecent.isEmpty) {
                    status = .empty
                } else {
                    status = .complete
                }
            } catch {
                print(error)
            }
        } else {
            guard maiRecent.isEmpty else { status = .complete; return }
            do {
                maiRecentData = try await MaimaiDataGrabber.getRecentData(username: accountName, limit: Int(entryCount) ?? 30)
                if (maiRecent.isEmpty) {
                    maiRecent = try JSONDecoder().decode(Array<MaimaiRecentRecord>.self, from: maiRecentData)
                }
                let maiSongData = try JSONDecoder().decode(Array<MaimaiSongData>.self, from: loadedMaimaiSongs)
                
                for (index, entry) in maiRecent.enumerated() {
                    status = .loading(hint: "加载中 \(index + 1)/\(maiRecent.count)")
                    let found = maiSongData.first { data in
                        String(data.title) == entry.title
                    }
                    guard let unwrapped = found else { continue }
                    maiSongs.append(unwrapped)
                }
                
                if (maiSongs.isEmpty || maiRecent.isEmpty) {
                    status = .empty
                } else {
                    status = .complete
                }
            } catch {
                print(error)
            }
        }
    }
}

struct RecentView_Previews: PreviewProvider {
    static var previews: some View {
        RecentView()
    }
}
