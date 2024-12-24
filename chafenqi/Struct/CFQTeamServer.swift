//
//  CFQTeamServer.swift
//  chafenqi
//
//  Created by 刘易斯 on 2024/12/24.
//

import Foundation

struct CFQTeamServer {
    static let session = URLSession(configuration: .default)
    static let decoder = JSONDecoder()

    
    static private func fetchFromServer(
        method: String,
        path: String,
        payload: Data? = nil,
        queries: [URLQueryItem] = [],
        token: String? = nil
    ) async throws -> (Data, URLResponse) {
        var url = URLComponents(string: CFQServer.serverAddress + "api/team/")!
        if !queries.isEmpty {
            url.queryItems = queries
        }
        var request = URLRequest(url: url.url!)
        request.httpMethod = method
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        if let payload = payload {
            request.setValue("\(payload.count)", forHTTPHeaderField: "Content-Length")
            request.httpBody = payload
        }
        if let token = token {
            request.setValue("bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let (data, response) = try await session.data(for: request)
        print("Response from \(path)")
        print("Status Code: \(response.statusCode())")
        print("Response Body Length: \(data.count)")
        return (data, response)
    }
    
    static private func fetchFromTeam(
        token: String,
        game: Int,
        teamId: Int,
        method: String,
        path: String,
        payload: Data? = nil,
        queries: [URLQueryItem] = []
    ) async throws -> (Data, URLResponse) {
        return try await fetchFromServer(method: method, path: "\(game.gameString())/\(teamId)/\(path)", payload: payload, queries: queries, token: token)
    }
    
    static func fetchCurrentTeam(
        authToken: String,
        game: Int
    ) async -> Int? {
        do {
            let (data, response) = try await fetchFromServer(method: "GET", path: "\(game.gameString())/current", token: authToken)
            
            return Int(String(data: data, encoding: .utf8) ?? "")
        } catch {
            print("Failed to fetch current team: \(error)")
            return nil
        }
    }
    
    static func fetchTeamInfo(
        authToken: String,
        game: Int,
        teamId: Int
    ) async {
        
    }
}

extension Int {
    func gameString() -> String {
        return if self == 0 { "chunithm" } else { "maimai" }
    }
}
