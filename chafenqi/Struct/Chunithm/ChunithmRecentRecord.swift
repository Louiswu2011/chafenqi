//
//  ChunithmRecentRecord.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/19.
//

import Foundation

struct ChunithmRecentRecord: Codable {
    var timestamp: Int
    var title: String
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
}
