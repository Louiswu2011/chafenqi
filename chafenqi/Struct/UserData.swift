//
//  UserDetailData.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/31.
//

import Foundation
import SwiftUI

struct UserData: Codable {
    var rating: Double
    var records: UserRecord
    var username: String
    
    init(){
        let placerholder = ScoreEntry(chartID: 1, constant: 14.4, status: "alljustice", level: "14", levelIndex: 3, levelLabel: "Master", musicID: 3, rating: 16.40, score: 1009560, title: "Y")
        let best = [ScoreEntry](repeating: placerholder, count: 100)
        let r10 = [ScoreEntry](repeating: placerholder, count: 10)
        rating = 17.00
        records = UserRecord(best: best, r10: r10)
        username = "louis"
    }

    
    func getAvgB30() -> Double {
        let b30 = self.records.best.sorted {
            $0.rating > $1.rating
        }.prefix(upTo: 30)
        
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
    
    func getMaximumRating() -> Double {
        let b1 = self.records.best.sorted {
            $0.rating > $1.rating
        }[0]
        
        return ( getAvgB30() * 30.0 + b1.rating * 10.0 ) / 40.0
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
}

struct UserRecord: Codable {
    var best: Array<ScoreEntry>
    var r10: Array<ScoreEntry>
}

struct ScoreEntry: Codable {
    var chartID: Int
    var constant: Double
    var status: String
    var level: String
    var levelIndex: Int
    var levelLabel: String
    var musicID: Int
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
        case "fullcombo", "fullchain":
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
            return Color.brown
        case 975000...999999:
            return Color.yellow.opacity(0.7)
        case 1000000...1007499:
            return Color.yellow
        case 1007500...1008999:
            return Color.red
        case 1009000...:
            return Color.red
        default:
            return Color.brown
        }
    }
    
    func shouldApplyRainbow() -> Bool {
        score >= 1007500
    }
    
    func getLevelColor() -> Color {
        switch (self.levelIndex) {
        case 0:
            return Color.green
        case 1:
            return Color.yellow
        case 2:
            return Color.red
        case 3:
            return Color.purple
        case 4:
            return Color.gray
        default:
            return Color.purple
        }
    }
    
    enum CodingKeys: String, CodingKey{
        case chartID = "cid"
        case constant = "ds"
        case status = "fc"
        case levelIndex = "level_index"
        case levelLabel = "level_label"
        case musicID = "mid"
        case rating = "ra"
        case level, score, title
    }
}
