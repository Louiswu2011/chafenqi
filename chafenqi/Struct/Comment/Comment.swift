//
//  Comment.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/3/13.
//

import Foundation

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
    
    static let shared = Comment(message: "这是一条评论", sender: "这是一个发言者", nickname: "系统管理员", uid: 1, timestamp: 10003442, mode: 0, musicId: 1, reply: -1, like: 0, dislike: 0)
    
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
        await post(url: URL(string: "http://43.139.107.206/comment/add")!, body: ["uid": uid])
    }
    
    func getDate() -> Date {
        Date(timeIntervalSince1970: TimeInterval(timestamp))
    }
    
    func getDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        
        return formatter.string(from: getDate())
    }
    
    private func post(url: URL, body: Dictionary<AnyHashable, AnyHashable>) async -> Bool {
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            let (_, response) = try await URLSession.shared.data(for: request)
            return response.statusCode() == 200
        } catch {
            return false
        }
    }
}

struct CommentHelper {
    static func getComments(mode: Int, musicId: Int) async -> Array<Comment> {
        let url = URL(string: "http://43.139.107.206/comment")!
        let body = ["mode": mode, "musicId": musicId]

        return await getCommentsWithQuery(url: url, queryBody: body)
    }
    
    static func getComments(by: String) async -> Array<Comment> {
        let url = URL(string: "http://43.139.107.206/comment/by")!
        let body = ["sender": by]
        
        return await getCommentsWithQuery(url: url, queryBody: body)
    }
    
    static private func getCommentsWithQuery(url: URL, queryBody: Dictionary<AnyHashable, AnyHashable>) async -> Array<Comment> {
        do {
            var request = URLRequest(url: url)

            request.httpMethod = "POST"
            request.httpBody = try JSONSerialization.data(withJSONObject: queryBody)
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let (data, response) = try await URLSession.shared.data(for: request)
            if (response.statusCode() != 200) {
                return []
            }
            
            return try JSONDecoder().decode(Array<Comment>.self, from: data)
        } catch {
            print(error)
            return []
        }
    }
}

