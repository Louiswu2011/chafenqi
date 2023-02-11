//
//  MaimaiRatingRanking.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/11.
//

import Foundation

struct MaimaiPlayerRating: Codable {
    var username: String
    var rating: Int
    
    enum CodingKeys: String, CodingKey {
        case username
        case rating = "ra"
    }
}
