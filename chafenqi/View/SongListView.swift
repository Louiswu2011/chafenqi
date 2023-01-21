//
//  SearchView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/8.
//

import SwiftUI

struct SongListView: View {
    @AppStorage("settingsCoverSource") var coverSource = ""
    @AppStorage("loadedSongs") var loadedSongs: Data = Data()
    
    @State private var searchText = ""
    @State private var showingDetail = false
    @State private var didSongListLoaded = false
    @State private var decodedLoadedSongs: Set<SongData> = []
    // @SceneStorage("filteredSongs") var filteredSongs: Data = Data()
    
    var body: some View {
        NavigationView {
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
                        Button {
                            
                        } label: {
                            Image(systemName: "arrow.up.arrow.down")
                            Text("排序")
                        }
                        Button {
                            
                        } label: {
                            Image(systemName: "slider.horizontal.3")
                            Text("筛选")
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .task {
                if (loadedSongs.isEmpty) {
                    didSongListLoaded = false
                    print("Starting task...")
                    // var songs: Set<SongData>
                    do {
                        try await loadedSongs = JSONEncoder().encode(ProbeDataGrabber.getSongDataSetFromServer())
                        print("Returned.")
                        didSongListLoaded.toggle()
                        decodedLoadedSongs = try! JSONDecoder().decode(Set<SongData>.self, from: loadedSongs)
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
        
    }
    
    var searchResults: Set<SongData> {
        let songs = try! decodedLoadedSongs.isEmpty ? JSONDecoder().decode(Set<SongData>.self, from: loadedSongs) :
            decodedLoadedSongs
        
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
