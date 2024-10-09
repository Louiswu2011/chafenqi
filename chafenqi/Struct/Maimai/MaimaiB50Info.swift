//
//  MaimaiB50Info.swift
//  chafenqi
//
//  Created by 刘易斯 on 2024/10/09.
//

import Foundation

struct MaimaiB50Info: Codable {
    var username: String = ""
    var info: MaimaiB50Detail = MaimaiB50Detail()
}

struct MaimaiB50Detail: Codable {
    var rating: Int = 0
    var newRating: Int = 0
    var pastRating: Int = 0
    var nickname: String = ""
    var b35: Array<MaimaiB50Entry> = []
    var b15: Array<MaimaiB50Entry> = []
}

struct MaimaiB50Entry: Codable {
    var index: Int = 0
    var title: String = ""
    var level: String = ""
    var achievements: Double = 0.0
    var constant: Double = 0.0
    var rating: Int = 0
    var fc: String = ""
    var diffIndex: Int = 0
    var musicId: String = ""
}
