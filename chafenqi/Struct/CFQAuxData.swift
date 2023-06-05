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

extension Date {
    func formatted(by: String) -> String {
        let f = DateFormatter()
        f.dateFormat = by
        f.timeZone = .autoupdatingCurrent
        f.locale = .autoupdatingCurrent
        return f.string(from: self)
    }
}

typealias CFQMaimaiDayEntry = (CFQMaimaiRecentScoreEntries, Date)
