//
//  MaimaiPlayerProfile.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/3.
//

import Foundation

struct MaimaiPlayerProfile: Codable {
    var additionalRating: Int
    var bindQQ: String
    var nickname: String
    var plate: String
    var privacy: Bool
    var username: String
    
    enum CodingKeys: String, CodingKey {
        case additionalRating = "additional_rating"
        case bindQQ = "bind_qq"
        case nickname
        case plate
        case privacy
        case username
    }
    
    init() {
        additionalRating = 0
        bindQQ = "0"
        nickname = "MAIMAI"
        plate = "None"
        privacy = false
        username = "MAIMAI"
    }
}
