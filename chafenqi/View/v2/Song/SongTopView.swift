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
    
    @State var filters = CFQFilterOptions()
    
    @State var filteredMaiSongs: [MaimaiSongData] = []
    @State var filteredChuSongs: [ChunithmMusicData] = []
    @State var searchText = ""
    
    var body: some View {
        VStack {
            if #available(iOS 15.0, *) {
                List {
                    if (user.currentMode == 0) {
                        ForEach(filteredChuSongs, id: \.musicID) { entry in
                            SongItemView(user: user, chuSong: entry)
                        }
                    } else {
                        ForEach(filteredMaiSongs, id: \.musicId) { entry in
                            SongItemView(user: user, maiSong: entry)
                        }
                    }
                }
                .searchable(text: $searchText, prompt: Text("搜索标题/曲师"))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .onSubmit(of: .search) {
                    filterSongs()
                }
                .onChange(of: searchText) { _ in
                    filterSongs()
                }
                .onAppear {
                    setupFilters()
                    filterSongs()
                }
            } else {
                // Fallback on earlier versions
                List {
                    if (user.currentMode == 0) {
                        ForEach(filteredChuSongs, id: \.musicID) { entry in
                            SongItemView(user: user, chuSong: entry)
                                .id(UUID())
                        }
                    } else {
                        ForEach(filteredMaiSongs, id: \.musicId) { entry in
                            SongItemView(user: user, maiSong: entry)
                                .id(UUID())
                        }
                    }
                }
                .navigationBarSearch($searchText)
                .onChange(of: searchText) { _ in
                    filterSongs()
                }
                .onAppear {
                    setupFilters()
                    filterSongs()
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    RandomSongView(user: user)
                } label: {
                    Image(systemName: "dice")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    SongFilterOptionsView(filters: $filters)
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
        }
        .navigationTitle("歌曲列表")
    }
    
    func filterSongs() {
        if (user.currentMode == 0) {
            if (searchText.isEmpty) {
                filteredChuSongs = user.data.chunithm.musics
            } else {
                filteredChuSongs = user.data.chunithm.musics.filter {
                    $0.title.localizedCaseInsensitiveContains(searchText) ||
                    $0.artist.localizedCaseInsensitiveContains(searchText)
                }
            }
            if filters.hideUnplayChart {
                let playedMusicIDs = user.chunithm.best.compactMap { $0.associatedSong!.musicID }
                filteredChuSongs = filteredChuSongs.filter {
                    playedMusicIDs.contains($0.musicID)
                }
            }
            
            let levelIndices = filters.filterChuLevelToggles.trueIndices
            let genreIndices = filters.filterChuGenreToggles.trueIndices
            let versionIndices = filters.filterChuVersionToggles.trueIndices
            if filters.excludeChuWEChart {
                filteredChuSongs = filteredChuSongs.filter {
                    $0.musicID < 8000
                }
            }
            if !levelIndices.isEmpty {
                filteredChuSongs = filteredChuSongs.filter { song in
                    let levels = levelIndices.compactMap { CFQFilterOptions.levelOptions[$0] }
                    return anyCommonElements(lhs: levels, rhs: song.charts.levels)
                }
            }
            if !genreIndices.isEmpty {
                filteredChuSongs = filteredChuSongs.filter { song in
                    let genres = genreIndices.compactMap { CFQFilterOptions.chuGenreOptions[$0] }
                    return genres.contains(song.genre)
                }
            }
            if !versionIndices.isEmpty {
                filteredChuSongs = filteredChuSongs.filter { song in
                    let versions = versionIndices.compactMap { CFQFilterOptions.chuVersionOptions[$0] }
                    return versions.contains(song.from)
                }
            }
            
            if filters.sortChu {
                if filters.sortChuMethod == .random {
                    filteredChuSongs.shuffle()
                } else {
                    switch filters.sortChuKey {
                    case .level:
                        filteredChuSongs.sort {
                            if filters.sortChuMethod == .descent {
                                return $0.charts.getChartFromLabel(filters.sortChuDiff.rawValue).numericLevel > $1.charts.getChartFromLabel(filters.sortChuDiff.rawValue).numericLevel
                            } else {
                                return $0.charts.getChartFromLabel(filters.sortChuDiff.rawValue).numericLevel < $1.charts.getChartFromLabel(filters.sortChuDiff.rawValue).numericLevel
                            }
                        }
                    case .constant:
                        filteredChuSongs.sort {
                            if filters.sortChuMethod == .descent {
                                return $0.charts.getChartFromLabel(filters.sortChuDiff.rawValue).constant > $1.charts.getChartFromLabel(filters.sortChuDiff.rawValue).constant
                            } else {
                                return $0.charts.getChartFromLabel(filters.sortChuDiff.rawValue).constant < $1.charts.getChartFromLabel(filters.sortChuDiff.rawValue).constant
                            }
                        }
                    case .bpm:
                        filteredChuSongs.sort {
                            if filters.sortChuMethod == .descent {
                                return $0.bpm > $1.bpm
                            } else {
                                return $0.bpm < $1.bpm
                            }
                        }
                    }
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
            
            if filters.hideUnplayChart {
                let playedMusicIds = user.maimai.best.compactMap { $0.associatedSong!.musicId }
                filteredMaiSongs = filteredMaiSongs.filter {
                    playedMusicIds.contains($0.musicId)
                }
            }
            
            let levelIndices = filters.filterMaiLevelToggles.trueIndices
            let genreIndices = filters.filterMaiGenreToggles.trueIndices
            let versionIndices = filters.filterMaiVersionToggles.trueIndices
            if !levelIndices.isEmpty {
                filteredMaiSongs = filteredMaiSongs.filter { song in
                    let levels = levelIndices.compactMap { CFQFilterOptions.levelOptions[$0] }
                    return anyCommonElements(lhs: levels, rhs: song.level)
                }
            }
            if !genreIndices.isEmpty {
                filteredMaiSongs = filteredMaiSongs.filter { song in
                    let genres = genreIndices.compactMap { CFQFilterOptions.maiGenreOptions[$0] }
                    return genres.contains(song.basicInfo.genre)
                }
            }
            if !versionIndices.isEmpty {
                filteredMaiSongs = filteredMaiSongs.filter { song in
                    let versions = versionIndices.compactMap { CFQFilterOptions.maiVersionOptions[$0] }
                    return versions.contains(song.basicInfo.from)
                }
            }
            
            if filters.sortMai {
                if filters.sortMaiMethod == .random {
                    filteredMaiSongs.shuffle()
                } else {
                    switch filters.sortMaiKey {
                    case .level:
                        filteredMaiSongs.sort {
                            if filters.sortMaiMethod == .descent {
                                return $0.getNumericLevelByLabel(filters.sortMaiDiff.rawValue) > $1.getNumericLevelByLabel(filters.sortMaiDiff.rawValue)
                            } else {
                                return $0.getNumericLevelByLabel(filters.sortMaiDiff.rawValue) < $1.getNumericLevelByLabel(filters.sortMaiDiff.rawValue)
                            }
                        }
                    case .constant:
                        filteredMaiSongs.sort {
                            if filters.sortMaiMethod == .descent {
                                return $0.constant[$0.levelLabeltoLevelIndex(filters.sortMaiDiff.rawValue)] > $1.constant[$1.levelLabeltoLevelIndex(filters.sortMaiDiff.rawValue)]
                            } else {
                                return $0.constant[$0.levelLabeltoLevelIndex(filters.sortMaiDiff.rawValue)] < $1.constant[$1.levelLabeltoLevelIndex(filters.sortMaiDiff.rawValue)]
                            }
                        }
                    case .bpm:
                        filteredMaiSongs.sort {
                            if filters.sortMaiMethod == .descent {
                                return $0.basicInfo.bpm > $1.basicInfo.bpm
                            } else {
                                return $0.basicInfo.bpm < $1.basicInfo.bpm
                            }
                        }
                    }
                }
            }
        }
    }
    
    func setupFilters() {
        guard filters.filterChuGenreToggles.isEmpty else { return }
        filters.filterChuGenreToggles = .init(repeating: false, count: CFQFilterOptions.chuGenreOptions.count)
        filters.filterMaiGenreToggles = .init(repeating: false, count: CFQFilterOptions.maiGenreOptions.count)
        filters.filterChuVersionToggles = .init(repeating: false, count: CFQFilterOptions.chuVersionOptions.count)
        filters.filterMaiVersionToggles = .init(repeating: false, count: CFQFilterOptions.maiVersionOptions.count)
        filters.filterChuLevelToggles = .init(repeating: false, count: CFQFilterOptions.levelOptions.count)
        filters.filterMaiLevelToggles = .init(repeating: false, count: CFQFilterOptions.levelOptions.count)
    }
    
    func anyCommonElements <T, U> (lhs: T, rhs: U) -> Bool where T: Sequence, U: Sequence, T.Iterator.Element: Equatable, T.Iterator.Element == U.Iterator.Element {
        for lhsItem in lhs {
            for rhsItem in rhs {
                if lhsItem == rhsItem {
                    return true
                }
            }
        }
        return false
    }
}

struct SongTopView_Previews: PreviewProvider {
    static var previews: some View {
        SongTopView(user: CFQNUser())
    }
}
