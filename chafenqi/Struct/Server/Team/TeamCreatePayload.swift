//
//  TeamCreatePayload.swift
//  chafenqi
//
//  Created by 刘易斯 on 2024/12/24.
//

import Foundation

struct TeamCreatePayload: Codable {
    let game: Int
    let displayName: String
    let style: String
    let remarks: String
    let promotable: Bool
}
