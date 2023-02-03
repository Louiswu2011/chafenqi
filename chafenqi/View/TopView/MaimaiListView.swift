//
//  MaimaiListView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/3.
//

import SwiftUI

struct MaimaiListView: View {
    @AppStorage("settingsCurrentMode") var mode = 0
    
    @AppStorage("settingsMaimaiCoverSource") var coverSource = 0
    
    @AppStorage("loadedMaimaiSongs") var loadedSongs: Data = Data()
    
    @AppStorage("didLogin") var didLogin = false
    @AppStorage("userMaimaiInfoData") var userInfoData = Data()
    @AppStorage("didMaimaiSongListLoaded") private var didSongListLoaded = false
    
    @State private var searchText = ""
    
    @State private var decodedLoadedMaimaiSongs: Array<MaimaiSongData> = []
    
    @State private var showingDetail = false
    @State private var showingFilterPanel = false
    @State private var showingPlayed = false
    
    
    var body: some View {
        
        VStack{
            if (didSongListLoaded) {
                List {
                    ForEach(searchMaimaiResults.sorted(by: <), id: \.musicId) { song in
                        NavigationLink {
                            MaimaiDetailView(song: song)
                        } label: {
                            MaimaiBasicView(song: song)
                        }
                        
                    }
                }
            } else {
                VStack(spacing: 15) {
                    ProgressView()
                    Text("加载歌曲列表中")
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
        .task {
            if (loadedSongs.isEmpty) {
                didSongListLoaded = false
                // var songs: Set<SongData>
                do {
                    try await loadedSongs = JSONEncoder().encode(MaimaiDataGrabber.getMusicData())
                    decodedLoadedMaimaiSongs = try! JSONDecoder().decode(Array<MaimaiSongData>.self, from: loadedSongs)
                    didSongListLoaded = true
                } catch {
                    print(error.localizedDescription)
                }
            } else {
                didSongListLoaded = true
            }
        }
        .searchable(text: $searchText, prompt: "输入歌曲名/作者...")
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled(true)
        
    }
    
    var searchMaimaiResults: Array<MaimaiSongData> {
        var songs = try! decodedLoadedMaimaiSongs.isEmpty ? JSONDecoder().decode(Array<MaimaiSongData>.self, from: loadedSongs) :
        decodedLoadedMaimaiSongs
        
        if searchText.isEmpty {
            return songs
        } else {
            return songs.filter {$0.title.lowercased().contains(searchText.lowercased()) || $0.basicInfo.artist.lowercased().contains(searchText.lowercased())}
        }
        
//        if (showingPlayed) {
//            let userInfo = try! JSONDecoder().decode(ChunithmUserData.self, from: userInfoData)
//            let idList = userInfo.records.best.compactMap { $0.musicID }
//            songs = songs.filter { idList.contains( $0.id ) }
//        }
//
//        if searchText.isEmpty {
//            return songs
//        } else {
//            return songs.filter {$0.title.lowercased().contains(searchText.lowercased()) || $0.basicInfo.artist.lowercased().contains(searchText.lowercased())}
//        }
    }
}

struct MaimaiListView_Previews: PreviewProvider {
    static var previews: some View {
        MaimaiListView()
    }
}
