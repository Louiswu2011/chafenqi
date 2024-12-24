//
//  UserChunithmEntry.swift
//  chafenqi
//
//  Created by 刘易斯 on 2024/12/24.
//

import Foundation

struct UserChunithmBestScoreEntry: Codable, Hashable, Equatable {
    let musicId: Int
    let levelIndex: Int
    let score: Int
    let rankIndex: Int
    let clearStatus: String
    let judgeStatus: String
    let chainStatus: String
    let lastModified: Int
    
    var associatedSong: ChunithmMusicData?
}

struct UserChunithmRecentScoreEntry: Codable, Hashable, Equatable {
    let timestamp: Int
    let musicId: Int
    let difficulty: String
    let score: Int
    let newRecord: Bool
    let judgeCritical: Int
    let judgeJustice: Int
    let judgeAttact: Int
    let judgeMiss: Int
    let noteTap: Int
    let noteHold: Int
    let noteSlide: Int
    let noteAir: Int
    let noteFlick: Int
    let rankIndex: Int
    let clearStatus: String
    let judgeStatus: String
    let chainStatus: String
    
    var associatedSong: ChunithmMusicData?
}

struct UserChunithmRatingListEntry: Codable, Hashable, Equatable {
    let index: Int
    let musicId: Int
    let score: Int
    let levelIndex: Int
    
    var associatedSong: ChunithmMusicData?
}

struct UserChunithmRatingList: Codable, Hashable, Equatable {
    let best: [UserChunithmRatingListEntry]
    let recent: [UserChunithmRatingListEntry]
    let candidate: [UserChunithmRatingListEntry]
}

struct UserChunithmPlayerInfo: Codable, Hashable, Equatable {
    let timestamp: Int
    let nickname: String
    let level: String
    let trophy: String
    let plate: String
    let dan: Int
    let ribbon: Int
    let rating: Double
    let maxRating: Double
    let rawOverpower: Double
    let percentOverpower: Double
    let lastPlayedDate: Int
    let friendCode: String
    let currentGold: Int
    let totalGold: Int
    let playCount: Int
    let charName: String
    let charUrl: String
    let charRank: String
    let charExp: Double
    let charIllust: String
    let ghostStatue: Int
    let silverStatue: Int
    let goldStatue: Int
    let rainbowStatue: Int
}

typealias UserChunithmBestScores = [UserChunithmBestScoreEntry]
typealias UserChunithmRecentScores = [UserChunithmRecentScoreEntry]
typealias UserChunithmPlayerInfos = [UserChunithmPlayerInfo]
