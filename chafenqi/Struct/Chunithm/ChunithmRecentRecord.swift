//
//  ChunithmRecentRecord.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/19.
//

import Foundation

let sharedChunithmRecentRecordJSON = """
{"timestamp":1676726340, "music_id": "1059","title":"MEGALOVANIA","diff": "master", "score":"1009940","is_new_record":0,"fc_status":"clear","rank_index":"13","judge_critical":"2000","judge_justice":"12","judge_attack":"0","judge_miss":"0","note_tap":"100.98%","note_hold":"101.00%","note_slide":"101.00%","note_air":"101.00%","note_flick":"101.00%","createdAt":"2023-02-18 15:52:51.370 +00:00","updatedAt":"2023-02-18 15:52:51.370 +00:00"}
"""

struct ChunithmRecentRecord: Codable {
    static let shared = try! JSONDecoder().decode(ChunithmRecentRecord.self, from: sharedChunithmRecentRecordJSON.data(using: .utf8)!)
    
    var timestamp: Int
    var music_id: String
    var title: String
    var diff: String
    var score: String
    var is_new_record: Int
    var fc_status: String
    var rank_index: String
    var judge_critical: String
    var judge_justice: String
    var judge_attack: String
    var judge_miss: String
    var note_tap: String?
    var note_hold: String?
    var note_slide: String?
    var note_air: String?
    var note_flick: String?
    var createdAt: String
    var updatedAt: String
    
    func getDate() -> Date {
        Date(timeIntervalSince1970: TimeInterval(timestamp))
    }
    
    func getDateString() -> String {
        let style = Date.VerbatimFormatStyle(format: "\(year: .defaultDigits)/\(month: .twoDigits)/\(day: .twoDigits) \(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .oneBased)):\(minute: .twoDigits)", timeZone: .autoupdatingCurrent, calendar: .autoupdatingCurrent)
        return style.format(getDate())
    }
    
    func getLevelIndex() -> Int {
        switch diff {
        case "basic":
            return 0
        case "advanced":
            return 1
        case "expert":
            return 2
        case "master":
            return 3
        case "ultima":
            return 4
        default:
            return 3
        }
    }
    
    func getGrade() -> String {
        switch Int(rank_index) {
        case 0:
            return "D"
        case 1:
            return "C"
        case 2:
            return "B"
        case 3:
            return "BB"
        case 4:
            return "BBB"
        case 5:
            return "A"
        case 6:
            return "AA"
        case 7:
            return "AAA"
        case 8:
            return "S"
        case 9:
            return "S+"
        case 10:
            return "SS"
        case 11:
            return "SS+"
        case 12:
            return "SSS"
        case 13:
            return "SSS+"
        default:
            return "F"
        }
    }
}
