//
//  UserComment.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/8/15.
//

import Foundation

struct UserComment: Codable {
    static let shared = UserComment(id: 0, timestamp: 0, userId: 1, username: "Admin", content: "Test", musicId: 1, gameType: 1, replyId: -1)
    
    var id: Int
    var timestamp: Int
    var userId: Int
    var username: String
    var content: String
    var musicId: Int
    var gameType: Int
    var replyId: Int
}

extension UserComment {
    var dateString: String {
        DateTool.shared.intTransformer.string(from: Date(timeIntervalSince1970: Double(self.timestamp)))
    }
}
