//
//  CFQAuxData.swift
//  chafenqi
//
//  Created by xinyue on 2023/6/5.
//

import Foundation

struct CFQMaimaiDayRecords: Codable {
    struct CFQMaimaiDayRecord: Codable {
        var date: Date = Date()
        
        var ratingDelta = 0
        var pcDelta = 0
        var dxScoreDelta = 0
        var achievementDelta: Double = 0
        var syncPointDelta = 0
        
        var latestDelta: UserMaimaiPlayerInfoEntry?
        var recentEntries: UserMaimaiRecentScores = []
        
        var hasDelta = false
        
        init() {}
    }
    
    init() {}
    
    var dayPlayed = -1
    var records: [CFQMaimaiDayRecord] = []
    
    init(recents: UserMaimaiRecentScores, deltas: UserMaimaiPlayerInfos) {
        let latestStamp = recents.first?.timestamp ?? 0
        let firstStamp = recents.last?.timestamp ?? 0
        
        // Truncate date to start and end of day respectively
        var truncatedFirstStamp = Calendar.current.startOfDay(for: firstStamp.toDate()).timeIntervalSince1970
        var dateComp = DateComponents()
        dateComp.day = 1
        dateComp.second = -1
        let truncatedLatestStamp = (Calendar.current.date(byAdding: dateComp, to: Calendar.current.startOfDay(for: latestStamp.toDate())) ?? Date()).timeIntervalSince1970
        
        var t = truncatedFirstStamp
        while t <= truncatedLatestStamp {
            t += 86400
            let playInDay = recents.filter { entry in
                (truncatedFirstStamp...t).contains(TimeInterval(entry.timestamp))
            }
            if !playInDay.isEmpty {
                // Filter recent logs
                var record = CFQMaimaiDayRecord()
                record.date = Date(timeIntervalSince1970: truncatedFirstStamp)
                record.recentEntries = playInDay
                
                // Filter delta logs
                // TODO: Fix slow toDate() function call
                let latestDelta = deltas.filter { entry in
                    return (truncatedFirstStamp...t).contains(TimeInterval(entry.timestamp))
                }.last
                if let last = latestDelta {
                    record.latestDelta = last
                    
                    // Calculate deltas
                    if let secondLast = self.records.last?.latestDelta {
                        record.hasDelta = true
                        
                        record.ratingDelta = last.rating - secondLast.rating
                        record.pcDelta = last.playCount - secondLast.playCount
                        // TODO: At lease get total achievements back
                    }
                }
                self.records.append(record)
            }
            truncatedFirstStamp += 86400
        }
        
        dayPlayed = self.records.count

    }
}

struct CFQChunithmDayRecords: Codable {
    
    struct CFQChunithmDayRecord: Codable {
        var date: Date = Date()
        
        var ratingDelta: Double = 0
        var pcDelta: Int = 0
        var overpowerDelta: Double = 0
        var totalGoldDelta: Int = 0
        
        var latestDelta: UserChunithmPlayerInfo?
        var recentEntries: UserChunithmRecentScores = []
        
        var hasDelta = false
        
        init() {}
    }
    
    var dayPlayed = 0
    var records: [CFQChunithmDayRecord] = []
    
    init() {}
    
    init(recents: UserChunithmRecentScores, deltas: UserChunithmPlayerInfos) {
        let latestStamp = recents.first?.timestamp ?? 0
        let firstStamp = recents.last?.timestamp ?? 0
        
        // Truncate date to start and end of day respectively
        var truncatedFirstStamp = Calendar.current.startOfDay(for: firstStamp.toDate()).timeIntervalSince1970
        var dateComp = DateComponents()
        dateComp.day = 1
        dateComp.second = -1
        let truncatedLatestStamp = (Calendar.current.date(byAdding: dateComp, to: Calendar.current.startOfDay(for: latestStamp.toDate())) ?? Date()).timeIntervalSince1970
        
        var t = truncatedFirstStamp
        while t <= truncatedLatestStamp {
            t += 86400
            let playInDay = recents.filter { entry in
                (truncatedFirstStamp...t).contains(TimeInterval(entry.timestamp))
            }
            if !playInDay.isEmpty {
                // Filter recent logs
                var record = CFQChunithmDayRecord()
                record.date = Date(timeIntervalSince1970: truncatedFirstStamp)
                record.recentEntries = playInDay
                
                // Filter delta logs
                let latestDelta = deltas.filter { entry in
                    return (truncatedFirstStamp...t).contains(TimeInterval(entry.timestamp))
                }.last
                if let last = latestDelta {
                    record.latestDelta = last
                    
                    if let secondLast = self.records.last?.latestDelta {
                        record.hasDelta = true
                        
                        record.ratingDelta = last.rating - secondLast.rating
                        record.pcDelta = last.playCount - secondLast.playCount
                        record.overpowerDelta = last.rawOverpower - secondLast.rawOverpower
                        record.totalGoldDelta = last.totalGold - secondLast.totalGold
                    }
                }
                
                self.records.append(record)
            }
            truncatedFirstStamp += 86400
        }
        
        dayPlayed = self.records.count
    }
}

