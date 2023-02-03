//
//  MaimaiPlayerRecord.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/3.
//

import Foundation

struct MaimaiPlayerRecord: Codable {
    var additionalRating: Int
    var records: Array<MaimaiRecordEntry>
    var username: String
    
    enum CodingKeys: String, CodingKey {
        case additionalRating = "additional_rating"
        case records
        case username
    }
    
    init(){
        additionalRating = 1000
        records = []
        username = "TEST"
    }
}

struct MaimaiRecordEntry: Codable {
    var achievements: Double
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
    
    func getRateString() -> String {
        return rate.replacingOccurrences(of: "p", with: "+").uppercased()
    }
    
    func getStatus() -> String {
        switch (status) {
        case "fc", "ap":
            return status.uppercased()
        case "fcp":
            return "FC+"
        case "app":
            return "AP+"
        default:
            return ""
        }
    }
    
    func getSyncStatus() -> String {
        switch (syncStatus) {
        case "fs":
            return "FS"
        case "fsp":
            return "FS+"
        case "fsd":
            return "FDX"
        case "fsdp":
            return "FDX+"
        default:
            return ""
        }
    }
}
