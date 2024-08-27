//
//  CFQFilterOptions.swift
//  chafenqi
//
//  Created by xinyue on 2023/5/29.
//

import Foundation
import SwiftUI

enum CFQSortKey: String, CaseIterable, Identifiable, Hashable {
    var id: Self {
        return self
    }
    
    case level = "等级"
    case constant = "定数"
    case bpm = "BPM"
}

enum CFQMaimaiSortDifficulty: String, CaseIterable, Identifiable, Hashable {
    var id: Self {
        return self
    }
    
    case basic = "Basic"
    case advanced = "Advanced"
    case expert = "Expert"
    case master = "Master"
    case remaster = "Re:Master"
}

enum CFQChunithmSortDifficulty: String, CaseIterable, Identifiable, Hashable {
    var id: Self {
        return self
    }
    
    case basic = "Basic"
    case advanced = "Advanced"
    case expert = "Expert"
    case master = "Master"
    case ultima = "Ultima"
}

enum CFQSortMethod: String, CaseIterable, Identifiable, Hashable {
    var id: Self {
        return self
    }
    
    case ascent = "升序"
    case descent = "降序"
    case random = "乱序"
}

struct SongListFilterOptions: Equatable {
    var versionSelection: [String] = []
    var levelSelection: [String] = []
    var genreSelection: [String] = []
    
    var sortEnabled: Bool = false
    var sortOrientation: CFQSortMethod = .descent
    var sortBy: CFQSortKey = .level
    var sortDifficulty: Int = 0
    
    var hideNotPlayed: Bool = false
    var hideUtage: Bool = true
    var hideWorldsEnd: Bool = true
    
    var onlyShowLoved: Bool = false
}
