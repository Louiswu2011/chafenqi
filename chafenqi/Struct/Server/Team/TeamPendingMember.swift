//
//  TeamPendingMember.swift
//  chafenqi
//
//  Created by 刘易斯 on 2024/12/24.
//

import Foundation

struct TeamPendingMember: Codable {
    let id: Int
    let userId: Int
    let nickname: String
    let avatar: String
    let trophy: String
    let rating: String
    let timestamp: Int
    let status: String
    let message: String
}
