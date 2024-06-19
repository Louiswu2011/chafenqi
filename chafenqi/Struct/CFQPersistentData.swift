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
        
        var songlist: Array<MaimaiSongData> = []
        
        static func hasCache() -> Bool {
            @AppStorage("loadedMaimaiSongs") var loadedSongs: Data = Data()
            return !loadedSongs.isEmpty
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
        self.maimai.songlist = try JSONDecoder().decode(Array<MaimaiSongData>.self, from: self.maimai.loadedSongs)
    }
    
    private func reloadMaimai() async throws {
        self.maimai.loadedSongs = try await CFQMaimaiServer.fetchMusicData()
        
        self.maimai.songlist = try JSONDecoder().decode(Array<MaimaiSongData>.self, from: self.maimai.loadedSongs)
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
            let latestMai = await CFQStatsServer.checkSongListVersion(game: .Maimai)
            let latestChu = await CFQStatsServer.checkSongListVersion(game: .Chunithm)
            
            if user.maimaiSongListVersion < latestMai || user.chunithmSongListVersion < latestChu {
                print("[CFQPersistentData] New data found, downloading...")
                try await data.update()
                user.maimaiSongListVersion = latestMai
                user.chunithmSongListVersion = latestChu
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
