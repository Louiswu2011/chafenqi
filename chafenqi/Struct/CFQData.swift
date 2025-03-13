//
//  CFQData.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/5/4.
//

import Foundation

struct CFQData: Codable {
    struct FishToken: Codable {
        var uid: Int
        var token: String
    }
    
    struct Maimai: Codable {
        static func assignAssociated(songs: [MaimaiSongData], bests: [UserMaimaiBestScoreEntry]) -> [UserMaimaiBestScoreEntry] {
            var b = bests
            for (i,entry) in b.enumerated() {
                var e = entry
                e.associatedSong = songs.first { $0.musicId == entry.musicId && $0.type == entry.type }
                b[i] = e
            }
            return b
        }
        
        static func assignAssociated(songs: [MaimaiSongData], recents: [UserMaimaiRecentScoreEntry]) -> [UserMaimaiRecentScoreEntry] {
            var r = recents
            for (i,entry) in r.enumerated() {
                var e = entry
                e.associatedSong = songs.first { $0.musicId == entry.musicId && $0.type == entry.type }
                r[i] = e
            }
            return r
        }
        
        struct LeaderboardEntry: Codable {
            var index: Int = 0
            var uid: Int = 0
            var username: String = ""
            var nickname: String = ""
            var achievements: Double = 0.0
            var judgeStatus: String = ""
            var syncStatus: String = ""
            var timestamp: Int = 0
        }
    }
    
    struct Chunithm: Codable {
        static func assignAssociated(songs: [ChunithmMusicData], bests: UserChunithmBestScores) -> UserChunithmBestScores {
            var b = bests
            for (i,entry) in b.enumerated() {
                let searched = songs.first {
                    $0.musicID == entry.musicId
                }
                if let song = searched {
                    var e = entry
                    e.associatedSong = song
                    b[i] = e
                }
            }
            return b
        }
        
        static func assignAssociated(songs: [ChunithmMusicData], recents: UserChunithmRecentScores) -> UserChunithmRecentScores {
            var r = recents
            for (i,entry) in r.enumerated() {
                if entry.difficulty == "worldsend" {
                    let filtered = songs.filter {
                        $0.musicID >= 8000
                    }
                    let searched = filtered.first {
                        $0.musicID == entry.musicId
                    }
                    if let song = searched {
                        var e = entry
                        e.associatedSong = song
                        r[i] = e
                    }
                } else {
                    let searched = songs.first {
                        $0.musicID == entry.musicId
                    }
                    if let song = searched {
                        var e = entry
                        e.associatedSong = song
                        r[i] = e
                    }
                }
            }
            return r
        }
        
        static func assignAssociated(bests: UserChunithmBestScores, ratings: UserChunithmRatingList) -> UserChunithmRatingList {
            func assign(bests: UserChunithmBestScores, ratings: [UserChunithmRatingListEntry]) -> [UserChunithmRatingListEntry] {
                var r = ratings
                for (i, entry) in r.enumerated() {
                    let searched = bests.first {
                        $0.musicId == entry.musicId && $0.levelIndex == entry.levelIndex
                    }
                    if let song = searched {
                        var e = entry
                        e.associatedBestEntry = song
                        r[i] = e
                    }
                }
                return r
            }
            
            return UserChunithmRatingList(best: assign(bests: bests, ratings: ratings.best), recent: assign(bests: bests, ratings: ratings.recent), candidate: assign(bests: bests, ratings: ratings.candidate))
        }
        
        struct MusicStatEntry: Codable {
            var idx: Int = 0
            var diff: Int = 0
            var totalPlayed: Int = 0
            var totalFullCombo: Int = 0
            var totalAllJustice: Int = 0
            var totalScore: Double = 0
            var ssspSplit: Int = 0
            var sssSplit: Int = 0
            var sspSplit: Int = 0
            var ssSplit: Int = 0
            var spSplit: Int = 0
            var sSplit: Int = 0
            var otherSplit: Int = 0
            var highestScore: Double = 0
            var highestPlayer: String = ""
            var highestPlayerNickname: String = ""
            var updatedAt: String = ""
            var createdAt: String = ""
        }
        
        struct LeaderboardEntry: Codable {
            var index: Int = 0
            var uid: Int = 0
            var username: String = ""
            var nickname: String = ""
            var score: Int = 0
            var rankIndex: Int = 0
            var clearStatus: String = ""
            var judgeStatus: String = ""
            var chainStatus: String = ""
            var timestamp: Int = 0
        }
    }
}

protocol CFQMaimaiCalculatable {
    var rateString: String { get }
    var rating: Int { get }
    var status: String { get }
    func getRating(constant: Double, achievements: Double) -> Int
    func getStatus(_ fc: String) -> String
}

