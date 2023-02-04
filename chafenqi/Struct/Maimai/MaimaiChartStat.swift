//
//  MaimaiChartStat.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/3.
//

import Foundation

struct MaimaiChartStat: Codable {
    var playCount: Int?
    var averageScore: Double?
    var ssspCount: Int?
    var tag: String?
    var diffRanking: Int?
    var diffTotal: Int?
    
    enum CodingKeys: String, CodingKey {
        case playCount = "count"
        case averageScore = "avg"
        case ssspCount = "sssp_count"
        case tag
        case diffRanking = "v"
        case diffTotal = "t"
    }
}
