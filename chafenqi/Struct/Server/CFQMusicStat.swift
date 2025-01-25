//
//  CFQMusicStat.swift
//  chafenqi
//
//  Created by Louis Wu on 2025/01/26.
//

import Foundation

struct CFQMusicStat: Codable {
    var musicId: Int = 0
    var difficulty: Int = 0
    var totalPlayed: Int = 0
    var totalFullCombo: Int = 0
    var totalAllJustice: Int = 0
    var totalFullChain: Int = 0
    var totalScore: Double = 0.0
    var ssspSplit: Int = 0
    var sssSplit: Int = 0
    var sspSplit: Int = 0
    var ssSplit: Int = 0
    var spSplit: Int = 0
    var sSplit: Int = 0
    var otherSplit: Int = 0
    var highestScore: Double = 0.0
    var highestPlayer: String = ""
    var highestPlayerNickname: String = ""
}
