//
//  MaimaiPlayerRecord.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/3.
//

import Foundation

struct MaimaiPlayerRecord: Codable {
    struct MaimaiRecordEntry: Codable {
        var achievements: String
        var constant: Double
        var dxScore: Int
        var status: String
        var syncStatus: String
        var level: String
        var levelIndex: Int
        var levelLabel: String
        var rating: Int
        var rate: String
        var musicId: Int
        var title: String
        var type: String
        
        enum CodingKeys: String, CodingKey {
            case achievements
            case constant = "ds"
            case dxScore
            case status = "fc"
            case syncStatus = "fs"
            case level
            case levelIndex = "level_index"
            case levelLabel = "level_label"
            case rating = "ra"
            case rate
            case musicId = "song_id"
            case title
            case type
        }
    }
    
    var additionalRating: Int
    var records: Array<MaimaiRecordEntry>
    var username: String
    
    enum CodingKeys: String, CodingKey {
        case additionalRating = "additional_rating"
        case records
        case username
    }
}
