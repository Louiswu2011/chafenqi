//
//  ProberDataGrabber.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/8.
//

import Foundation

struct ChunithmDataGrabber {
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
        request.setValue("\(payload.count)", forHTTPHeaderField: "Content-Length")
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
    
    static func getRecentData(username: String, limit: Int = 30) async throws -> Data {
        let request = URLRequest(url: URL(string: "http://43.139.107.206/recent?mode=0&username=\(username.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")&count=\(limit)")!)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        if (response.statusCode() == 400) {
            throw CFQError.BadRequestError
        }
        
        return data
    }
    
    static func getSongCoverUrl(source: Int, musicId: String) -> URL {
        return URL(string: "http://43.139.107.206:8083/api/chunithm/cover?musicId=\(musicId)")!
    }
}
