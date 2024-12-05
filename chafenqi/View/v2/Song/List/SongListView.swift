//
//  SongListView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2024/08/27.
//

import Foundation
import SwiftUI

struct SongListView: View {
    @ObservedObject var user: CFQNUser
    
    @State private var showFilterView: Bool = false
    @State private var searchText: String = ""
    
    @State private var chuSongList: [ChunithmMusicData] = []
    @State private var maiSongList: [MaimaiSongData] = []
    
    @State private var chuPlayedId: [Int] = []
    @State private var maiPlayedId: [Int] = []
    
    @State private var chuOption: SongListFilterOptions = SongListFilterOptions()
    @State private var maiOption: SongListFilterOptions = SongListFilterOptions()
    
    var body: some View {
        VStack {
            List {
                if user.currentMode == 0 && !chuSongList.isEmpty {
                    ForEach(chuSongList, id: \.musicID) { entry in
                        SongItemView(user: user, chuSong: entry)
                    }
                } else if user.currentMode == 1 && !maiSongList.isEmpty {
                    ForEach(maiSongList, id: \.musicId) { entry in
                        SongItemView(user: user, maiSong: entry)
                    }
                }
            }
        }
        .onAppear {
            loadVar()
        }
        .searchable(text: $searchText, prompt: Text("搜索标题或曲师"))
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled(true)
        .navigationTitle("歌曲列表")
        .analyticsScreen(name: "songlist_screen")
        .toolbar {
            NavigationLink(isActive: $showFilterView) {
                SongListFilterView(
                    user: user,
                    selection: user.currentMode == 0 ? $chuOption : $maiOption,
                    showFilterView: $showFilterView
                )
            } label: {
                Image(systemName: "line.3.horizontal.decrease.circle")
            }
        }
        .onChange(of: searchText) { _ in
            refresh()
        }
        .onSubmit(of: .search) {
            refresh()
        }
    }
    
    func loadVar() {
        chuPlayedId = user.chunithm.best.map { entry in entry.associatedSong!.musicID }
        maiPlayedId = user.maimai.best.map { entry in entry.associatedSong!.musicId }
        refresh()
    }
    
    func refresh() {
        if user.currentMode == 0 {
            chuSongList = filterChunithm(option: chuOption)
        } else if user.currentMode == 1 {
            maiSongList = filterMaimai(option: maiOption)
        }
    }
    
    func filterChunithm(option: SongListFilterOptions) -> [ChunithmMusicData] {
        var filteredList = user.data.chunithm.musics
        if option.onlyShowLoved {
            filteredList = filteredList.filter { entry in user.remoteOptions.chunithmFavList.components(separatedBy: ",").contains(String(entry.musicID)) }
        }
        if !searchText.isEmpty {
            filteredList = filteredList.filterTitleAndArtist(keyword: searchText)
        }
        if option.hideNotPlayed {
            filteredList = filteredList.filter { entry in chuPlayedId.contains(entry.musicID) }
        }
        if option.hideWorldsEnd {
            filteredList = filteredList.filter { entry in entry.musicID < 8000 }
        }
        if !option.levelSelection.isEmpty {
            filteredList = filteredList.filter { entry in anyCommonElements(lhs: entry.charts.levels, rhs: option.levelSelection) }
        }
        if !option.versionSelection.isEmpty {
            filteredList = filteredList.filter { entry in option.versionSelection.contains(entry.from) }
        }
        if !option.genreSelection.isEmpty {
            filteredList = filteredList.filter { entry in option.genreSelection.contains(entry.genre) }
        }
        
        
        if !option.sortEnabled { return filteredList }
        switch option.sortBy {
        case .level:
            filteredList = filteredList.sorted { a, b in
                if option.sortOrientation == .descent {
                    return a.charts.enumerated[option.sortDifficulty].numericLevel > b.charts.enumerated[option.sortDifficulty].numericLevel
                } else {
                    return a.charts.enumerated[option.sortDifficulty].numericLevel < b.charts.enumerated[option.sortDifficulty].numericLevel
                }
            }
        case .constant:
            filteredList = filteredList.sorted { a, b in
                if option.sortOrientation == .descent {
                    return a.charts.enumerated[option.sortDifficulty].constant > b.charts.enumerated[option.sortDifficulty].constant
                } else {
                    return a.charts.enumerated[option.sortDifficulty].constant < b.charts.enumerated[option.sortDifficulty].constant
                }
            }
        case .bpm:
            filteredList = filteredList.sorted { a, b in
                if option.sortOrientation == .descent {
                    return a.bpm > b.bpm
                } else {
                    return a.bpm < b.bpm
                }
            }
        }
        return filteredList
    }
    
