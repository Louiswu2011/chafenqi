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
    
    var uid: Int
    var timestamp: Int
    var mode: Int
    var musicId: Int
    var reply: Int
    var like: Int
    var dislike: Int
    
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
            "mode": mode,
            "musicId": musicId,
            "reply": reply
        ])
    }
    
    func delete() async -> Bool {
        await post(url: URL(string: "http://43.139.107.206/comment/add")!, body: ["uid": uid])
    }
    
    private func post(url: URL, body: Dictionary<AnyHashable, AnyHashable>) async -> Bool {
        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            
            var (_, response) = try await URLSession.shared.data(for: request)
            return response.statusCode() == 200
        } catch {
            return false
        }
    }
}

extension Array<Comment> {
    init(by: String) async {
        // Get comments from specific sender
        self = []
        self = await getComments(by: by)
    }
    
    init(mode: Int, musicId: Int) async {
        // Get comments from specific songs
        self = []
        self = await getComments(mode: mode, musicId: musicId)
    }
    
    private func getComments(mode: Int, musicId: Int) async -> Array<Comment> {
        let url = URL(string: "http://43.139.107.206/comment")!
        let body = ["mode": mode, "musicId": musicId]

        return await getCommentsWithPayload(url: url, payload: body)
    }
    
    private func getComments(by: String) async -> Array<Comment> {
        let url = URL(string: "http://43.139.107.206/comment/by")!
        let body = ["sender": by]
        
        return await getCommentsWithPayload(url: url, payload: body)
    }
    
    private func getCommentsWithPayload(url: URL, payload: Dictionary<AnyHashable, AnyHashable>) async -> Array<Comment> {
        do {
            let body = try JSONSerialization.data(withJSONObject: payload)
            var request = URLRequest(url: url)
            
            request.httpMethod = "POST"
            request.httpBody = body
            request.setValue("\(data!.count)", forHTTPHeaderField: "Content-Length")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            var (data, response) = try await URLSession.shared.data(for: request)
            if (response.statusCode() != 200) {
                return []
            }
            
            return try JSONDecoder().decode(Array<Comment>.self, from: data)
        } catch {
            return []
        }
    }
}

