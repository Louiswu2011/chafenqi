//
//  MaimaiMusicData.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/3.
//

import Foundation
import SwiftUI

struct MaimaiSongData: Codable, Hashable, Comparable {
    static func < (lhs: MaimaiSongData, rhs: MaimaiSongData) -> Bool {
        lhs.musicId < rhs.musicId
    }
    
    static func == (lhs: MaimaiSongData, rhs: MaimaiSongData) -> Bool {
        lhs.musicId == rhs.musicId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(musicId)
    }
    
    struct MaimaiSongChartData: Codable {
        var notes: Array<Int>
        var charter: String
    }

    struct MaimaiSongBasicInfo: Codable {
        var title: String
        var artist: String
        var genre: String
        var bpm: Int
        var releaseDate: String
        var from: String
        var isNew: Bool
        
        enum CodingKeys: String, CodingKey {
            case title
            case artist
            case genre
            case bpm
            case releaseDate = "release_date"
            case from
            case isNew = "is_new"
        }
    }
    
    var musicId: String
    var title: String
    var type: String
    var constant: Array<Double>
    var level: Array<String>
    var chartId: Array<Int>
    var charts: Array<MaimaiSongChartData>
    var basicInfo: MaimaiSongBasicInfo
    
    enum CodingKeys: String, CodingKey {
        case musicId = "id"
        case title
        case type
        case constant = "ds"
        case level
        case chartId = "cids"
        case charts
        case basicInfo = "basic_info"
    }
    
    func getLevelColor(index: Int) -> Color {
        switch (index) {
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

extension MaimaiSongData {
    var coverURL: URL {
        return MaimaiDataGrabber.getSongCoverUrl(source: 0, coverId: getCoverNumber(id: self.musicId))
    }
}
