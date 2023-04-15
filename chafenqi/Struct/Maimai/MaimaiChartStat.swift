//
//  MaimaiChartStat.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/3.
//

import Foundation

struct MaimaiChartStatWrapper: Codable {
    var charts: Dictionary<String, Array<MaimaiChartStat>>
}

struct MaimaiChartStat: Codable {
    var playCount: Int?
    var diff: String?
    var fit_diff: Double?
    var averageScore: Double?
    var avg: Double?
    var avg_dx: Double?
    var std_dev: Double?
    var dist: Array<Int>?
    var fc_dist: Array<Int>?
    
    enum CodingKeys: String, CodingKey {
        case playCount = "cnt"
        case averageScore = "avg"
        case diff, fit_diff, avg_dx, dist, fc_dist, std_dev
    }
}
