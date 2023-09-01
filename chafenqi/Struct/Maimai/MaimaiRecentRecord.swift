//
//  MaimaiRecentRecord.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/18.
//

import Foundation
import SwiftUI

let sharedMaimaiRecentRecordJSON = """
{"timestamp":1676382600,"title":"Grievous Lady", "diff": "master", "achievement":"100.9553%","is_new_record":1,"dx_score":"2810","fc_status":"fcplus","fs_status":null,"note_tap":"597,128,1,0,0","note_hold":"73,19,0,0,0","note_slide":"85,0,0,0,0","note_touch":"44,0,0,0,0","note_break":"36,5,0,0,0","max_combo":"988/988","max_sync":"583/1976","matching_1":"０Ｓｈｕ＿","matching_2":"―","matching_3":"―","createdAt":"2023-02-18 16:43:59.657 +00:00","updatedAt":"2023-02-18 16:43:59.657 +00:00"}
"""

struct MaimaiRecentRecord: Codable {
    static let shared = try! JSONDecoder().decode(MaimaiRecentRecord.self, from: sharedMaimaiRecentRecordJSON.data(using: .utf8)!)
    
    var timestamp: Int
    var title: String
    var diff: String
    var achievement: String
    var is_new_record: Int
    var dx_score: String
    var fc_status: String?
    var fs_status: String?
    var note_tap: String?
    var note_hold: String?
    var note_slide: String?
    var note_touch: String?
    var note_break: String?
    var max_combo: String
    var max_sync: String?
    var matching_1: String?
    var matching_2: String?
    var matching_3: String?
    var createdAt: String
    var updatedAt: String
    
    func getDate() -> Date {
        Date(timeIntervalSince1970: TimeInterval(timestamp))
    }
    
    func getDateString() -> String {
        let formatter = DateTool.shared.intTransformer
        
        return formatter.string(from: getDate())
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
        case "remaster":
            return 4
        default:
            return 3
        }
    }
    
    func getRate() -> String {
        let rawAchievement = Double(achievement.replacingOccurrences(of: "%", with: ""))!
        switch rawAchievement {
        case ..<50:
            return "D"
        case 50..<60:
            return "C"
        case 60..<70:
            return "B"
        case 70..<75:
            return "BB"
        case 75..<80:
            return "BBB"
        case 80..<90:
            return "A"
        case 90..<94:
            return "AA"
        case 94..<97:
            return "AAA"
        case 97..<98:
            return "S"
        case 98..<99:
            return "S+"
        case 99..<99.5:
            return "SS"
        case 99.5..<100:
            return "SS+"
        case 100..<100.5:
            return "SSS"
        case 100.5...:
            return "SSS+"
        default:
            return "F"
        }
    }
    
    func getGradeBadgeColor() -> Color {
        let rawAchievement = Double(achievement.replacingOccurrences(of: "%", with: ""))!
        switch rawAchievement {
        case ..<80:
            return Color.gray
        case 80..<97:
            return Color.gray
        case 97...:
            return Color.orange
        default:
            return Color.clear
        }
    }
    
    func getRawAchievement() -> Double {
        Double(achievement.replacingOccurrences(of: "%", with: ""))!
    }
    
    func getFCBadgeColor() -> Color {
        switch (fc_status) {
        case "clear":
            return Color.green
        case "fc", "fcplus":
            return Color.blue
        case "ap", "applus":
            return Color.yellow
        default:
            return Color.clear
        }
    }
    
    func getDescribingStatus() -> String {
        switch (fc_status) {
        case "clear":
            return "CLEAR"
        case "fc":
            return "FC"
        case "fcplus":
            return "FC+"
        case "ap":
            return "AP"
        case "applus":
            return "AP+"
        default:
            return "CLEAR"
        }
    }
}
