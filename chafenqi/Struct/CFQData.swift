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
        static func assignAssociated(songs: [MaimaiSongData], bests: [BestScoreEntry]) -> [BestScoreEntry] {
            var b = bests
            for (i,entry) in b.enumerated() {
                if (entry.title == "D✪N’T ST✪P R✪CKIN’") {
                    var e = entry
                    e.associatedSong = songs.first {
                        $0.musicId == "364" && $0.type == entry.type
                    }
                    b[i] = e
                } else {
                    let searched = songs.first {
                        let titleMatch = $0.title.localizedCaseInsensitiveCompare(entry.title)
                        if titleMatch == .orderedSame {
                            return $0.type == entry.type // What about Link(COF)? Distinguish them on server-side
                        }
                        return false
                    }
                    if let song = searched {
                        var e = entry
                        e.associatedSong = song
                        b[i] = e
                    }
                }
            }
            return b
        }
        
        static func assignAssociated(songs: [MaimaiSongData], recents: [RecentScoreEntry]) -> [RecentScoreEntry] {
            var r = recents
            for (i,entry) in r.enumerated() {
                if (entry.title == "D✪N’T ST✪P R✪CKIN’") {
                    var e = entry
                    e.associatedSong = songs.first {
                        $0.musicId == "364" && $0.type == entry.type
                    }
                    r[i] = e
                } else {
                    let searched = songs.first {
                        let titleMatch = $0.title.localizedCaseInsensitiveCompare(entry.title)
                        if titleMatch == .orderedSame {
                            return $0.type == entry.type
                        }
                        return false
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
        
        struct UserInfo: Codable {
            var uid: Int
            var nickname: String
            var trophy: String
            var rating: Int
            var maxRating: Int
            var star: Int
            var charUrl: String
            var gradeUrl: String
            var playCount: Int
            var stats: String
            var updatedAt: String
            var createdAt: String
            
            static let empty = UserInfo(uid: 0, nickname: "", trophy: "", rating: 0, maxRating: 0, star: 0, charUrl: "", gradeUrl: "", playCount: 0, stats: "", updatedAt: "", createdAt: "")
        }
        
        struct BestScoreEntry: Codable {
            var title: String
            var level: String
            var levelIndex: Int
            var type: String
            var score: Double
            var dxScore: Int
            var rate: String // e.g. SSS+
            var fc: String = ""
            var fs: String = ""
            var ds: Double = 0.0
            var idx: String // Useless in maimai.NET
            var associatedSong: MaimaiSongData?
            var updatedAt: String
            var createdAt: String
            
            enum CodingKeys: String, CodingKey {
                case title
                case level
                case levelIndex = "level_index"
                case type
                case score = "achievements"
                case dxScore
                case rate
                case fc
                case fs
                case ds
                case idx
                case updatedAt
                case createdAt
            }
        }
        
        struct RecentScoreEntry: Codable {
            var timestamp: Int
            var title: String
            var difficulty: String
            var type: String
            var score: Double
            var isNewRecord: Int
            var dxScore: Int
            var fc: String = ""
            var fs: String = ""
            var notes: [String: String]
            private var notes_tap: String
            private var notes_hold: String
            private var notes_slide: String
            private var notes_touch: String
            private var notes_break: String
            var maxCombo: String
            var maxSync: String
            var matching: [String]
            private var matching_1: String
            private var matching_2: String
            private var matching_3: String
            var associatedSong: MaimaiSongData?
            var updatedAt: String
            var createdAt: String
            
            init(from decoder: Decoder) throws {
                let container: KeyedDecodingContainer<CFQData.Maimai.RecentScoreEntry.CodingKeys> = try decoder.container(keyedBy: CFQData.Maimai.RecentScoreEntry.CodingKeys.self)
                self.timestamp = try container.decode(Int.self, forKey: CFQData.Maimai.RecentScoreEntry.CodingKeys.timestamp)
                self.title = try container.decode(String.self, forKey: CFQData.Maimai.RecentScoreEntry.CodingKeys.title)
                self.difficulty = try container.decode(String.self, forKey: CFQData.Maimai.RecentScoreEntry.CodingKeys.difficulty)
                self.type = try container.decode(String.self, forKey: .type)
                self.score = try container.decode(Double.self, forKey: CFQData.Maimai.RecentScoreEntry.CodingKeys.score)
                self.isNewRecord = try container.decode(Int.self, forKey: CFQData.Maimai.RecentScoreEntry.CodingKeys.isNewRecord)
                self.dxScore = try container.decode(Int.self, forKey: CFQData.Maimai.RecentScoreEntry.CodingKeys.dxScore)
                self.fc = try container.decode(String.self, forKey: CFQData.Maimai.RecentScoreEntry.CodingKeys.fc)
                self.fs = try container.decode(String.self, forKey: CFQData.Maimai.RecentScoreEntry.CodingKeys.fs)
                self.notes_tap = try container.decode(String.self, forKey: CFQData.Maimai.RecentScoreEntry.CodingKeys.notes_tap)
                self.notes_hold = try container.decode(String.self, forKey: CFQData.Maimai.RecentScoreEntry.CodingKeys.notes_hold)
                self.notes_slide = try container.decode(String.self, forKey: CFQData.Maimai.RecentScoreEntry.CodingKeys.notes_slide)
                self.notes_touch = try container.decode(String.self, forKey: CFQData.Maimai.RecentScoreEntry.CodingKeys.notes_touch)
                self.notes_break = try container.decode(String.self, forKey: CFQData.Maimai.RecentScoreEntry.CodingKeys.notes_break)
                self.maxCombo = try container.decode(String.self, forKey: CFQData.Maimai.RecentScoreEntry.CodingKeys.maxCombo)
                self.maxSync = try container.decode(String.self, forKey: CFQData.Maimai.RecentScoreEntry.CodingKeys.maxSync)
                self.matching_1 = try container.decode(String.self, forKey: CFQData.Maimai.RecentScoreEntry.CodingKeys.matching_1)
                self.matching_2 = try container.decode(String.self, forKey: CFQData.Maimai.RecentScoreEntry.CodingKeys.matching_2)
                self.matching_3 = try container.decode(String.self, forKey: CFQData.Maimai.RecentScoreEntry.CodingKeys.matching_3)
                self.matching = [self.matching_1, self.matching_2, self.matching_3]
                self.notes = ["tap": self.notes_tap, "hold": self.notes_hold, "slide": self.notes_slide, "touch": self.notes_touch, "break": self.notes_break]
                self.updatedAt = try container.decode(String.self, forKey: .updatedAt)
                self.createdAt = try container.decode(String.self, forKey: .createdAt)
            }
            
            enum CodingKeys: String, CodingKey {
                case timestamp
                case title
                case difficulty
                case type
                case score = "achievements"
                case isNewRecord
                case dxScore
                case fc
                case fs
                case notes_tap
                case notes_hold
                case notes_slide
                case notes_touch
                case notes_break
                case maxCombo
                case maxSync
                case matching_1
                case matching_2
                case matching_3
                case updatedAt
                case createdAt
            }
        }
        
        struct DeltaEntry: Codable {
            var rating: Int
            var playCount: Int
            var stats: String
            var dxScore: Int
            var achievement: Double
            var syncPoint: Int
            var awakening: Int
            var updatedAt: String
            var createdAt: String
        }
    }
    
    struct Chunithm: Codable {
        static func assignAssociated(songs: [ChunithmSongData], bests: [BestScoreEntry]) -> [BestScoreEntry] {
            var b = bests
            for (i,entry) in b.enumerated() {
                let searched = songs.first {
                    String($0.musicId) == entry.idx
                }
                if let song = searched {
                    var e = entry
                    e.associatedSong = song
                    b[i] = e
                }
            }
            return b
        }
        
        static func assignAssociated(songs: [ChunithmSongData], recents: [RecentScoreEntry]) -> [RecentScoreEntry] {
            var r = recents
            for (i,entry) in r.enumerated() {
                let searched = songs.first {
                    String($0.musicId) == entry.idx
                }
                if let song = searched {
                    var e = entry
                    e.associatedSong = song
                    r[i] = e
                }
            }
            return r
        }
        
        static func assignAssociated(songs: [ChunithmSongData], ratings: [RatingEntry]) -> [RatingEntry] {
            var r = ratings
            for (i, entry) in r.enumerated() {
                let searched = songs.first {
                    String($0.musicId) == entry.idx
                }
                if let song = searched {
                    var e = entry
                    e.associatedSong = song
                    r[i] = e
                }
            }
            return r
        }
        
        struct UserInfo: Codable {
            var uid: Int
            var nickname: String
            var trophy: String
            var plate: String
            var dan: Int
            var ribbon: Int
            var rating: Double
            var maxRating: Double
            var overpower_raw: Double
            var overpower_percent: Double
            var lastPlayDate: Int
            var charUrl: String
            var friendCode: String
            var currentGold: Int
            var totalGold: Int
            var playCount: Int
            var updatedAt: String
            var createdAt: String
            
            static let empty = UserInfo(uid: 0, nickname: "", trophy: "", plate: "", dan: 0, ribbon: 0, rating: 0.0, maxRating: 0.0, overpower_raw: 0.0, overpower_percent: 0.0, lastPlayDate: 0, charUrl: "", friendCode: "", currentGold: 0, totalGold: 0, playCount: 0, updatedAt: "", createdAt: "")
        }
        
        struct BestScoreEntry: Codable {
            var title: String
            var levelIndex: Int
            var score: Int
            var rankIndex: Int = -1
            var clear: String = ""
            var fcombo: String = ""
            var fchain: String = ""
            var idx: String // Basically music id
            var associatedSong: ChunithmSongData?
            var updatedAt: String
            var createdAt: String
            
            enum CodingKeys: String, CodingKey {
                case title
                case levelIndex = "level_index"
                case score = "highscore"
                case rankIndex = "rank_index"
                case clear
                case fcombo = "full_combo"
                case fchain = "full_chain"
                case idx
                case updatedAt
                case createdAt
            }
        }
        
        struct RecentScoreEntry: Codable {
            var timestamp: Int
            var idx: String
            var title: String
            var difficulty: String
            var score: Int
            var isNewRecord: Int
            var fc: String = ""
            var rankIndex: Int = -1
            var judges: [String: Int]
            private var judges_critical: Int
            private var judges_justice: Int
            private var judges_attack: Int
            private var judges_miss: Int
            var notes: [String: String]
            private var notes_tap: String
            private var notes_hold: String
            private var notes_slide: String
            private var notes_air: String
            private var notes_flick: String
            var associatedSong: ChunithmSongData?
            var updatedAt: String
            var createdAt: String
            
            init(from decoder: Decoder) throws {
                let container: KeyedDecodingContainer<CFQData.Chunithm.RecentScoreEntry.CodingKeys> = try decoder.container(keyedBy: CFQData.Chunithm.RecentScoreEntry.CodingKeys.self)
                self.timestamp = try container.decode(Int.self, forKey: CFQData.Chunithm.RecentScoreEntry.CodingKeys.timestamp)
                self.idx = try container.decode(String.self, forKey: CFQData.Chunithm.RecentScoreEntry.CodingKeys.idx)
                self.title = try container.decode(String.self, forKey: CFQData.Chunithm.RecentScoreEntry.CodingKeys.title)
                self.difficulty = try container.decode(String.self, forKey: CFQData.Chunithm.RecentScoreEntry.CodingKeys.difficulty)
                self.score = try container.decode(Int.self, forKey: CFQData.Chunithm.RecentScoreEntry.CodingKeys.score)
                self.isNewRecord = try container.decode(Int.self, forKey: CFQData.Chunithm.RecentScoreEntry.CodingKeys.isNewRecord)
                self.fc = try container.decode(String.self, forKey: CFQData.Chunithm.RecentScoreEntry.CodingKeys.fc)
                self.rankIndex = try container.decode(Int.self, forKey: CFQData.Chunithm.RecentScoreEntry.CodingKeys.rankIndex)
                self.judges_critical = try container.decode(Int.self, forKey: CFQData.Chunithm.RecentScoreEntry.CodingKeys.judges_critical)
                self.judges_justice = try container.decode(Int.self, forKey: CFQData.Chunithm.RecentScoreEntry.CodingKeys.judges_justice)
                self.judges_attack = try container.decode(Int.self, forKey: CFQData.Chunithm.RecentScoreEntry.CodingKeys.judges_attack)
                self.judges_miss = try container.decode(Int.self, forKey: CFQData.Chunithm.RecentScoreEntry.CodingKeys.judges_miss)
                self.notes_tap = try container.decode(String.self, forKey: CFQData.Chunithm.RecentScoreEntry.CodingKeys.notes_tap)
                self.notes_hold = try container.decode(String.self, forKey: CFQData.Chunithm.RecentScoreEntry.CodingKeys.notes_hold)
                self.notes_slide = try container.decode(String.self, forKey: CFQData.Chunithm.RecentScoreEntry.CodingKeys.notes_slide)
                self.notes_air = try container.decode(String.self, forKey: CFQData.Chunithm.RecentScoreEntry.CodingKeys.notes_air)
                self.notes_flick = try container.decode(String.self, forKey: CFQData.Chunithm.RecentScoreEntry.CodingKeys.notes_flick)
                self.judges = ["critical": self.judges_critical, "justice": self.judges_justice, "attack": self.judges_attack, "miss": self.judges_miss]
                self.notes = ["tap": self.notes_tap, "hold": self.notes_hold, "slide": self.notes_slide, "air": self.notes_air, "flick": self.notes_flick]
                self.updatedAt = try container.decode(String.self, forKey: .updatedAt)
                self.createdAt = try container.decode(String.self, forKey: .createdAt)
            }
            
            enum CodingKeys: String, CodingKey {
                case timestamp
                case idx
                case title
                case difficulty
                case score = "highscore"
                case isNewRecord
                case fc
                case rankIndex = "rank_index"
                case judges_critical
                case judges_justice
                case judges_attack
                case judges_miss
                case notes_tap
                case notes_hold
                case notes_slide
                case notes_air
                case notes_flick
                case updatedAt
                case createdAt
            }
        }
        
        struct RatingEntry: Codable {
            var idx: String
            var title: String
            var levelIndex: Int
            var score: Int
            var type: String
            var updatedAt: String
            var createdAt: String
            var associatedSong: ChunithmSongData?
            
            enum CodingKeys: String, CodingKey {
                case idx
                case title
                case score = "highscore"
                case levelIndex = "level_index"
                case type
                case updatedAt
                case createdAt
            }
        }
        
        struct DeltaEntry: Codable {
            var rating: Double
            var overpower_raw: Double
            var overpower_percent: Double
            var playCount: Int
            var totalGold: Int
            var currentGold: Int
            var updatedAt: String
            var createdAt: String
        }
        
        struct ExtraEntry: Codable {
            var nameplates: [NameplateEntry]
            var skills: [SkillEntry]
            var characters: [CharacterEntry]
            var trophies: [TrophyEntry]
            var mapIcons: [MapIconEntry]
            var tickets: [TicketEntry]
            var collections: CollectionEntry
            
            static let empty = ExtraEntry(nameplates: [], skills: [], characters: [], trophies: [], mapIcons: [], tickets: [], collections: CollectionEntry(charUrl: "", charName: "", charRank: "", charExp: 0.0, charIllust: "", ghost: 0, silver: 0, gold: 0, updatedAt: "", createdAt: ""))
            
            struct NameplateEntry: Codable {
                var name: String
                var url: String
                var current: Int
                var updatedAt: String
                var createdAt: String
            }
            struct SkillEntry: Codable {
                var name: String
                var icon: String
                var level: Int
                var description: String
                var current: Int
                var updatedAt: String
                var createdAt: String
            }
            struct CharacterEntry: Codable {
                var name: String
                var url: String
                var rank: String
                var exp: Double
                var current: Int
                var updatedAt: String
                var createdAt: String
            }
            struct TrophyEntry: Codable {
                var name: String
                var type: String
                var description: String
                var updatedAt: String
                var createdAt: String
            }
            struct MapIconEntry: Codable {
                var name: String
                var url: String
                var current: Int
                var updatedAt: String
                var createdAt: String
            }
            struct TicketEntry: Codable {
                var name: String
                var url: String
                var count: Int
                var description: String
                var updatedAt: String
                var createdAt: String
            }
            struct CollectionEntry: Codable {
                var charUrl: String
                var charName: String
                var charRank: String
                var charExp: Double
                var charIllust: String
                var ghost: Int // Should always be zero
                var silver: Int
                var gold: Int
                var updatedAt: String
                var createdAt: String
            }
        }
    }
}

protocol CFQMaimaiRatingCalculatable {
    var rating: Int { get }
    func getRating(constant: Double, achievements: Double) -> Int
}

extension CFQMaimaiRatingCalculatable {
    func getRating(constant: Double, achievements: Double) -> Int {
        let ratingDict = [
            100.5000...101.0000:22.4,
            100.0000...100.4999:21.6,
            99.5000...99.9999:21.1,
            99.0000...99.4999:20.8,
            98.0000...98.9999:20.3,
            97.0000...97.9999:20.0,
            94.0000...96.9999:16.8,
            90.0000...93.9999:13.6,
            80.0000...89.9999:8.0,
            75.0000...79.9999:7.5
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
        let rating = Int((constant * achievements * factor).rounded(.down))
        return rating
    }
}

extension CFQData.Maimai.BestScoreEntry: CFQMaimaiRatingCalculatable {
    var rating: Int {
        getRating(constant: self.associatedSong!.constant[self.levelIndex], achievements: self.score)
    }
}
extension CFQData.Maimai.RecentScoreEntry: CFQMaimaiRatingCalculatable {
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
        getRating(constant: self.associatedSong!.constant[self.levelIndex], achievements: self.score)
    }
}

protocol CFQChunithmRatingCalculatable {
    var rating: Double {get}
    func getRating(constant: Double, score: Int) -> Double
}

extension CFQChunithmRatingCalculatable {
    func getRating(constant: Double, score: Int) -> Double {
        var rating: Double {
            switch (score) {
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
}

extension CFQData.Chunithm.BestScoreEntry: CFQChunithmRatingCalculatable {
    var rating: Double { getRating(constant: self.associatedSong!.constant[self.levelIndex], score: self.score) }
}
extension CFQData.Chunithm.RecentScoreEntry: CFQChunithmRatingCalculatable {
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
    var rating: Double { getRating(constant: self.associatedSong!.constant[self.levelIndex], score: self.score) }
}
extension CFQData.Chunithm.RatingEntry: CFQChunithmRatingCalculatable {
    var rating: Double { getRating(constant: self.associatedSong!.constant[self.levelIndex], score: self.score) }
}

typealias CFQMaimai = CFQData.Maimai
typealias CFQMaimaiUserInfo = CFQMaimai.UserInfo
typealias CFQMaimaiBestScoreEntries = [CFQMaimai.BestScoreEntry]
typealias CFQMaimaiRecentScoreEntries = [CFQMaimai.RecentScoreEntry]
typealias CFQMaimaiDeltaEntries = [CFQMaimai.DeltaEntry]

typealias CFQChunithm = CFQData.Chunithm
typealias CFQChunithmUserInfo = CFQChunithm.UserInfo
typealias CFQChunithmBestScoreEntries = [CFQChunithm.BestScoreEntry]
typealias CFQChunithmRecentScoreEntries = [CFQChunithm.RecentScoreEntry]
typealias CFQChunithmRatingEntries = [CFQChunithm.RatingEntry]
typealias CFQChunithmDeltaEntries = [CFQChunithm.DeltaEntry]
typealias CFQChunithmExtraEntry = CFQChunithm.ExtraEntry
