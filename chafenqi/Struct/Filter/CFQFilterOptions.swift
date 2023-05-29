//
//  CFQFilterOptions.swift
//  chafenqi
//
//  Created by xinyue on 2023/5/29.
//

import Foundation

struct CFQFilterOptions: Codable {
    static var levelOptions: [String] {
        var options: [String] = []
        for i in 1...15 {
            options.append("\(i)")
            if (7...14).contains(i) {
                options.append("\(i)+")
            }
        }
        return options
    }
    
    static let chuGenreOptions = [
        "POPS & ANIME",
        "niconico",
        "\u{6771}\u{65b9}Project",
        "VARIETY",
        "イロドリミドリ",
        "ゲキマイ",
        "ORIGINAL"
    ]
    
    static let maiGenreOptions = [
        "流行&动漫",
        "niconico & VOCALOID",
        "东方Project",
        "其他游戏",
        "舞萌",
        "音击/中二节奏"
    ]
    
    static let maiGenreList = [
        "POPS\u{30a2}\u{30cb}\u{30e1}",
        "niconicoボーカロイド",
        "\u{6771}\u{65b9}Project",
        "ゲームバラエティ",
        "maimai",
        "オンゲキCHUNITHM"
    ]
    
    var filterMaiLevelToggles: [Bool] = .init(repeating: false, count: 23)
    var filterChuLevelToggles: [Bool] = .init(repeating: false, count: 23)
    var filterMaiGenreToggles: [Bool] = .init(repeating: false, count: 6)
    var filterChuGenreToggles: [Bool] = .init(repeating: false, count: 7)
}
