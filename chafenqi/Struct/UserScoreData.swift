//
//  UserScoreData.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/17.
//

import Foundation
import SwiftUI

struct UserScoreData: Codable {
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
            case "fullcombo":
                return "FC"
            case "AllJustice":
                return "AJ"
            default:
                return "Clear"
            }
        }
        
        func getClearBadgeColor() -> Color {
            switch (self.status) {
            case "fullcombo":
                return Color.blue.opacity(0.9)
            case "AllJustice":
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
    
    struct ScoreRecord: Codable {
        var b30: Array<ScoreEntry>
        var r10: Array<ScoreEntry>
    }
    
    var nickname: String
    var rating: Double
    var records: ScoreRecord
    var username: String
    
    init() {
        nickname = "CHUNITHM"
        rating = 17.10
        records = ScoreRecord(b30: Array<ScoreEntry>(), r10: Array<ScoreEntry>())
        username = "CHUNITHM"
    }
    
    func getAvgB30() -> Double {
        var avg: Double = 0.0
        self.records.b30.forEach { entry in
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
        return ( getAvgB30() * 30.0 + self.records.b30[0].rating * 10.0 ) / 40.0
    }
    
    func getRelativeR10Percentage() -> Double {
        if (abs(getAvgR10() - self.records.b30[0].rating) > 1) {
            return getAvgR10() / self.records.b30[0].rating
        } else {
            let head = Int(getAvgR10())
            return (getAvgR10() - Double(head)) / (self.records.b30[0].rating - Double(head))
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
