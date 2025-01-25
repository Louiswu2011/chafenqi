//
//  ChunithmLeaderboardEntry.swift
//  chafenqi
//
//  Created by 刘易斯 on 2024/06/29.
//

import Foundation

struct ChunithmRatingLeaderboardEntry: Codable {
    var uid: Int = 0
    var username: String = ""
    var nickname: String = ""
    var rating: Double = 0.0
}
struct ChunithmTotalScoreLeaderboardEntry: Codable {
    var uid: Int = 0
    var username: String = ""
    var nickname: String = ""
    var totalScore: Int = 0
}
struct ChunithmTotalPlayedLeaderboardEntry: Codable {
    var uid: Int = 0
    var username: String = ""
    var nickname: String = ""
    var totalPlayed: Int = 0
}
struct ChunithmFirstLeaderboardEntry: Codable {
    var uid: Int = 0
    var username: String = ""
    var nickname: String = ""
    var firstCount: Int = 0
}
struct ChunithmFirstLeaderboardMusicEntry: Codable {
    var musicId: Int = 0
    var diffIndex: Int = 0
    var score: Int = 0
}

struct ChunithmRatingRank: Codable {
    var uid: Int = 0
    var username: String = ""
    var nickname: String = ""
    var rating: Double = 0.0
    var rank: Int = 0
}
struct ChunithmTotalScoreRank: Codable {
    var uid: Int = 0
    var username: String = ""
    var nickname: String = ""
    var totalScore: Int = 0
    var rank: Int = 0
}
struct ChunithmTotalPlayedRank: Codable {
    var uid: Int = 0
    var username: String = ""
    var nickname: String = ""
    var totalPlayed: Int = 0
    var rank: Int = 0
}
struct ChunithmFirstRank: Codable {
    var rank: Int = 0
    var firstCount: Int = 0
}

typealias ChunithmRatingLeaderboard = [ChunithmRatingLeaderboardEntry]
typealias ChunithmTotalScoreLeaderboard = [ChunithmTotalScoreLeaderboardEntry]
typealias ChunithmTotalPlayedLeaderboard = [ChunithmTotalPlayedLeaderboardEntry]
typealias ChunithmFirstLeaderboard = [ChunithmFirstLeaderboardEntry]

extension Array<ChunithmFirstLeaderboardMusicEntry> {
    func getFirstPerDifficulty() -> [Int] {
        // Basic, Advanced, Expert, Master, Ultima
        var diffCount = [0, 0, 0, 0, 0]
        self.forEach { music in
            if music.diffIndex <= 4 && music.diffIndex >= 0 {
                diffCount[music.diffIndex] += 1
            }
        }
        return diffCount
    }
}
