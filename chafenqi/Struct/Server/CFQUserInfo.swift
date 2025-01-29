//
//  CFQUserInfo.swift
//  chafenqi
//
//  Created by 刘易斯 on 2024/12/05.
//

import Foundation

struct CFQUserInfo: Codable {
    var id: Int
    var username: String
    var password: String
    var premiumUntil: Int
    var bindQQ: String
    var createdAt: Int
    var lastLogin: Int
}
