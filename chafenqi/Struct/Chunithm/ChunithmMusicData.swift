//
//  ChunithmMusicData.swift
//  chafenqi
//
//  Created by xinyue on 2023/5/30.
//

import Foundation

struct ChunithmMusicData: Hashable, Equatable, Codable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(musicID)
    }
    
    static func == (lhs: ChunithmMusicData, rhs: ChunithmMusicData) -> Bool {
        return lhs.musicID == rhs.musicID
    }
    
    struct Charts: Codable {
        struct Chart: Codable {
            var enabled: Bool
            var constant: Double
            var level: String
            var charter: String?
        }
        
        struct WEChart: Codable {
            var enabled: Bool
            var constant: Double
            var level: String
            var charter: String?
            var wetype: String?
            var wediff: Int
        }
        
        var basic: Chart
        var advanced: Chart
        var expert: Chart
        var master: Chart
        var ultima: Chart
        var worldsend: WEChart
        
    }
    var musicID: Int
    var title: String
    var artist: String
    var genre: String
    var bpm: Int
    var from: String
    var charts: Charts
}

extension ChunithmMusicData.Charts {
    var enables: [Bool] {
        [basic.enabled, advanced.enabled, expert.enabled, master.enabled, ultima.enabled, worldsend.enabled]
    }
    var levels: [String] {
        [basic.level, advanced.level, expert.level, master.level, ultima.level, worldsend.enabled ? "\(worldsend.wetype ?? "") ⭐️\(worldsend.wediff)" : ""]
    }
    var constants: [Double] {
        [basic.constant, advanced.constant, expert.constant, master.constant, ultima.constant, worldsend.constant]
    }
    var charters: [String] {
        [basic.charter ?? "", advanced.charter ?? "", expert.charter ?? "", master.charter ?? "", ultima.charter ?? "", worldsend.charter ?? ""]
    }
}

extension ChunithmMusicData {
    var coverURL: URL {
        return ChunithmDataGrabber.getSongCoverUrl(source: 1, musicId: String(self.musicID))
    }
}
