//
//  SongTopView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/5/8.
//

import SwiftUI
import SwiftlySearch

struct SongTopView: View {
    @ObservedObject var user: CFQNUser
    
    @State var filteredMaiSongs: [MaimaiSongData] = []
    @State var filteredChuSongs: [ChunithmSongData] = []
    @State var searchText = ""
    
    var body: some View {
        VStack {
            if #available(iOS 15.0, *) {
                List {
                    if (user.currentMode == 0) {
                        ForEach(filteredChuSongs, id: \.musicId) { entry in
                            SongItemView(user: user, chuSong: entry)
                        }
                    } else {
                        ForEach(filteredMaiSongs, id: \.musicId) { entry in
                            SongItemView(user: user, maiSong: entry)
                        }
                    }
                }
                .searchable(text: $searchText, prompt: Text("搜索标题/曲师"))
                .onSubmit(of: .search) {
                    filterSongs()
                }
                .onChange(of: searchText) { _ in
                    filterSongs()
                }
                .onAppear {
                    filterSongs()
                }
            } else {
                // Fallback on earlier versions
                List {
                    if (user.currentMode == 0) {
                        ForEach(filteredChuSongs, id: \.musicId) { entry in
                            SongItemView(user: user, chuSong: entry)
                        }
                    } else {
                        ForEach(filteredMaiSongs, id: \.musicId) { entry in
                            SongItemView(user: user, maiSong: entry)
                        }
                    }
                }
                .navigationBarSearch($searchText)
                .onChange(of: searchText) { _ in
                    filterSongs()
                }
                .onAppear {
                    filterSongs()
                }
            }
        }
        .navigationTitle("歌曲列表")
    }
    
    func filterSongs() {
        if (user.currentMode == 0) {
            if (searchText.isEmpty) {
                filteredChuSongs = user.data.chunithm.songs
            } else {
                filteredChuSongs = user.data.chunithm.songs.filter {
                    $0.title.localizedCaseInsensitiveContains(searchText) ||
                    $0.basicInfo.artist.localizedCaseInsensitiveContains(searchText)
                }
            }
        } else {
            if (searchText.isEmpty) {
                filteredMaiSongs = user.data.maimai.songlist
            } else {
                filteredMaiSongs = user.data.maimai.songlist.filter {
                    $0.title.localizedCaseInsensitiveContains(searchText) ||
                    $0.basicInfo.artist.localizedCaseInsensitiveContains(searchText)
                }
            }
        }
    }
}

struct SongTopView_Previews: PreviewProvider {
    static var previews: some View {
        SongTopView(user: CFQNUser())
    }
}
