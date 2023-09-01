//
//  CFQAuxData.swift
//  chafenqi
//
//  Created by xinyue on 2023/6/5.
//

import Foundation

struct CFQMaimaiDayRecords {
    struct CFQMaimaiDayRecord {
        var date: Date = Date()
        
        var ratingDelta = 0
        var pcDelta = 0
        var dxScoreDelta = 0
        var achievementDelta: Double = 0
        var syncPointDelta = 0
        
        var latestDelta: CFQMaimai.DeltaEntry?
        var recentEntries: CFQMaimaiRecentScoreEntries = []
        
        var hasDelta = false
        
        init() {}
    }
    
    init() {}
    
    var dayPlayed = -1
    var records: [CFQMaimaiDayRecord] = []
    
    init(recents: CFQMaimaiRecentScoreEntries, deltas: CFQMaimaiDeltaEntries) {
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
                    if let timestamp = entry.createdAt.toDate()?.timeIntervalSince1970 {
                        return (truncatedFirstStamp...t).contains(timestamp)
                    } else {
                        return false
                    }
                }.last
                if let last = latestDelta {
                    record.latestDelta = last
                    
                    // Calculate deltas
                    if let secondLast = self.records.last?.latestDelta {
                        record.hasDelta = true
                        
                        record.ratingDelta = last.rating - secondLast.rating
                        record.pcDelta = last.playCount - secondLast.playCount
                        record.achievementDelta = last.achievement - secondLast.achievement
                        record.dxScoreDelta = last.dxScore - secondLast.dxScore
                        record.syncPointDelta = last.syncPoint - secondLast.syncPoint
                    }
                }
                self.records.append(record)
            }
            truncatedFirstStamp += 86400
        }
        
        dayPlayed = self.records.count

    }
}

struct CFQChunithmDayRecords {
    struct CFQChunithmDayRecord {
        var date: Date = Date()
        
        var ratingDelta: Double = 0
        var pcDelta: Int = 0
        var overpowerDelta: Double = 0
        var totalGoldDelta: Int = 0
        
        var latestDelta: CFQChunithm.DeltaEntry?
        var recentEntries: CFQChunithmRecentScoreEntries = []
        
        var hasDelta = false
        
        init() {}
    }
    
    var dayPlayed = 0
    var records: [CFQChunithmDayRecord] = []
    
    init() {}
    
    init(recents: CFQChunithmRecentScoreEntries, deltas: CFQChunithmDeltaEntries) {
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
                    if let timestamp = entry.createdAt.toDate()?.timeIntervalSince1970 {
                        return (truncatedFirstStamp...t).contains(timestamp)
                    } else {
                        return false
                    }
                }.last
                if let last = latestDelta {
                    record.latestDelta = last
                    
                    if let secondLast = self.records.last?.latestDelta {
                        record.hasDelta = true
                        
                        record.ratingDelta = last.rating - secondLast.rating
                        record.pcDelta = last.playCount - secondLast.playCount
                        record.overpowerDelta = last.overpower_raw - secondLast.overpower_raw
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
            var songs: CFQMaimaiBestScoreEntries = []
            
            init(range: ClosedRange<Double>, best: CFQMaimaiBestScoreEntries) {
                songs = best.filter {
                    range.contains($0.score)
                }
                count = songs.count
            }
        }
        
        var count: Int = 0
        var levelString: String = ""
        var grades: [CFQMaimaiGradeRecord] = []
        var noRecordSongs: [MaimaiSongData] = []
        var ratios: [Double] = []
        
        init(index: Int, best: CFQMaimaiBestScoreEntries, songData: [MaimaiSongData]) {
            let songs = best.filter {
                $0.level == CFQMaimaiLevelRecords.maiLevelStrings[index]
            }
            self.levelString = CFQMaimaiLevelRecords.maiLevelStrings[index]
            let playedIdList = songs.compactMap { $0.associatedSong!.musicId }
            let filteredData = songData.filter {
                $0.level.contains(levelString)
            }
            self.noRecordSongs = filteredData.filter {
                !playedIdList.contains($0.musicId)
            }
            for range in CFQMaimaiLevelRecords.clearAchievements {
                grades.append(CFQMaimaiGradeRecord(range: range, best: songs))
            }
            self.count = filteredData.count
            self.ratios = grades.compactMap { Double($0.count) / Double(self.count) }
        }
    }
    
    var levels: [CFQMaimaiLevelRecord] = []
    
    init(songs: [MaimaiSongData], best: CFQMaimaiBestScoreEntries) {
        for level in CFQMaimaiLevelRecords.maiLevelStrings.indices {
            levels.append(CFQMaimaiLevelRecord(index: level, best: best, songData: songs))
        }
    }
    
    init() {}
}

typealias CFQMaimaiDayEntry = (CFQMaimaiRecentScoreEntries, Date)