extension CFQMaimaiCalculatable {
    func getRating(constant: Double, achievements: Double) -> Int {
        let ratingDict = [
            100.5000...101.0000:22.4,
            100.0000...100.4999:21.6,
            99.5000...99.9999:21.1,
            99.0000...99.4999:20.8,
            98.0000...98.9999:20.3,
            97.0000...97.9999:20.0,
            94.0000...96.9999:16.8
        ]
        var factor = 0.0
        for range in ratingDict.keys {
            if (range.contains(achievements)) {
                factor = ratingDict[range]!
            }
        }
        if (factor == 0.0) {
            factor = (achievements / 10).rounded(.down)
        }
        let rating = Int((constant * min(achievements, 100.5) * factor / 100).rounded(.down))
        return rating
        
        // 312.59488896
        // 324.1728
    }
    
    func getRateStringFromScore(_ score: Double) -> String {
        switch (score) {
        case ...49.9999:
            return "D"
        case 50.0000...59.0000:
            return "C"
        case 60.0000...69.9999:
            return "B"
        case 70.0000...74.9999:
            return "BB"
        case 75.0000...79.9999:
            return "BBB"
        case 80.0000...89.9999:
            return "A"
        case 90.0000...93.0000:
            return "AA"
        case 94.0000...96.9999:
            return "AAA"
        case 97.0000...97.9999:
            return "S"
        case 98.0000...98.9999:
            return "S+"
        case 99.0000...99.4999:
            return "SS"
        case 99.5000...99.9999:
            return "SS+"
        case 100.0000...100.4999:
            return "SSS"
        case 100.5000...:
            return "SSS+"
        default:
            return "?"
        }
    }
    
    func getRateString(_ rate: String) -> String {
        return rate.replacingOccurrences(of: "p", with: "+").uppercased()
    }
    
    func getStatus(_ fc: String) -> String {
        if fc.contains("dummy") { return "" }
        return fc.replacingOccurrences(of: "plus", with: "+").uppercased()
    }
}

extension UserMaimaiBestScoreEntry: CFQMaimaiCalculatable {
    var rateString: String {
        getRateStringFromScore(self.achievements)
    }
    
    var rating: Int {
        guard let song = self.associatedSong else {
            Logger.shared.warning("Nil was found when calculating maimai song rating.")
            return 0
        }
        
        guard let constant = song.constants[orNil: self.levelIndex] else {
            Logger.shared.warning("Cannot find constant for song \(song.title), level index \(self.levelIndex)")
            return 0
        }
        
        return getRating(constant: constant, achievements: self.achievements)
    }
    var status: String {
        getStatus(self.judgeStatus)
    }
}
extension UserMaimaiRecentScoreEntry: CFQMaimaiCalculatable {
    var rateString: String { self.getRateStringFromScore(self.achievements) }
    var levelIndex: Int {
        switch self.difficulty.lowercased() {
        case "basic":
            return 0
        case "advanced":
            return 1
        case "expert":
            return 2
        case "master":
            return 3
        default:
            return 4
        }
    }
    var rating: Int {
        guard let song = self.associatedSong else {
            return 0
        }
        
        guard let constant = song.constants[orNil: self.levelIndex] else {
            return 0
        }
        
        return getRating(constant: constant, achievements: self.achievements)
    }
    var status: String {
        getStatus(self.judgeStatus)
    }
}
extension CFQData.Maimai.LeaderboardEntry: CFQMaimaiCalculatable {
    var rating: Int {
        0
    }
    
    var status: String {
        getStatus(self.judgeStatus)
    }
    
    var rateString: String { self.getRateStringFromScore(self.achievements) }
}

protocol CFQChunithmCalculatable {
    var rating: Double {get}
    var grade: String {get}
    var status: String {get}
    func getRating(constant: Double, score: Int) -> Double
    func getGrade(_ score: Int) -> String
    func getDescribingStatus(_ fc: String) -> String
}

extension CFQChunithmCalculatable {
    func getRating(constant: Double, score: Int) -> Double {
        var rating: Double {
            switch (score) {
            case 925000...949999:
                return constant - 3.0 + Double(score - 950000) * 3 / 50000
            case 950000...974999:
                return constant - 1.5 + Double(score - 950000) * 3 / 50000
            case 975000...999999:
                return constant + Double(score - 975000) / 2500 * 0.1
            case 1000000...1004999:
                return constant + 1.0 + Double(score - 1000000) / 1000 * 0.1
            case 1005000...1007499:
                return constant + 1.5 + Double(score - 1005000) / 500 * 0.1
            case 1007500...1008999:
                return constant + 2.0 + Double(score - 1007500) / 100 * 0.01
            case 1009000...1010000:
                return constant + 2.15
            default:
                return 0
            }
        }
        return rating
    }
    
