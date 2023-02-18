//
//  MaimaiRecentRecord.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/18.
//

import Foundation

struct MaimaiRecentRecord: Codable {
    var timestamp: Int
    var title: String
    var achievement: String
    var is_new_record: Int
    var dx_score: String
    var fc_status: String
    var fs_status: String
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
}
