//
//  MaimaiLeaderboardEntry.swift
//  chafenqi
//
//  Created by 刘易斯 on 2024/06/29.
//

import Foundation

struct MaimaiRatingLeaderboardEntry: Codable {
    var uid: Int = 0
    var username: String = ""
    var nickname: String = ""
    var rating: Int = 0
}
struct MaimaiTotalScoreLeaderboardEntry: Codable {
    var uid: Int = 0
    var username: String = ""
    var nickname: String = ""
    var totalAchievements: Double = 0.0
}
struct MaimaiTotalPlayedLeaderboardEntry: Codable {
    var uid: Int = 0
    var username: String = ""
    var nickname: String = ""
    var totalPlayed: Int = 0
}
struct MaimaiFirstLeaderboardEntry: Codable {
    var uid: Int = 0
    var username: String = ""
    var nickname: String = ""
    var firstCount: Int = 0
}
struct MaimaiFirstLeaderboardMusicEntry: Codable {
    var musicId: Int = 0
    var diffIndex: Int = 0
    var achievements: Double = 0.0
}

struct MaimaiRatingRank: Codable {
    var uid: Int = 0
    var username: String = ""
    var nickname: String = ""
    var rating: Int = 0
    var rank: Int = 0
}
struct MaimaiTotalScoreRank: Codable {
    var uid: Int = 0
    var username: String = ""
    var nickname: String = ""
    var totalAchievements: Double = 0.0
    var rank: Int = 0
}
struct MaimaiTotalPlayedRank: Codable {
    var uid: Int = 0
    var username: String = ""
    var nickname: String = ""
    var totalPlayed: Int = 0
    var rank: Int = 0
}
struct MaimaiFirstRank: Codable {
    var rank: Int = 0
    var firstCount: Int = 0
}

typealias MaimaiRatingLeaderboard = [MaimaiRatingLeaderboardEntry]
typealias MaimaiTotalScoreLeaderboard = [MaimaiTotalScoreLeaderboardEntry]
typealias MaimaiTotalPlayedLeaderboard = [MaimaiTotalPlayedLeaderboardEntry]
typealias MaimaiFirstLeaderboard = [MaimaiFirstLeaderboardEntry]

extension Array<MaimaiFirstLeaderboardMusicEntry> {
    func getFirstPerDifficulty() -> [Int] {
        // Basic, Advanced, Expert, Master, Re:Master
        var diffCount = [0, 0, 0, 0, 0]
        self.forEach { music in
            if music.diffIndex <= 4 && music.diffIndex >= 0 {
                diffCount[music.diffIndex] += 1
            }
        }
        return diffCount
    }
}