    func getDescribingStatus(_ fc: String) -> String {
        if (fc == "fullcombo") {
            return "FC"
        } else if (fc == "alljustice") {
            return "AJ"
        }
        return ""
    }
    
    func getGrade(_ score: Int) -> String {
        switch (score) {
        case ...499999:
            return "D"
        case 500000...599999:
            return "C"
        case 600000...699999:
            return "B"
        case 700000...799999:
            return "BB"
        case 800000...899999:
            return "BBB"
        case 900000...924999:
            return "A"
        case 925000...949999:
            return "AA"
        case 950000...974999:
            return "AAA"
        case 975000...999999:
            return "S"
        case 1000000...1007499:
            return "SS"
        case 1007500...1008999:
            return "SSS"
        case 1009000...:
            return "SSS+"
        default:
            return "?"
        }
    }
}

extension UserChunithmBestScoreEntry: CFQChunithmCalculatable {
    var grade: String { getGrade(self.score) }
    var status: String { getDescribingStatus(self.judgeStatus) }
    var rating: Double {
        guard let song = self.associatedSong else {
            return 0.0
        }
        
        guard let constant = song.charts.constants[orNil: self.levelIndex] else {
            return 0.0
        }
        
        return getRating(constant: constant, score: self.score)
    }
}
extension UserChunithmRecentScoreEntry: CFQChunithmCalculatable {
    var levelIndex: Int {
        switch self.difficulty.lowercased() {
        case "basic":
            return 0
        case "advanced":
            return 1
        case "expert":
            return 2
        case "master":
            return 3
        default:
            return 4
        }
    }
    var grade: String { getGrade(self.score) }
    var status: String { getDescribingStatus(self.judgeStatus) }
    var rating: Double {
        guard let song = self.associatedSong else {
            return 0.0
        }
        
        guard let constant = song.charts.constants[orNil: self.levelIndex] else {
            return 0.0
        }
        
        return getRating(constant: constant, score: self.score)
    }
    
    var losses: [Double] {
        let combo = self.judgeCritical + self.judgeJustice + self.judgeAttack + self.judgeMiss
        let unit = 10000 / Double(combo)
        let jLoss = unit
        let aLoss = 51 * unit
        let mLoss = 101 * unit
        return [jLoss, aLoss, mLoss]
    }
}
extension UserChunithmRatingListEntry: CFQChunithmCalculatable {
    var grade: String { getGrade(self.score) }
    var status: String { getDescribingStatus(self.associatedBestEntry!.judgeStatus) }
    var rating: Double {
        guard let song = self.associatedBestEntry?.associatedSong else {
            return 0.0
        }
        
        guard let constant = song.charts.constants[orNil: self.levelIndex] else {
            return 0.0
        }
        
        return getRating(constant: constant, score: self.score)
    }
}

extension String {
    var significance: Int {
        return ["NORMAL", "BRONZE", "SILVER", "GOLD", "RAINBOW"].firstIndex(of: self) ?? -1
    }
    
    var chunithmTrophySignificance: Int {
        return ["normal", "copper", "silver", "gold", "platinum"].firstIndex(of: self) ?? -1
    }
}


extension String {
    var customDateString: String {
        DateTool.defaultDateString(from: self)
    }
    
    func toDateString(format: String) -> String {
        DateTool.toDateString(from: self, format: format)
    }
    
    func toDate() -> Date? {
        DateTool.toDate(from: self)
    }
}

extension Int {
    var customDateString: String {
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        let formatter = DateTool.shared.intTransformer
        formatter.dateFormat = "yy-MM-dd HH:mm"
        return formatter.string(from: date)
    }
    
    func toDateString(format: String) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        let formatter = DateTool.shared.freeTransformer
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    func toDate() -> Date {
        Date(timeIntervalSince1970: TimeInterval(self))
    }
}

extension Double {
    func toDateString(format: String) -> String {
        let date = Date(timeIntervalSince1970: self)
        let formatter = DateTool.shared.freeTransformer
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
}

extension StringProtocol {
    var firstUppercased: String { prefix(1).uppercased() + dropFirst() }
    var firstCapitalized: String { prefix(1).capitalized + dropFirst() }
}

typealias CFQMaimai = CFQData.Maimai
typealias CFQMaimaiLeaderboardEntry = CFQMaimai.LeaderboardEntry
typealias CFQMaimaiLeaderboard = [CFQMaimai.LeaderboardEntry]

typealias CFQChunithm = CFQData.Chunithm
typealias CFQChunithmMusicStatEntry = CFQChunithm.MusicStatEntry
typealias CFQChunithmLeaderboardEntry = CFQChunithm.LeaderboardEntry
typealias CFQChunithmLeaderboard = [CFQChunithm.LeaderboardEntry]
