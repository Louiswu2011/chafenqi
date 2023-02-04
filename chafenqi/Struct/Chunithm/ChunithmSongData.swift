//
//  SongData.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/8.
//

import Foundation

struct ChunithmSongData: Hashable, Equatable, Codable, Comparable {
    static func < (lhs: ChunithmSongData, rhs: ChunithmSongData) -> Bool {
        return lhs.id < rhs.id
    }
    
    
    struct ChunithmSongBasicInfo: Codable {
        var title: String
        var artist: String
        var genre: String
        var bpm: Int
        var from: String
    }
    
    struct ChunithmSongChartData: Codable {
        var combo: Int
        var charter: String
    }
    
    var id: Int
    var title: String
    var constant: Array<Double>
    var level: Array<String>
    var chartID: Array<Int>
    var charts: Array<ChunithmSongChartData>
    var basicInfo: ChunithmSongBasicInfo
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        title = try values.decode(String.self, forKey: CodingKeys.title)
        constant = try values.decode(Array<Double>.self, forKey: CodingKeys.constant)
        level = try values.decode(Array<String>.self, forKey: CodingKeys.level)
        chartID = try values.decode(Array<Int>.self, forKey: CodingKeys.chardID)
        charts = try values.decode(Array<ChunithmSongChartData>.self, forKey: CodingKeys.charts)
        basicInfo = try values.decode(ChunithmSongBasicInfo.self, forKey: CodingKeys.basicInfo)
    }
    
    enum CodingKeys: String, CodingKey {
        case constant = "ds"
        case chardID = "cids"
        case basicInfo = "basic_info"
        case id, title, level, charts
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(constant, forKey: .constant)
        try container.encode(level, forKey: .level)
        try container.encode(chartID, forKey: .chardID)
        try container.encode(charts, forKey: .charts)
        try container.encode(basicInfo, forKey: .basicInfo)
    }
    
    static func == (lhs: ChunithmSongData, rhs: ChunithmSongData) -> Bool {
        return lhs.id == rhs.id
    }
}




