//
//  TeamCourseRecord.swift
//  chafenqi
//
//  Created by 刘易斯 on 2024/12/24.
//

import Foundation

struct TeamCourseRecord: Codable {
    let id: Int
    let timestamp: Int
    let userId: Int
    let trackRecords: [TrackRecord]
    let cleared: Bool
    
    struct TrackRecord: Codable {
        let score: String
        let damage: Int
    }
}

extension TeamCourseRecord {
    func totalScore(mode: Int) -> String {
        return if mode == 0 {
            String(trackRecords.reduce(0) { $0 + (Int($1.score) ?? 0) })
        } else {
            String(format: "%.4f", trackRecords.reduce(0) { $0 + (Double($1.score.replacingOccurrences(of: "%", with: "")) ?? 0.0) }) + "%"
        }
    }
    
    func rawScore() -> Double {
        return trackRecords.reduce(0) { $0 + (Double($1.score.replacingOccurrences(of: "%", with: "")) ?? 0) }
    }
}
