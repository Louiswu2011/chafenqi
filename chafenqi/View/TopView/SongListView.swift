//
//  MaimaiListView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/3.
//

import SwiftUI

struct SongListView: View {
    @AppStorage("settingsCurrentMode") var mode = 0
    
    @AppStorage("settingsMaimaiCoverSource") var maimaiCoverSource = 0
    @AppStorage("settingsChunithmCoverSoruce") var chunithmCoverSource = 0
    
    @AppStorage("loadedMaimaiSongs") var loadedMaimaiSongs = Data()
    @AppStorage("loadedChunithmSongs") var loadedChunithmSongs = Data()
    
    @AppStorage("didLogin") var didLogin = false
    
    @AppStorage("userMaimaiInfoData") var userMaimaiInfoData = Data()
    @AppStorage("userChunithmInfoDta") var userChunithmInfoData = Data()
    
    @AppStorage("didMaimaiSongListLoaded") private var didMaimaiLoaded = false
    @AppStorage("didChunithmSongListLoaded") private var didChunithmLoaded = false
    
    @State private var searchText = ""
    
    @State private var decodedMaimaiSongs: Array<MaimaiSongData> = []
    @State private var decodedChunithmSongs: Array<ChunithmSongData> = []
    
    @State private var showingDetail = false
    @State private var showingFilterPanel = false
    @State private var showingPlayed = false
    
    
    var body: some View {
        VStack{
            let isLoaded = mode == 0 ? didChunithmLoaded : didMaimaiLoaded
            
            if (isLoaded) {
                if (mode == 0) {
                    if searchChunithmResults != nil {
                        List {
                            ForEach(searchChunithmResults!.sorted(by: <), id: \.musicId) { song in
                                NavigationLink {
                                    ChunithmDetailView(song: song)
                                } label: {
                                    SongBasicView(chunithmSong: song)
                                }
                                
                            }
                        }
                    } else {
                        VStack(spacing: 15) {
                            ProgressView()
                            Text("加载歌曲列表中...")
                        }
                    }
                } else {
                    if searchMaimaiResults != nil {
                        List {
                            ForEach(searchMaimaiResults!.sorted(by: <), id: \.musicId) { song in
                                NavigationLink {
                                    MaimaiDetailView(song: song)
                                } label: {
                                    SongBasicView(maimaiSong: song)
                                }
                                
                            }
                        }
                    } else {
                        VStack(spacing: 15) {
                            ProgressView()
                            Text("加载歌曲列表中...")
                        }
                    }
                }
            } else {
                VStack(spacing: 15) {
                    ProgressView()
                    Text("加载歌曲列表中...")
                }
            }
            
        }
        .navigationTitle("曲目列表")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    //                        Button {
                    //                            showingFilterPanel.toggle()
                    //                        } label: {
                    //                            Image(systemName: "arrow.up.arrow.down")
                    //                            Text("筛选和排序")
                    //                        }
                    //                        .sheet(isPresented: $showingFilterPanel) {
                    //
                    //                        }
                    Toggle(isOn: $showingPlayed) {
                        Image(systemName: "rectangle.on.rectangle")
                        Text("仅显示已游玩曲目")
                    }
                    .disabled(!didLogin)
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
        }
        .onAppear {
            if (mode == 0) {
                if (loadedChunithmSongs.isEmpty) {
                    didChunithmLoaded = false
                    Task {
                        do {
                            try await loadedChunithmSongs = JSONEncoder().encode(ChunithmDataGrabber.getSongDataSetFromServer())
                            decodedChunithmSongs = try JSONDecoder().decode(Array<ChunithmSongData>.self, from: loadedChunithmSongs)
                            didChunithmLoaded = true
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                } else {
                    didChunithmLoaded = true
                }
            } else {
                if (loadedMaimaiSongs.isEmpty) {
                    didMaimaiLoaded = false
                    Task {
                        do {
                            try await loadedMaimaiSongs = JSONEncoder().encode(MaimaiDataGrabber.getMusicData())
                            decodedMaimaiSongs = try JSONDecoder().decode(Array<MaimaiSongData>.self, from: loadedMaimaiSongs)
                            didMaimaiLoaded = true
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                } else {
                    didMaimaiLoaded = true
                }
            }
        }
        .searchable(text: $searchText, prompt: "输入歌曲名/作者...")
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled(true)
        
    }
    
    var searchMaimaiResults: Array<MaimaiSongData>? {
        guard didMaimaiLoaded && mode == 1 else { return nil }
        
        do {
            var songs = try decodedMaimaiSongs.isEmpty ? JSONDecoder().decode(Array<MaimaiSongData>.self, from: loadedMaimaiSongs) :
            decodedMaimaiSongs
            
            if (showingPlayed) {
                let userInfo = try! JSONDecoder().decode(MaimaiPlayerRecord.self, from: userMaimaiInfoData)
                let idList = userInfo.records.compactMap { $0.musicId }
                songs = songs.filter { idList.contains( Int($0.musicId)! ) }
            }

            if searchText.isEmpty {
                return songs
            } else {
                return songs.filter {$0.title.lowercased().contains(searchText.lowercased()) || $0.basicInfo.artist.lowercased().contains(searchText.lowercased())}
            }
        } catch {
            return nil
        }
    }
    
    var searchChunithmResults: Array<ChunithmSongData>? {
        guard didChunithmLoaded && mode == 0 else { return nil }
        
        do {
            var songs = try decodedChunithmSongs.isEmpty ? JSONDecoder().decode(Array<ChunithmSongData>.self, from: loadedChunithmSongs) :
            decodedChunithmSongs
            
            if (showingPlayed) {
                let userInfo = try! JSONDecoder().decode(ChunithmUserData.self, from: userChunithmInfoData)
                let idList = userInfo.records.best.compactMap { $0.musicId }
                songs = songs.filter { idList.contains( $0.musicId ) }
            }

            if searchText.isEmpty {
                return songs
            } else {
                return songs.filter {$0.title.lowercased().contains(searchText.lowercased()) || $0.basicInfo.artist.lowercased().contains(searchText.lowercased())}
            }
        } catch {
            return nil
        }
    }
}

struct MaimaiListView_Previews: PreviewProvider {
    static var previews: some View {
        SongListView()
    }
}
