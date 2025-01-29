//
//  UserMaimaiBestScoreEntry.swift
//  chafenqi
//
//  Created by 刘易斯 on 2024/12/05.
//

import Foundation

struct UserMaimaiBestScoreEntry: Codable, Hashable, Equatable {
    let musicId: Int
    let levelIndex: Int
    let type: String
    let achievements: Double
    let dxScore: Int
    let judgeStatus: String
    let syncStatus: String
    let lastModified: Int
    
    var associatedSong: MaimaiSongData?
}

struct UserMaimaiRecentScoreEntry: Codable, Hashable, Equatable {
    let timestamp: Int
    let musicId: Int
    let difficulty: String
    let type: String
    let achievements: Double
    let newRecord: Bool
    let dxScore: Int
    let judgeStatus: String
    let syncStatus: String
    let noteTap: Array<String>
    let noteHold: Array<String>
    let noteSlide: Array<String>
    let noteTouch: Array<String>
    let noteBreak: Array<String>
    let maxCombo: String
    let maxSync: String
    let players: Array<String>
    
    var associatedSong: MaimaiSongData?
}

struct UserMaimaiPlayerInfoEntry: Codable {
    let timestamp: Int
    var nickname: String
    let trophy: String
    let rating: Int
    let maxRating: Int
    let stars: Int
    let charUrl: String
    let gradeUrl: String
    let playCount: Int
    let stats: String
}

typealias UserMaimaiBestScores = [UserMaimaiBestScoreEntry]
typealias UserMaimaiRecentScores = [UserMaimaiRecentScoreEntry]
typealias UserMaimaiPlayerInfos = [UserMaimaiPlayerInfoEntry]
