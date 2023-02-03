//
//  SearchView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/8.
//

import SwiftUI

enum sortState {
    case byMusicID, byHighestConstant
}

struct SongListView: View {
    @AppStorage("settingsCoverSource") var coverSource = ""
    @AppStorage("loadedChunithmSongs") var loadedSongs: Data = Data()
    @AppStorage("didLogin") var didLogin = false
    @AppStorage("userChunithmInfoData") var userInfoData = Data()
    @AppStorage("didChunithmSongListLoaded") private var didSongListLoaded = false
    
    @State private var searchText = ""
    
    
    @State private var decodedLoadedSongs: Set<ChunithmSongData> = []
    
    @State private var showingDetail = false
    @State private var showingFilterPanel = false
    @State private var showingPlayed = false
    
    
    var body: some View {
        
        VStack{
            if (didSongListLoaded) {
                // Text("\(searchText)")
                //ScrollView {
                
                List {
                    ForEach(searchResults.sorted(by: <), id: \.id) { song in
                        NavigationLink(destination: SongDetailView(song: song)) {
                            SongBasicInfoView(song: song)
                        }
                        // TODO: open detail view
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
                    try await loadedSongs = JSONEncoder().encode(ChunithmDataGrabber.getSongDataSetFromServer())
                    didSongListLoaded.toggle()
                    decodedLoadedSongs = try! JSONDecoder().decode(Set<ChunithmSongData>.self, from: loadedSongs)
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
    
    
    var searchResults: Set<ChunithmSongData> {
        var songs = try! decodedLoadedSongs.isEmpty ? JSONDecoder().decode(Set<ChunithmSongData>.self, from: loadedSongs) :
        decodedLoadedSongs
        
        if (showingPlayed) {
            let userInfo = try! JSONDecoder().decode(ChunithmUserData.self, from: userInfoData)
            let idList = userInfo.records.best.compactMap { $0.musicID }
            songs = songs.filter { idList.contains( $0.id ) }
        }
        
        if searchText.isEmpty {
            return songs
        } else {
            return songs.filter {$0.title.lowercased().contains(searchText.lowercased()) || $0.basicInfo.artist.lowercased().contains(searchText.lowercased())}
        }
    }
    
    
}



struct SongListView_Previews: PreviewProvider {
    static var previews: some View {
        SongListView()
    }
}