struct CFQMaimaiLevelRecords: Codable {
    static let clearAchievements = [100.5...101.00, 100.0...100.4999, 99.5...99.9999, 99.0...99.4999, 98.0...98.9999, 97.0...97.9999, 0.0...96.9999]
    static var maiLevelStrings: [String] {
        var strings = [String]()
        for i in 1...15 {
            strings.append("\(i)")
            if (7...14).contains(i) {
                strings.append("\(i)+")
            }
        }
        return strings
    }
    
    struct CFQMaimaiLevelRecord: Codable {
        struct CFQMaimaiGradeRecord: Codable {
            var count: Int = 0
            var songs: UserMaimaiBestScores = []
            
            init(range: ClosedRange<Double>, best: UserMaimaiBestScores) {
                songs = best.filter {
                    range.contains($0.achievements)
                }
                count = songs.count
            }
        }
        
        var count: Int = 0
        var levelString: String = ""
        var grades: [CFQMaimaiGradeRecord] = []
        var noRecordSongs: [MaimaiSongData] = []
        var ratios: [Double] = []
        
        init(index: Int, best: UserMaimaiBestScores, songData: [MaimaiSongData]) {
            let songs = best.filter {
                guard let song = $0.associatedSong else {
                    return false
                }
                
                guard let level = song.level[orNil: $0.levelIndex] else {
                    return false
                }
                
                return level == CFQMaimaiLevelRecords.maiLevelStrings[index]
            }
            self.levelString = CFQMaimaiLevelRecords.maiLevelStrings[index]
            let playedIdList = songs.compactMap { $0.associatedSong?.coverId ?? 0 }
            let filteredData = songData.filter {
                $0.level.contains(levelString)
            }
            self.noRecordSongs = filteredData.filter {
                !playedIdList.contains($0.coverId)
            }
            for range in CFQMaimaiLevelRecords.clearAchievements {
                grades.append(CFQMaimaiGradeRecord(range: range, best: songs))
            }
            self.count = filteredData.count
            self.ratios = grades.compactMap { Double($0.count) / Double(self.count) }
        }
    }
    
    var levels: [CFQMaimaiLevelRecord] = []
    
    init(songs: [MaimaiSongData], best: UserMaimaiBestScores) {
        for level in CFQMaimaiLevelRecords.maiLevelStrings.indices {
            levels.append(CFQMaimaiLevelRecord(index: level, best: best, songData: songs))
        }
    }
    
    init() {}
}

struct CFQChunithmLevelRecords: Codable {
    static var chuLevelStrings: [String] {
        var strings = [String]()
        for i in 1...15 {
            strings.append("\(i)")
            if (7...14).contains(i) {
                strings.append("\(i)+")
            }
        }
        return strings
    }
    
    var levels: [CFQChunithmLevelRecord] = []
    
    struct CFQChunithmLevelRecord: Codable {
        var count: Int = 0
        var levelString: String = ""
        // var grades: [CFQMaimaiGradeRecord] = []
        var noRecordSongs: [ChunithmMusicData] = []
        var ratios: [Double] = []
        
        init(level: String, best: UserChunithmBestScores, songData: [ChunithmMusicData]) {
            self.levelString = level
            let songs = best.filter {
                ($0.associatedSong?.charts.getChartFromIndex($0.levelIndex).level ?? "") == level
            }
            let playedIdList = songs.compactMap { $0.associatedSong?.musicID ?? 0 }
            let filteredData = songData.filter {
                $0.charts.levels.contains(levelString)
            }
            self.noRecordSongs = filteredData.filter {
                !playedIdList.contains($0.musicID)
            }
        }
    }
    
    init(songs: [ChunithmMusicData], best: UserChunithmBestScores) {
        for level in CFQChunithmLevelRecords.chuLevelStrings {
            levels.append(CFQChunithmLevelRecord(level: level, best: best, songData: songs))
        }
    }
    
    init() {}
}

