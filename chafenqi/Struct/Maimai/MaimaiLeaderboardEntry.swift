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

typealias MaimaiRatingLeaderboard = [MaimaiRatingLeaderboardEntry]
typealias MaimaiTotalScoreLeaderboard = [MaimaiTotalScoreLeaderboardEntry]
typealias MaimaiTotalPlayedLeaderboard = [MaimaiTotalPlayedLeaderboardEntry]
