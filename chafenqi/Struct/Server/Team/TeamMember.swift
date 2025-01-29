//
//  TeamMember.swift
//  chafenqi
//
//  Created by 刘易斯 on 2024/12/24.
//

import Foundation

struct TeamMember: Codable {
    let id: Int
    let userId: Int
    let nickname: String
    let avatar: String
    let trophy: String
    let rating: String
    let joinAt: Int
    let activityPoints: Int
    let playCount: Int
    let lastActivityAt: Int
}
