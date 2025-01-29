//
//  UserChunithmExtraEntry.swift
//  chafenqi
//
//  Created by 刘易斯 on 2024/12/24.
//

import Foundation

struct UserChunithmExtra: Codable, Equatable {
    let characters: [UserChunithmCharacterEntry]
    let mapIcons: [UserChunithmMapIconEntry]
    let nameplates: [UserChunithmNameplateEntry]
    let skills: [UserChunithmSkillEntry]
    let tickets: [UserChunithmTicketEntry]
    let trophies: [UserChunithmTrophyEntry]
    
    static let empty = UserChunithmExtra(characters: [], mapIcons: [], nameplates: [], skills: [], tickets: [], trophies: [])
}

struct UserChunithmCharacterEntry: Codable, Equatable {
    let name: String
    let url: String
    let rank: String
    let exp: Double
    let current: Bool
}

struct UserChunithmMapIconEntry: Codable, Equatable {
    let name: String
    let url: String
    let current: Bool
}

struct UserChunithmNameplateEntry: Codable, Equatable {
    let name: String
    let url: String
    let current: Bool
}

struct UserChunithmSkillEntry: Codable, Equatable {
    let name: String
    let url: String
    let level: Int
    let description: String
    let current: Bool
}

struct UserChunithmTicketEntry: Codable, Equatable {
    let name: String
    let url: String
    let count: Int
    let description: String
}

struct UserChunithmTrophyEntry: Codable, Equatable {
    let name: String
    let type: String
    let description: String
}
