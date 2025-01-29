//
//  MaimaiPlayerInfoDTO.swift
//  chafenqi
//
//  Created by 刘易斯 on 2024/12/05.
//

struct UserMaimaiExtra: Codable {
    let avatars: [UserMaimaiAvatarEntry]
    let characters: [UserMaimaiCharacterEntry]
    let frames: [UserMaimaiFrameEntry]
    let nameplates: [UserMaimaiNameplateEntry]
    let partners: [UserMaimaiPartnerEntry]
    let trophies: [UserMaimaiTrophyEntry]
    
    static let empty = UserMaimaiExtra(avatars: [], characters: [], frames: [], nameplates: [], partners: [], trophies: [])
}

struct UserMaimaiAvatarEntry: Codable, Equatable {
    let name: String
    let url: String
    let description: String
    let area: String
    let current: Bool
}

struct UserMaimaiCharacterEntry: Codable, Equatable {
    let name: String
    let url: String
    let description: String
    let level: String
    let area: String
    let current: Bool
}

struct UserMaimaiFrameEntry: Codable, Equatable {
    let name: String
    let url: String
    let description: String
    let area: String
    let current: Bool
}

struct UserMaimaiNameplateEntry: Codable, Equatable {
    let name: String
    let url: String
    let description: String
    let area: String
    let current: Bool
}

struct UserMaimaiPartnerEntry: Codable, Equatable {
    let name: String
    let url: String
    let description: String
    let current: Bool
}

struct UserMaimaiTrophyEntry: Codable, Equatable {
    let name: String
    let description: String
    let type: String
    let current: Bool
}
