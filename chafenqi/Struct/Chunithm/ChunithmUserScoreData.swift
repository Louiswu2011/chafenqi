//
//  UserScoreData.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/17.
//

import Foundation
import SwiftUI

struct ChunithmUserScoreData: Codable {
    static let shared = ChunithmUserScoreData(nickname: "", rating: 0.0, records: ScoreRecord(b30: [], r10: []), username: "")
    
    struct ScoreRecord: Codable {
        var b30: Array<ScoreEntry>
        var r10: Array<ScoreEntry>
    }
    
    var nickname: String
    var rating: Double
    var records: ScoreRecord
    var username: String
}
