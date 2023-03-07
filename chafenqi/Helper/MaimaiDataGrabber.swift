//
//  MaimaiDataGrabber.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/3.
//

import Foundation

struct MaimaiDataGrabber {
    
    // Data: Additional Rating, Bind QQ, Nickname, Plate, Privacy, Username
    static func getPlayerProfile(token: String) async throws -> Data {
        let url = URL(string: "https://www.diving-fish.com/api/maimaidxprober/player/profile")!
        
        var request = URLRequest(url: url)
        request.setValue("jwt_token=\(token)", forHTTPHeaderField: "Cookie")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        return data
    }
    
    static func getPlayerRecord(token: String) async throws -> Data {
        let url = URL(string: "https://www.diving-fish.com/api/maimaidxprober/player/records")!
        
        var request = URLRequest(url: url)
        request.setValue("jwt_token=\(token)", forHTTPHeaderField: "Cookie")
        
        let (data, _) = try await URLSession.shared.data(for: request)
        
        return data
    }
    
    static func getMusicData() async throws -> Data {
        let request = URLRequest(url: URL(string: "https://www.diving-fish.com/api/maimaidxprober/music_data")!)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return data
    }
    
    static func getChartStat() async throws -> Data {
        let request = URLRequest(url: URL(string: "https://www.diving-fish.com/api/maimaidxprober/chart_stats")!)

        let (data, _) = try await URLSession.shared.data(for: request)
        return data
    }
    
    static func getRatingRanking() async throws -> Data {
        let request = URLRequest(url: URL(string: "https://www.diving-fish.com/api/maimaidxprober/rating_ranking")!)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        return data
    }
    
    static func getRecentData(username: String, limit: Int = 30) async throws -> Data {
        let request = URLRequest(url: URL(string: "http://43.139.107.206/recent?mode=1&username=\(username.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")&count=\(limit)")!)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        let httpResponse = response as! HTTPURLResponse
        if (httpResponse.statusCode == 400) {
            throw CFQError.BadRequestError
        }
        
        return data
    }
    
    static func getSongCoverUrl(source: Int, coverId: String) -> URL {
        return URL(string: "https://www.diving-fish.com/covers/\(coverId).png")!
    }
}
