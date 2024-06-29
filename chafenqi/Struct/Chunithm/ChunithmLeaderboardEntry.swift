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

typealias ChunithmRatingLeaderboard = [ChunithmRatingLeaderboardEntry]
typealias ChunithmTotalScoreLeaderboard = [ChunithmTotalScoreLeaderboardEntry]
typealias ChunithmTotalPlayedLeaderboard = [ChunithmTotalPlayedLeaderboardEntry]
