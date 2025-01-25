//
//  CFQUserUploadStatus.swift
//  chafenqi
//
//  Created by Louis Wu on 2025/01/26.
//

import Foundation

struct CFQUserUploadStatus: Codable {
    var chunithm: Int
    var maimai: Int
    
    enum CodingKeys: String, CodingKey {
        case chunithm = "chu"
        case maimai = "mai"
    }
}
