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
                        $0.musicId == "299" && $0.type == entry.type
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
        
        struct RecentScoreEntry: Codable, Hashable {
            func hash(into hasher: inout Hasher) {
                hasher.combine(timestamp)
            }
            
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
            var awakening: String
            var updatedAt: String
            var createdAt: String
            
            static let empty = DeltaEntry(rating: 0, playCount: 0, stats: "", dxScore: 0, achievement: 0, syncPoint: 0, awakening: "", updatedAt: "", createdAt: "")
        }
        
        struct ExtraEntry: Codable {
            var avatars: [AvatarEntry]
            var nameplates: [NameplateEntry]
            var characters: [CharacterEntry]
            var trophies: [TrophyEntry]
            var frames: [FrameEntry]
            var partners: [PartnerEntry]
            
            static let empty = ExtraEntry(avatars: [], nameplates: [], characters: [], trophies: [], frames: [], partners: [])
            
            struct AvatarEntry: Codable {
                var name: String
                var description: String
                var image: String
                var area: String
                var selected: Int
            }
            struct NameplateEntry: Codable {
                var name: String
                var description: String
                var image: String
                var area: String
                var selected: Int
            }
            struct CharacterEntry: Codable {
                var name: String
                var description: String
                var image: String
                var area: String
                var level: String
                var selected: Int
            }
            struct TrophyEntry: Codable {
                var name: String
                var description: String
                var type: String
                var selected: Int
            }
            struct FrameEntry: Codable {
                var name: String
                var description: String
                var image: String
                var area: String
                var selected: Int
            }
            struct PartnerEntry: Codable {
                var name: String
                var description: String
                var image: String
                var selected: Int
            }
        }
    }
    
    struct Chunithm: Codable {
        static func assignAssociated(songs: [ChunithmMusicData], bests: [BestScoreEntry]) -> [BestScoreEntry] {
            var b = bests
            for (i,entry) in b.enumerated() {
                let searched = songs.first {
                    String($0.musicID) == entry.idx
                }
                if let song = searched {
                    var e = entry
                    e.associatedSong = song
                    b[i] = e
                }
            }
            return b
        }
        
        static func assignAssociated(songs: [ChunithmMusicData], recents: [RecentScoreEntry]) -> [RecentScoreEntry] {
            var r = recents
            for (i,entry) in r.enumerated() {
                if entry.difficulty == "worldsend" {
                    let filtered = songs.filter {
                        $0.musicID >= 8000
                    }
                    let searched = filtered.first {
                        String($0.title) == entry.title
                    }
                    if let song = searched {
                        var e = entry
                        e.associatedSong = song
                        r[i] = e
                    }
                } else {
                    let searched = songs.first {
                        String($0.musicID) == entry.idx
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
        
        static func assignAssociated(bests: CFQChunithmBestScoreEntries, ratings: [RatingEntry]) -> [RatingEntry] {
            var r = ratings
            for (i, entry) in r.enumerated() {
                let searched = bests.first {
                    $0.idx == entry.idx && $0.levelIndex == entry.levelIndex
                }
                if let song = searched {
                    var e = entry
                    e.associatedBestEntry = song
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
            var associatedSong: ChunithmMusicData?
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
        
        struct RecentScoreEntry: Codable, Hashable {
            func hash(into hasher: inout Hasher) {
                hasher.combine(timestamp)
            }
            
            var timestamp: Int
            var idx: String
            var title: String
            var difficulty: String
            var score: Int
            var isNewRecord: Int
            var clear: String
            var fcombo: String
            var fchain: String
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
            var associatedSong: ChunithmMusicData?
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
                self.fcombo = try container.decode(String.self, forKey: CFQData.Chunithm.RecentScoreEntry.CodingKeys.fcombo)
                self.fchain = try container.decode(String.self, forKey: CFQData.Chunithm.RecentScoreEntry.CodingKeys.fchain)
                self.clear = try container.decode(String.self, forKey: CFQData.Chunithm.RecentScoreEntry.CodingKeys.clear)
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
                case clear
                case fcombo = "full_combo"
                case fchain = "full_chain"
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
            var associatedBestEntry: BestScoreEntry?
            
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
            
            static let empty = DeltaEntry(rating: 0, overpower_raw: 0, overpower_percent: 0, playCount: 0, totalGold: 0, currentGold: 0, updatedAt: "", createdAt: "")
        }
        
        struct ExtraEntry: Codable {
            var nameplates: [NameplateEntry]
            var skills: [SkillEntry]
            var characters: [CharacterEntry]
            var trophies: [TrophyEntry]
            var mapIcons: [MapIconEntry]
            var tickets: [TicketEntry]
            var collections: [CollectionEntry]
            
            static let empty = ExtraEntry(nameplates: [], skills: [], characters: [], trophies: [], mapIcons: [], tickets: [], collections: [])
            
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

protocol CFQMaimaiCalculatable {
    var rating: Int { get }
    var rateString: String { get }
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
        return fc.replacingOccurrences(of: "plus", with: "+").uppercased()
    }
}

extension CFQData.Maimai.BestScoreEntry: CFQMaimaiCalculatable {
    var rateString: String {
        getRateString(self.rate)
    }
    var rating: Int {
        getRating(constant: self.associatedSong!.constant[self.levelIndex], achievements: self.score)
    }
    var status: String {
        getStatus(self.fc)
    }
}
extension CFQData.Maimai.RecentScoreEntry: CFQMaimaiCalculatable {
    var rateString: String { getRateStringFromScore(self.score) }
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
    var status: String {
        getStatus(self.fc)
    }
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

extension CFQData.Chunithm.BestScoreEntry: CFQChunithmCalculatable {
    var grade: String { getGrade(self.score) }
    var status: String { getDescribingStatus(self.fcombo) }
    var rating: Double { getRating(constant: self.associatedSong!.charts.constants[self.levelIndex], score: self.score) }
}
extension CFQData.Chunithm.RecentScoreEntry: CFQChunithmCalculatable {
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
    var status: String { getDescribingStatus(self.fcombo) }
    var rating: Double { getRating(constant: self.associatedSong!.charts.constants[self.levelIndex], score: self.score) }
}
extension CFQData.Chunithm.RatingEntry: CFQChunithmCalculatable {
    var grade: String { getGrade(self.score) }
    var status: String { getDescribingStatus(self.associatedBestEntry!.fcombo) }
    var rating: Double { getRating(constant: self.associatedBestEntry!.associatedSong!.charts.constants[self.levelIndex], score: self.score) }
}

extension String {
    var customDateString: String {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = .autoupdatingCurrent
        formatter.formatOptions = [.withColonSeparatorInTimeZone, .withSpaceBetweenDateAndTime, .withFractionalSeconds, .withInternetDateTime]
        let date = formatter.date(from: self)
        if let date = date {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM-dd HH:mm"
            formatter.timeZone = .autoupdatingCurrent
            formatter.locale = .autoupdatingCurrent
            return formatter.string(from: date)
        }
        return ""
    }
    
    func toDateString(format: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = .autoupdatingCurrent
        formatter.formatOptions = [.withColonSeparatorInTimeZone, .withSpaceBetweenDateAndTime, .withFractionalSeconds, .withInternetDateTime]
        let date = formatter.date(from: self)
        if let date = date {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            formatter.timeZone = .autoupdatingCurrent
            formatter.locale = .autoupdatingCurrent
            return formatter.string(from: date)
        }
        return ""
    }
    
    func toDate() -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = .autoupdatingCurrent
        formatter.formatOptions = [.withColonSeparatorInTimeZone, .withSpaceBetweenDateAndTime, .withFractionalSeconds, .withInternetDateTime]
        return formatter.date(from: self)
    }
}

extension Int {
    var customDateString: String {
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        let formatter = DateFormatter()
        formatter.dateFormat = "yy-MM-dd HH:mm"
        formatter.timeZone = .autoupdatingCurrent
        formatter.locale = .autoupdatingCurrent
        return formatter.string(from: date)
    }
    
    func toDateString(format: String) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(self))
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = .autoupdatingCurrent
        formatter.locale = .autoupdatingCurrent
        return formatter.string(from: date)
    }
    
    func toDate() -> Date {
        Date(timeIntervalSince1970: TimeInterval(self))
    }
}

extension Double {
    func toDateString(format: String) -> String {
        let date = Date(timeIntervalSince1970: self)
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = .autoupdatingCurrent
        formatter.locale = .autoupdatingCurrent
        return formatter.string(from: date)
    }
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
