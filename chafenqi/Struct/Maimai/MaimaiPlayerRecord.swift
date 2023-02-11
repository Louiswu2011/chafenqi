//
//  MaimaiPlayerRecord.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/3.
//

import Foundation
import SwiftUI

let remasterColor = Color(red: 224 / 255, green: 217 / 255, blue: 230 / 255)

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
    
    func getPastSlice(songData: Array<MaimaiSongData>) -> ArraySlice<MaimaiRecordEntry> {
        let slice = records.filter { songData.filter { $0.basicInfo.isNew == false }.compactMap { Int($0.musicId)! }.contains( $0.musicId ) }.sorted { $0.rating > $1.rating }
        let length = slice.count > 24 ? 25 : slice.count
        return slice.prefix(upTo: length)
    }
    
    func getCurrentSlice(songData: Array<MaimaiSongData>) -> ArraySlice<MaimaiRecordEntry> {
        let slice = records.filter { songData.filter { $0.basicInfo.isNew == true }.compactMap { Int($0.musicId)! }.contains( $0.musicId ) }.sorted { $0.rating > $1.rating }
        let length = slice.count > 14 ? 15 : slice.count
        return slice.prefix(upTo: length)
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
    
    func getClearBadgeColor() -> Color {
        switch (self.status) {
        case "fc", "fcp":
            return Color.blue.opacity(0.9)
        case "ap", "app":
            return Color.yellow
        default:
            return Color.red
        }
    }
    
    func getLevelColor() -> Color {
        switch (self.levelIndex) {
        case 0:
            return Color.green
        case 1:
            return Color.yellow
        case 2:
            return Color.red
        case 3:
            return Color.purple
        case 4:
            return Color(red: 171 / 255, green: 147 / 255, blue: 191 / 255)
        default:
            return Color.purple
        }
    }
}
