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

extension ChunithmMusicData.Charts.Chart {
    func getNumericLevel(for level: String) -> Double {
        var numericLevel: Double = Double(level.replacingOccurrences(of: "+", with: "")) ?? 0.0
        if level.contains("+") {
            numericLevel += 0.5
        }
        return numericLevel
    }
    
    var numericLevel: Double {
        getNumericLevel(for: self.level)
    }
}

extension ChunithmMusicData.Charts {
    var enables: [Bool] {
        [basic.enabled, advanced.enabled, expert.enabled, master.enabled, ultima.enabled, worldsend.enabled]
    }
    var levels: [String] {
        [basic.level, advanced.level, expert.level, master.level, ultima.level, worldsend.enabled ? "\(worldsend.wetype ?? "") ⭐️\(worldsend.wediff)" : ""]
    }
    var numericLevels: [Double] {
        [basic.numericLevel, expert.numericLevel, master.numericLevel, ultima.numericLevel]
    }
    var constants: [Double] {
        [basic.constant, advanced.constant, expert.constant, master.constant, ultima.constant, worldsend.constant]
    }
    var charters: [String] {
        [basic.charter ?? "", advanced.charter ?? "", expert.charter ?? "", master.charter ?? "", ultima.charter ?? "", worldsend.charter ?? ""]
    }
    
    func getChartFromLabel(_ string: String) -> Chart {
        switch string {
        case "Basic":
            return self.basic
        case "Advanced":
            return self.advanced
        case "expert":
            return self.expert
        case "master":
            return self.master
        default:
            return self.ultima
        }
    }
}

extension ChunithmMusicData {
    var coverURL: URL {
        return ChunithmDataGrabber.getSongCoverUrl(source: 1, musicId: String(self.musicID))
    }
}
