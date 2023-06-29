//
//  UserInfoFetcher.swift
//  chafenqi
//
//  Created by xinyue on 2023/6/28.
//

import Foundation
import UIKit

struct Maimai: Codable {
    var uid: Int
    var nickname: String
    var trophy: String
    var rating: Int
    var maxRating: Int
    var star: Int
    var charUrl: String
    var gradeUrl: String
    var playCount: Int
    var stats: String
    var updatedAt: String
    var createdAt: String
    
    static let empty = Maimai(uid: -1, nickname: "暂无数据", trophy: "", rating: 0, maxRating: 0, star: 0, charUrl: "", gradeUrl: "", playCount: 0, stats: "", updatedAt: "", createdAt: "")
}

struct Chunithm: Codable {
    var uid: Int
    var nickname: String
    var trophy: String
    var plate: String
    var dan: Int
    var ribbon: Int
    var rating: Double
    var maxRating: Double
    var overpower_raw: Double
    var overpower_percent: Double
    var lastPlayDate: Int
    var charUrl: String
    var friendCode: String
    var currentGold: Int
    var totalGold: Int
    var playCount: Int
    var updatedAt: String
    var createdAt: String
    
    static let empty = Chunithm(uid: -1, nickname: "暂无数据", trophy: "", plate: "", dan: 0, ribbon: 0, rating: 0.0, maxRating: 0.0, overpower_raw: 0.0, overpower_percent: 0.0, lastPlayDate: 0, charUrl: "", friendCode: "", currentGold: 0, totalGold: 0, playCount: 0, updatedAt: "", createdAt: "")
}

struct UserInfoFetcher {
    static var cachedMaimai = Maimai.empty
    static var cachedChunithm = Chunithm.empty
    static var cachedMaimaiRecentOne: CFQMaimai.RecentScoreEntry?
    static var cachedChunithmRecentOne: CFQChunithm.RecentScoreEntry?
    static var cachedMaimaiRecentOneSong: MaimaiSongData?
    static var cachedChunithmRecentOneSong: ChunithmMusicData?
    static var cachedMaimaiCover = UIImage()
    static var cachedChunithmCover = UIImage()
    
    static var lastErrorCause = ""
    
    static var session = URLSession.shared
    static var decoder = JSONDecoder()
    
    static var jwtToken = ""
    
    static func refreshJwtToken() {
        self.jwtToken = UserDefaults(suiteName: "group.com.nltv.chafenqi.shared")!.string(forKey: "JWT")!
    }
    
    static func refreshData() async throws {
        refreshJwtToken()
        self.cachedMaimai = try await fetchGameData(Maimai.self, path: "api/maimai/info")
        self.cachedChunithm = try await fetchGameData(Chunithm.self, path: "api/chunithm/info")
    }
    
    static func fetchFromServer(path: String) async throws -> (Data, URLResponse) {
        let url = URLComponents(string: "http://43.139.107.206:8083/" + path)!
        var request = URLRequest(url: url.url!)
        request.httpMethod = "GET"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        if (!self.jwtToken.isEmpty) {
            request.setValue("bearer \(self.jwtToken)", forHTTPHeaderField: "Authorization")
        }
        let (data, response) = try await URLSession.shared.data(for: request)
        if response.statusCode() != 200 {
            self.lastErrorCause = "token: \(jwtToken)\nresponse: \(response.statusCode())\nerror: "
            throw CFQError.invalidResponseError(response: String(decoding: data, as: UTF8.self) + "\(response.statusCode())")
        }
        return (data, response)
    }
    
    static func fetchGameData<T: Decodable>(_ type: T.Type, path: String) async throws -> T {
        let (data, _) = try await fetchFromServer(path: path)
        return try decoder.decode(T.self, from: data)
    }
    
}
