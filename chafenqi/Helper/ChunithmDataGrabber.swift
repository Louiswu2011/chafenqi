//
//  ProberDataGrabber.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/8.
//

import Foundation

struct ChunithmDataGrabber {
    static func getSongDataSetFromServer() async throws ->  Set<SongData>{
        let request = URLRequest(url: URL(string: "https://www.diving-fish.com/api/chunithmprober/music_data")!)
        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        return try! decoder.decode(Set<SongData>.self, from: data)
    }

    
    static func getUserNickname(username: String) async throws -> String {
        let body = ["username": username]
        let bodyData = try! JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await postWithPayload(url: URL(string: "https://www.diving-fish.com/api/chunithmprober/query/player")!, payload: bodyData)
        let decoder = JSONDecoder()
        
        do {
            return try decoder.decode(UserScoreData.self, from: data).nickname
        } catch {
            throw CFQError.invalidResponseError(response: String(decoding: data, as: UTF8.self))
        }
    }
    
    static func loginAs(username: String, password: String) async throws -> (String, String) {
        let body = ["username": username, "password": password]
        let bodyData = try! JSONSerialization.data(withJSONObject: body)
        
        let (_, response) = try await postWithPayload(url: URL(string: "https://www.diving-fish.com/api/maimaidxprober/login")!, payload: bodyData)
        
        let httpResponse = response as! HTTPURLResponse
        let rawCookie = httpResponse.value(forHTTPHeaderField: "Set-Cookie")
        
        if (httpResponse.statusCode == 401) {
            throw CFQError.AuthenticationFailedError
        }

        let tokenComponent = rawCookie!.components(separatedBy: ";")[0]
        let token = String(tokenComponent[tokenComponent.index(after: tokenComponent.firstIndex(of: "=")!)...])
        
        return (rawCookie!, token)
    }
    
    static private func postWithPayload(url: URL, payload: Data) async throws -> (Data, URLResponse) {
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.httpBody = payload
        request.setValue("\(data!.count)", forHTTPHeaderField: "Content-Length")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        return try await URLSession.shared.data(for: request)
    }
    
    static func getUserRecord(token: String) async throws -> Data {
        var request = URLRequest(url: URL(string: "https://www.diving-fish.com/api/chunithmprober/player/records")!)
        
        request.httpMethod = "GET"
        request.setValue("jwt_token=\(token)", forHTTPHeaderField: "Cookie")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return data
    }
}
