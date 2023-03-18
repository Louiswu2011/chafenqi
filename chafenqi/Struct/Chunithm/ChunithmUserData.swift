//
//  UserDetailData.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/31.
//

import Foundation
import SwiftUI

struct ChunithmUserData: Codable {
    var rating: Double
    var records: UserRecord
    var username: String
    
    static let shared = ChunithmUserData(rating: 19.00, records: UserRecord(best: [], r10: []), username: "?")
    
    func getOverpower() -> Double {
        let qualifiedList = records.best.filter {
            ($0.levelIndex == 3 || $0.levelIndex == 4) && $0.score >= 975000
        }
        
        var overpower: Double = 0.0
        for entry in qualifiedList {
            let score = entry.score
            var rating: Double {
                switch (entry.score) {
                case 975000...999999:
                    return entry.constant + Double(entry.score - 975000) / 2500 * 0.1
                case 1000000...1004999:
                    return entry.constant + 1.0 + Double(entry.score - 1000000) / 1000 * 0.1
                case 1005000...1007499:
                    return entry.constant + 1.5 + Double(entry.score - 1005000) / 500 * 0.1
                case 1007500...1008999:
                    return entry.constant + 2.0 + Double(entry.score - 1007500) / 100 * 0.01
                case 1009000...1010000:
                    return entry.constant + 2.15
                default:
                    return 0
                }
            }
            var op: Double = 0.0
            var extra: Double {
                if (entry.getStatus() == "FC") {
                    return 0.5
                } else if (entry.getStatus() == "AJ") {
                    return 1.0
                } else {
                    return 0.0
                }
            }

            
            if (score <= 1007500) {
                op = rating * 5.0
            } else if (score < 1010000) {
                op = (entry.constant + 2.0) * 5.0 + Double((score - 1007500)) * 0.0015
            } else if (score == 1010000) {
                op = (entry.constant + 2.0) * 5.0 + 4.0
            }
            
            print("title \(entry.title), level \(entry.levelLabel), score \(score), base \(op), status \(entry.status), bonus \(extra)")
            if((extra == 0.0 && entry.getStatus() != "Clear") || (extra != 0.0 && entry.getStatus() == "Clear")) {
                print("Wrong extra value, got \(extra) while status is \(entry.getStatus())")
            }
            
            overpower += (op + extra)
        }
        
        for i in 10...15 {
            print("Level \(i): \(qualifiedList.filter {$0.level == "\(i)"}.count)")
            print("Level \(i)+: \(qualifiedList.filter {$0.level == "\(i)+"}.count)")
        }
        
        print(qualifiedList.count)
        return overpower
    }
    
    func getAvgB30() -> Double {
        let best = self.records.best.sorted {
            $0.rating > $1.rating
        }
        
        let length = best.count > 29 ? 30 : best.count
        let b30 = best.prefix(upTo: length)
        
        var avg: Double = 0.0
        b30.forEach { entry in
            avg += entry.rating
        }
        return avg / 30.0
    }
    
    func getAvgR10() -> Double {
        var avg: Double = 0.0
        self.records.r10.forEach { entry in
            avg += entry.rating
        }
        return avg / 10.0
    }
    
    func getRating() -> Double {
        return ((getAvgB30() * 30.0 + getAvgR10() * 10.0 ) / 40.0).cut(remainingDigits: 2)
    }
    
    func getMaximumRating() -> Double {
        let b1 = self.records.best.sorted {
            $0.rating > $1.rating
        }[0]
        
        return ((getAvgB30() * 30.0 + b1.rating * 10.0) / 40.0).cut(remainingDigits: 2)
    }
    
    func getRelativeR10Percentage() -> Double {
        let b1 = self.records.best.sorted {
            $0.rating > $1.rating
        }[0]
        
        if (abs(getAvgR10() - b1.rating) > 1) {
            return getAvgR10() / b1.rating
        } else {
            let head = Int(getAvgR10())
            return (getAvgR10() - Double(head)) / (b1.rating - Double(head))
        }
    }
    
    func getRelativePercentage() -> Double {
        if (abs(self.rating - getMaximumRating()) > 1) {
            return self.rating / getMaximumRating()
        } else {
            let head = Int(self.rating)
            return (self.rating - Double(head)) / (getMaximumRating() - Double(head))
        }
    }
    
    func isRecordDataEmpty() -> Bool {
        return self.records.r10.isEmpty || self.records.best.isEmpty
    }
}

struct UserRecord: Codable {
    var best: Array<ScoreEntry>
    var r10: Array<ScoreEntry>
}

struct ScoreEntry: Codable, Hashable {
    var chartId: Int
    var constant: Double
    var status: String
    var level: String
    var levelIndex: Int
    var levelLabel: String
    var musicId: Int
    var rating: Double
    var score: Int
    var title: String
    
    func getGrade() -> String {
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
    
    func getStatus() -> String {
        switch (self.status) {
        case "fullcombo", "fullchain2", "fullchain":
            return "FC"
        case "alljustice":
            return "AJ"
        default:
            return "Clear"
        }
    }
    
    func getClearBadgeColor() -> Color {
        switch (self.status) {
        case "fullcombo", "fullchain":
            return Color.blue.opacity(0.9)
        case "alljustice":
            return Color.yellow
        default:
            return Color.red
        }
    }
    
    func getGradeBadgeColor() -> Color {
        switch (score) {
        case 950000...974999:
            return Color.gray
        case 975000...999999:
            return Color.yellow.opacity(0.7)
        case 1000000...1007499:
            return Color.yellow
        case 1007500...1008999:
            return Color.red
        case 1009000...:
            return Color.red
        default:
            return Color.gray
        }
    }
    
    func shouldApplyRainbow() -> Bool {
        score >= 1007500
    }
    
    enum CodingKeys: String, CodingKey{
        case chartId = "cid"
        case constant = "ds"
        case status = "fc"
        case levelIndex = "level_index"
        case levelLabel = "level_label"
        case musicId = "mid"
        case rating = "ra"
        case level, score, title
    }
}
