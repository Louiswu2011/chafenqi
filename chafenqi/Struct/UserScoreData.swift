//
//  UserScoreData.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/17.
//

import Foundation

struct UserScoreData: Codable {
    struct ScoreEntry: Codable {
        var chartID: Int
        var constant: Double
        var status: String
        var level: String
        var levelIndex: Int
        var levelLabel: String
        var musicID: Int
        var rating: Double
        var score: Int
        var title: String
        
        enum CodingKeys: String, CodingKey{
            case chartID = "cid"
            case constant = "ds"
            case status = "fc"
            case levelIndex = "level_index"
            case levelLabel = "level_label"
            case musicID = "mid"
            case rating = "ra"
            case level, score, title
        }
    }
    
    struct ScoreRecord: Codable {
        var b30: Array<ScoreEntry>
        var r10: Array<ScoreEntry>
    }
    
    var nickname: String
    var rating: Double
    var records: ScoreRecord
    var username: String
    
    init() {
        nickname = "CHUNITHM"
        rating = 17.10
        records = ScoreRecord(b30: Array<ScoreEntry>(), r10: Array<ScoreEntry>())
        username = "CHUNITHM"
    }
}
