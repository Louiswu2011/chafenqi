//
//  Comment.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/3/13.
//

import Foundation

@available(*, deprecated, message: "No longer used in v2. See UserComment instead.")
struct Comment: Codable {
    var message: String
    var sender: String
    var nickname: String
    
    var uid: Int
    var timestamp: Int
    var mode: Int
    var musicId: Int
    var reply: Int
    var like: Int
    var dislike: Int
    
    static let shared = Comment(message: "这是一条评论", sender: "这是一个发言者", nickname: "系统管理员", uid: 1, timestamp: 10003442, mode: 0, musicId: 1, reply: 2, like: 0, dislike: 0)
    
    func concatReply() -> String {
        if (reply != -1) {
            return "回复#\(reply): \(message)"
        } else {
            return message
        }
    }
    
    mutating func addLike() {
        self.like += 1
    }
    
    mutating func addDislike() {
        self.dislike += 1
    }
    
    func postLike() async -> Bool {
        await post(url: URL(string: "http://43.139.107.206/comment/like")!, body: ["uid": uid])
    }
    
    func postDislike() async -> Bool{
        await post(url: URL(string: "http://43.139.107.206/comment/dislike")!, body: ["uid": uid])
    }
    
    func add() async -> Bool {
        await post(url: URL(string: "http://43.139.107.206/comment/add")!, body: [
            "message": message,
            "sender": sender,
            "nickname": nickname,
            "mode": mode,
            "musicId": musicId,
            "reply": reply
        ])
    }
    
    func delete() async -> Bool {
        await post(url: URL(string: "http://43.139.107.206/comment/delete")!, body: ["uid": uid])
    }
    
    func getDate() -> Date {
        Date(timeIntervalSince1970: TimeInterval(timestamp))
    }
    
    func getDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy/MM/dd HH:mm"
        
        return formatter.string(from: getDate())
    }
    
    private func post(url: URL, body: Dictionary<AnyHashable, AnyHashable>) async -> Bool {
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let (_, response) = try await URLSession.shared.data(for: request)
            return response.statusCode() == 200
        } catch {
            return false
        }
    }
}

struct CommentHelper {
    static func postComment(message: String, sender: String, nickname: String, mode: Int, musicId: Int, reply: Int = -1) async -> Bool {
        let url = URL(string: "http://43.139.107.206/comment/add")!
        let body = [
            "message": message,
            "sender": sender,
            "nickname": nickname,
            "mode": mode,
            "musicId": musicId,
            "reply": reply
        ] as [String : AnyHashable]
        
        do {
            var request = URLRequest(url: url)

            request.httpMethod = "POST"
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let (_, response) = try await URLSession.shared.data(for: request)
            if (response.statusCode() != 200) {
                return false
            }
            
            return true
        } catch {
            print(error)
            return false
        }
    }
}

