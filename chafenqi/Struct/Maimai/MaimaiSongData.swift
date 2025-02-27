//
//  MaimaiMusicData.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/3.
//

import Foundation
import SwiftUI

struct MaimaiSongData: Codable, Hashable, Comparable {
    static func < (lhs: MaimaiSongData, rhs: MaimaiSongData) -> Bool {
        lhs.musicId < rhs.musicId
    }
    
    static func == (lhs: MaimaiSongData, rhs: MaimaiSongData) -> Bool {
        lhs.musicId == rhs.musicId
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(musicId)
    }
    
    struct MaimaiSongChartData: Codable {
        var notes: Array<Int>
        var charter: String
    }

    struct MaimaiSongBasicInfo: Codable {
        var title: String
        var artist: String
        var genre: String
        var bpm: Int
        var version: Int
        var isNew: Bool
        
        var from: String = ""
        
        enum CodingKeys: String, CodingKey {
            case title
            case artist
            case genre
            case bpm
            case version
            case isNew
        }
    }
    
    var musicId: Int
    var title: String
    var type: String
    var constants: Array<Double>
    var level: Array<String>
    var charts: Array<MaimaiSongChartData>
    var coverId: Int
    var basicInfo: MaimaiSongBasicInfo
    
    func getLevelColor(index: Int) -> Color {
        switch (index) {
        case 0:
            return Color.green
        case 1:
            return Color.yellow
        case 2:
            return Color.red
        case 3:
            return Color.purple
        case 4:
            return Color(red: 171 / 255, green: 147 / 255, blue: 191 / 255)
        default:
            return Color.purple
        }
    }
    
    func getNumericLevelByLabel(_ string: String) -> Double {
        if self.basicInfo.genre == "宴会場" { return 0.0 }
        func getNumericLevel(for level: String) -> Double {
            var numericLevel: Double = Double(level.replacingOccurrences(of: "+", with: "")) ?? 0.0
            if level.contains("+") {
                numericLevel += 0.5
            }
            return numericLevel
        }
        switch string {
        case "Basic":
            return getNumericLevel(for: self.level[0])
        case "Advanced":
            return getNumericLevel(for: self.level[1])
        case "Expert":
            return getNumericLevel(for: self.level[2])
        case "Master":
            return getNumericLevel(for: self.level[3])
        default:
            if self.level.count < 5 {
                return 0.0
            } else {
                return getNumericLevel(for: self.level[4])
            }
        }
    }
    
    func getNumericLevelByLevelIndex(_ index: Int) -> Double {
        if self.basicInfo.genre == "宴会場" { return 0.0 }
        func getNumericLevel(for level: String) -> Double {
            var numericLevel: Double = Double(level.replacingOccurrences(of: "+", with: "")) ?? 0.0
            if level.contains("+") {
                numericLevel += 0.5
            }
            return numericLevel
        }
        if index == 4 && self.level.count < 5 { return 0.0 }
        if !(0...4 ~= index) { return 0.0 }
        return getNumericLevel(for: self.level[index])
    }
    
    func levelLabeltoLevelIndex(_ label: String) -> Int {
        switch label {
        case "Basic":
            return 0
        case "Advanced":
            return 1
        case "expert":
            return 2
        case "master":
            return 3
        default:
            if self.level.count < 5 {
                return 0
            } else {
                return 4
            }
        }
    }
}

extension MaimaiSongData {
    var coverURL: URL {
        return MaimaiDataGrabber.getSongCoverUrl(source: 0, coverId: self.coverId)
    }
}

extension MaimaiSongData.MaimaiSongChartData {
    func appendDecoration(_ score: Double) -> String { "-\(String(format: "%.4f", score))%" }
    
    // Errors: [Tap/Hold/Slide/Touch]:[Great, Good, Miss] [Break]:[HGreat, LGreat, Good, Miss]
    var errors: [Double] {
        var basicUnitScore: Double {
            return 100.0 / Double(self.notes[0] + 2 * self.notes[1] + 3 * self.notes[2] + self.notes[3] + 5 * self.notes[4])
        }
        let breakUnitScore: Double = 1.0 / Double(self.notes.last ?? 1)
        return [basicUnitScore, breakUnitScore]
    }
    
    var possibleNormalLosses: [[String]] {
        let unitScores = self.errors
        let nor = unitScores[0]
        return [
            [appendDecoration(nor * 0.2), appendDecoration(nor * 0.5), appendDecoration(nor)],
            [appendDecoration(nor * 0.4), appendDecoration(nor), appendDecoration(nor * 2)],
            [appendDecoration(nor * 0.6), appendDecoration(nor * 1.5), appendDecoration(nor * 3)],
            [appendDecoration(nor * 0.2), appendDecoration(nor * 0.5), appendDecoration(nor)]
        ]
    }
    
    var possibleBreakLosses: [String] {
        // [HPerfect, LPerfect, HGreat, MGreat, LGreat, Good, Miss]
        let unitScores = self.errors
        let nor = unitScores[0]
        let br = unitScores[1]
        return [appendDecoration(br * 0.25), appendDecoration(br * 0.5), appendDecoration(br * 0.6 + nor), appendDecoration(br * 0.6 + nor * 2), appendDecoration(br * 0.6 + nor * 2.5), appendDecoration(br * 0.7 + nor * 3), appendDecoration(br * 1 + nor * 5)]
    }
    
    var lossUntilSSS: Double {
        return 1 / (errors[0] * 0.2)
    }
    
    var lossUntilSSSPlus: Double {
        return 0.5 / (errors[0] * 0.2)
    }
    
    var breakToGreatRatio: Double {
        return (errors[1] * 0.25) / (errors[0] * 0.2)
    }
}
