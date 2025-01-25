//
//  CFQSonglist.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/3/18.
//

import Foundation
import SwiftUI
import FirebasePerformance

class CFQPersistentData: ObservableObject {
    @Published var chunithm: Chunithm = Chunithm()
    @Published var maimai: Maimai = Maimai()
    
    var shouldReload = true
    
    static let decoder = JSONDecoder()
    
    struct Chunithm {
        @AppStorage("loadedChunithmMusics") var loadedMusics: Data = Data()
        @AppStorage("chartIDMap") var mapData = Data()
        var musics: Array<ChunithmMusicData> = []
        
        static func hasCache() -> Bool {
            @AppStorage("loadedChunithmMusics") var loadedMusics: Data = Data()
            return !loadedMusics.isEmpty
        }
    }
    
    struct Maimai {
        @AppStorage("loadedMaimaiSongs") var loadedSongs: Data = Data()
        @AppStorage("loadedMaimaiVersions") var loadedVersions: Data = Data()
        @AppStorage("loadedMaimaiGenres") var loadedGenres: Data = Data()
        
        var songlist: Array<MaimaiSongData> = []
        var versionList: Array<MaimaiVersionData> = []
        var genreList: Array<MaimaiGenreData> = []
        
        static func hasCache() -> Bool {
            @AppStorage("loadedMaimaiSongs") var loadedSongs: Data = Data()
            @AppStorage("loadedMaimaiVersions") var loadedVersions: Data = Data()
            @AppStorage("loadedMaimaiGenres") var loadedGenres: Data = Data()
            
            return !loadedSongs.isEmpty && !loadedVersions.isEmpty && !loadedGenres.isEmpty
        }
    }
    
    private func loadChunithm() async throws {
        self.chunithm.musics = try JSONDecoder().decode(Array<ChunithmMusicData>.self, from: self.chunithm.loadedMusics)
        
        let path = Bundle.main.url(forResource: "IdMap", withExtension: "json")
        self.chunithm.mapData = try Data(contentsOf: path!)
    }
    
    private func reloadChunithm() async throws {
        try await self.chunithm.loadedMusics = CFQChunithmServer.fetchMusicData()
        
        self.chunithm.musics = try JSONDecoder().decode(Array<ChunithmMusicData>.self, from: self.chunithm.loadedMusics)
        
        let path = Bundle.main.url(forResource: "IdMap", withExtension: "json")
        self.chunithm.mapData = try Data(contentsOf: path!)
    }
    
    private func loadMaimai() async throws {
        self.maimai.songlist = try CFQPersistentData.decoder.decode(Array<MaimaiSongData>.self, from: self.maimai.loadedSongs)
        self.maimai.versionList = try CFQPersistentData.decoder.decode(Array<MaimaiVersionData>.self, from: self.maimai.loadedVersions)
        self.maimai.genreList = try CFQPersistentData.decoder.decode(Array<MaimaiGenreData>.self, from: self.maimai.loadedGenres)
    }
    
    private func reloadMaimai() async throws {
        self.maimai.loadedSongs = try await CFQMaimaiServer.fetchMusicData()
        self.maimai.loadedVersions = try await CFQMaimaiServer.fetchVersionData()
        self.maimai.loadedGenres = try await CFQMaimaiServer.fetchGenreData()
        
        self.maimai.songlist = try JSONDecoder().decode(Array<MaimaiSongData>.self, from: self.maimai.loadedSongs)
        self.maimai.versionList = try JSONDecoder().decode(Array<MaimaiVersionData>.self, from: self.maimai.loadedVersions)
        self.maimai.genreList = try JSONDecoder().decode(Array<MaimaiGenreData>.self, from: self.maimai.loadedGenres)
    }
    
    func update() async throws {
        let updateTrace = Performance.startTrace(name: "update_persistent_data")
        try await reloadMaimai()
        try await reloadChunithm()
        
        shouldReload = false
        updateTrace?.stop()
    }
    
    func loadFromCache() async throws {
        try await loadMaimai()
        try await loadChunithm()
        
        shouldReload = false
    }
    
    func refresh() async throws {
        shouldReload = true
        try await update()
    }
    
    static func loadFromCacheOrRefresh(user: CFQNUser) async throws -> CFQPersistentData {
        let data = CFQPersistentData()
        
        if user.shouldAutoUpdateSongList {
            // Check for new updates
            let latestMai = await CFQStatsServer.checkSongListVersion(tag: "maimai_song_list")
            let latestChu = await CFQStatsServer.checkSongListVersion(tag: "chunithm_song_list")
            
            if user.maimaiSongListVersion != latestMai || user.chunithmSongListVersion != latestChu {
                print("[CFQPersistentData] New data found, downloading...")
                try await data.update()
                DispatchQueue.main.async {
                    user.maimaiSongListVersion = latestMai
                    user.chunithmSongListVersion = latestChu
                }
                return data
            }
            print("[CFQPersistentData] Music data is up to date.")
        } else {
            print("[CFQPersistentData] Auto update skipped by user.")
        }
        
        if (Maimai.hasCache() && Chunithm.hasCache()) {
            try await data.loadFromCache()
            data.shouldReload = false
            print("[CFQPersistentData] Persistent data cache loaded.")
            return data
        } else {
            try await data.update()
            print("[CFQPersistentData] Persistent data downloaded.")
            return data
        }
    }
    
    static func forceRefresh() async throws -> CFQPersistentData {
        let data = CFQPersistentData()
        try await data.update()
        print("[CFQPersistentData] Persistent data downloaded.")
        return data
    }
}
