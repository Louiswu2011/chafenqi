//
//  ChunithmMusicData.swift
//  chafenqi
//
//  Created by xinyue on 2023/5/30.
//

import Foundation

struct ChunithmMusicData: Codable {
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