    func filterMaimai(option: SongListFilterOptions) -> [MaimaiSongData] {
        var filteredList = user.data.maimai.songlist
        if option.onlyShowLoved {
            filteredList = filteredList.filter { entry in user.remoteOptions.maimaiFavList.components(separatedBy: ",").contains(String(entry.musicId)) }
        }
        if !searchText.isEmpty {
            filteredList = filteredList.filterTitleAndArtist(keyword: searchText)
        }
        if option.hideNotPlayed {
            filteredList = filteredList.filter { entry in maiPlayedId.contains(entry.musicId) }
        }
        if option.hideUtage {
            filteredList = filteredList.filter { entry in entry.basicInfo.genre != "宴会場" }
        }
        if !option.levelSelection.isEmpty {
            filteredList = filteredList.filter { entry in anyCommonElements(lhs: entry.level, rhs: option.levelSelection) }
        }
        if !option.versionSelection.isEmpty {
            filteredList = filteredList.filter { entry in option.versionSelection.contains(entry.basicInfo.from) }
        }
        if !option.genreSelection.isEmpty {
            filteredList = filteredList.filter { entry in option.genreSelection.contains(entry.basicInfo.genre) }
        }
        
        if !option.sortEnabled { return filteredList }
        switch option.sortBy {
        case .level:
            filteredList = filteredList.sorted { a, b in
                if a.basicInfo.genre == "宴会場" || b.basicInfo.genre == "宴会場" { return false }
                if option.sortOrientation == .descent {
                    return a.getNumericLevelByLevelIndex(option.sortDifficulty) > a.getNumericLevelByLevelIndex(option.sortDifficulty)
                } else {
                    return a.getNumericLevelByLevelIndex(option.sortDifficulty) < b.getNumericLevelByLevelIndex(option.sortDifficulty)
                }
            }
        case .constant:
            filteredList = filteredList.sorted { a, b in
                if a.basicInfo.genre == "宴会場" || b.basicInfo.genre == "宴会場" { return false }
                if option.sortOrientation == .descent {
                    return a.constants.getOrNull(option.sortDifficulty) > a.constants.getOrNull(option.sortDifficulty)
                } else {
                    return a.constants.getOrNull(option.sortDifficulty) < a.constants.getOrNull(option.sortDifficulty)
                }
            }
        case .bpm:
            filteredList = filteredList.sorted { a, b in
                if option.sortOrientation == .descent {
                    return a.basicInfo.bpm > b.basicInfo.bpm
                } else {
                    return a.basicInfo.bpm < b.basicInfo.bpm
                }
            }
        }
        return filteredList
    }
    
    func searchChunithm(prompt: String) -> [ChunithmMusicData] {
        if prompt.isEmpty {
            return chuSongList
        } else {
            return chuSongList.filterTitleAndArtist(keyword: prompt)
        }
    }
    
    func searchMaimai(prompt: String) -> [MaimaiSongData] {
        if prompt.isEmpty {
            return maiSongList
        } else {
            return maiSongList.filterTitleAndArtist(keyword: prompt)
        }
    }
}
