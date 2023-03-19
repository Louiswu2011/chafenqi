//
//  CFQSonglist.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/3/18.
//

import Foundation
import SwiftUI

class CFQPersistentData: ObservableObject {
    @Published var chunithm: Chunithm = Chunithm()
    @Published var maimai: Maimai = Maimai()
    
    var shouldReload = true
    
    struct Chunithm {
        @AppStorage("loadedChunithmSongs") var loadedSongs: Data = Data()
        @AppStorage("chartIDMap") var mapData = Data()
        
        var songs: Array<ChunithmSongData> = []
    }
    
    struct Maimai {
        @AppStorage("loadedMaimaiChartStats") var loadedStats: Data = Data()
        @AppStorage("loadedMaimaiSongs") var loadedSongs: Data = Data()
        @AppStorage("loadedMaimaiRanking") var loadedRanking: Data = Data()
        
        var songlist: Array<MaimaiSongData> = []
        var chartStats: Dictionary<String, Array<MaimaiChartStat>> = [:]
        var ranking: Array<MaimaiPlayerRating> = []
    }
    
    private func updateChunithm() async throws {
        try await self.chunithm.loadedSongs = JSONEncoder().encode(ChunithmDataGrabber.getSongDataSetFromServer())

        self.chunithm.songs = try JSONDecoder().decode(Array<ChunithmSongData>.self, from: self.chunithm.loadedSongs)
        
        var decoded = try JSONDecoder().decode(Array<ChunithmSongData>.self, from: self.chunithm.loadedSongs)
        decoded = decoded.filter { $0.constant != [0.0, 0.0, 0.0, 0.0, 0.0, 0.0] && $0.constant != [0.0] }
        self.chunithm.loadedSongs = try JSONEncoder().encode(decoded)
        self.chunithm.songs = decoded
        
        let path = Bundle.main.url(forResource: "IdMap", withExtension: "json")
        self.chunithm.mapData = try Data(contentsOf: path!)
    }
    
    private func updateMaimai() async throws {
        self.maimai.loadedSongs = try await MaimaiDataGrabber.getMusicData()
        self.maimai.loadedStats = try await MaimaiDataGrabber.getChartStat()
        self.maimai.loadedRanking = try await MaimaiDataGrabber.getRatingRanking()
        
        self.maimai.songlist = try JSONDecoder().decode(Array<MaimaiSongData>.self, from: self.maimai.loadedSongs)
        self.maimai.chartStats = try JSONDecoder().decode(Dictionary<String, Array<MaimaiChartStat>>.self, from: self.maimai.loadedStats)
        self.maimai.ranking = try JSONDecoder().decode(Array<MaimaiPlayerRating>.self, from: self.maimai.loadedRanking)
    }
    
    func update() async throws {
        guard shouldReload else { return }
        
        try await updateChunithm()
        try await updateMaimai()
        
        shouldReload = false
    }
    
    func refresh() async throws {
        shouldReload = true
        try await update()
    }
}
