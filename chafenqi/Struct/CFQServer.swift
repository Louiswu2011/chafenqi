//
//  CFQServer.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/5/4.
//

import Foundation
import Crypto
import AlertToast
import UIKit

struct CFQServer {
    enum GameType: String, Hashable, CaseIterable, Identifiable {
        var id: Self {
            return self
        }
        
        case Maimai = "舞萌DX"
        case Chunithm = "中二节奏NEW"
    }
    
    static let session = URLSession(configuration: .default)
    static let encoder = JSONEncoder()
    static let decoder = JSONDecoder()
    
    static let serverAddress = SharedValues.apiServerAddress
    
    struct User {
        static func auth(username: String, password: String) async throws -> String {
            let payload = try JSONSerialization.data(withJSONObject: ["username": username, "password": password.sha256String])
            let (data, _) = try await CFQServer.fetchFromServer(method: "POST", path: "api/auth/login", payload: payload)
            let token = String(decoding: data, as: UTF8.self)
            return token
        }
        
        static func register(username: String, password: String) async throws {
            let payload = try JSONSerialization.data(withJSONObject: ["username": username])
            let (_, _) = try await CFQServer.fetchFromServer(method: "POST", path: "api/auth/register/checkAvailability", payload: payload)
            let registerPayload = try JSONSerialization.data(withJSONObject: ["username": username, "password": password.sha256String])
            let (_, _) = try await CFQServer.fetchFromServer(method: "POST", path: "api/auth/register", payload: registerPayload)
        }
        
        static func checkPremium(authToken: String) async throws -> Bool {
            do {
                let (data, _) = try await CFQServer.fetchFromServer(method: "GET", path: "api/user/info", token: authToken)
                let info = try decoder.decode(CFQUserInfo.self, from: data)
                print("[CFQServer] Premium checking return \(info.premiumUntil)")
                return info.premiumUntil >= Int(Date().timeIntervalSince1970)
            } catch CFQServerError.UserNotPremiumError {
                return false
            }
        }
        
        static func fetchUserInfo(authToken: String) async throws -> CFQUserInfo? {
            do {
                let (data, response) = try await CFQServer.fetchFromServer(method: "GET", path: "api/user/info", token: authToken)
                let info = try decoder.decode(CFQUserInfo.self, from: data)
                return info
            } catch {
                return nil
            }
        }
        
        static func checkPremiumExpireTime(authToken: String) async throws -> TimeInterval {
            do {
                let (data, response) = try await CFQServer.fetchFromServer(method: "GET", path: "api/user/info", token: authToken)
                let info = try decoder.decode(CFQUserInfo.self, from: data)
                return TimeInterval(info.premiumUntil)
            } catch {
                return 0
            }
        }
        
        static func redeem(username: String, code: String) async throws -> String {
            let payload = try JSONSerialization.data(withJSONObject: ["code": code])
            let (data, _) = try await CFQServer.fetchFromServer(method: "POST", path: "api/user/redeem", payload: payload)
            let resp = String(decoding: data, as: UTF8.self)
            return resp
        }
        
        static func fetchUserOption(authToken: String, param: String, type: String = "string") async -> String {
            do {
                let query = [URLQueryItem(name: "param", value: param), URLQueryItem(name: "type", value: type)]
                let (data, response) = try await CFQServer.fetchFromServer(method: "GET", path: "api/user/properties", query: query, token: authToken, shouldThrowByCode: false)
                if response.statusCode() == 200 {
                    return String(decoding: data, as: UTF8.self)
                } else {
                    return ""
                }
            } catch {
                print("Failed to fetch user option \(param) from server.")
                return ""
            }
        }
        
        static func uploadUserOption(authToken: String, param: String, value: String) async throws -> Bool {
            let payload = try JSONSerialization.data(withJSONObject: ["property": param, "value": value])
            let (_, response) = try await CFQServer.fetchFromServer(method: "POST", path: "api/user/properties", payload: payload, token: authToken, shouldThrowByCode: false)
            return response.statusCode() == 200
        }
        
        static func fetchCookieStatus(game: GameType, authToken: String) async throws -> Bool {
            let query = [URLQueryItem(name: "dest", value: game == .Chunithm ? "0" : "1")]
            let (_, response) = try await CFQServer.fetchFromServer(method: "GET", path: "api/user/has-cache", query: query, token: authToken, shouldThrowByCode: false)
            return response.statusCode() == 200
        }
        
        static func fetchIsUploading(game: GameType, authToken: String) async throws -> Bool {
            do {
                let (data, _) = try await CFQServer.fetchFromServer(method: "GET", path: "api/user/upload-status", token: authToken, shouldThrowByCode: false)
                let status = try decoder.decode(CFQUserUploadStatus.self, from: data)
                if game == .Chunithm {
                    return status.chunithm >= 0
                } else {
                    return status.maimai >= 0
                }
            } catch {
                return false
            }
        }
        
        static func fetchLeaderboardRank<T: Decodable>(authToken: String, type: T.Type) async -> T? {
            var leaderboard = ""
            var game = 0
            switch type {
            case is MaimaiRatingRank.Type:
                leaderboard = "rating"
                game = 0
            case is MaimaiTotalScoreRank.Type:
                leaderboard = "total-score"
                game = 0
            case is MaimaiTotalPlayedRank.Type:
                leaderboard = "total-played"
                game = 0
            case is MaimaiFirstRank.Type:
                leaderboard = "first"
                game = 0
            case is ChunithmRatingRank.Type:
                leaderboard = "rating"
                game = 1
            case is ChunithmTotalScoreRank.Type:
                leaderboard = "total-score"
                game = 1
            case is ChunithmTotalPlayedRank.Type:
                leaderboard = "total-played"
                game = 1
            case is ChunithmFirstRank.Type:
                leaderboard = "first"
                game = 1
            default:
                return nil
            }
            let gameTypeString = game == 1 ? "chunithm" : "maimai"
            do {
                let (data, _) = try await fetchFromServer(method: "GET", path: "api/user/leaderboard/\(gameTypeString)/\(leaderboard)", token: authToken, shouldThrowByCode: false)
                return try decoder.decode(T.self, from: data)
            } catch {
                print("Failed to fetch leaderboard rank for game \(gameTypeString) \(leaderboard).\n\(error)")
                return nil
            }
        }
        
        static func addFavMusic(authToken: String, game: Int, musicId: String) async -> String? {
            do {
                let payload = try JSONSerialization.data(withJSONObject: ["game": String(game), "musicId": musicId])
                let (data, _) = try await fetchFromServer(method: "POST", path: "api/user/favorite", payload: payload, token: authToken, shouldThrowByCode: false)
                return String(decoding: data, as: UTF8.self)
            } catch {
                print("Failed to add favorite music \(musicId) to game \(game).")
                return nil
            }
        }
        
        static func removeFavMusic(authToken: String, game: Int, musicId: String) async -> String? {
            do {
                let queries = [URLQueryItem(name: "game", value: String(game)), URLQueryItem(name: "musicId", value: musicId)]
                let (data, _) = try await fetchFromServer(method: "DELETE", path: "api/user/favorite", query: queries, token: authToken, shouldThrowByCode: false)
                return String(decoding: data, as: UTF8.self)
            } catch {
                print("Failed to remove favorite music \(musicId) to game \(game).")
                return nil
            }
        }
    }
    
    struct Image {
        static func getChunithmB30Image(authToken: String) async -> UIImage? {
            do {
                let (data, _) = try await CFQServer.fetchFromServer(method: "GET", path: "api/user/chunithm/image/b30", token: authToken, shouldThrowByCode: false)
                return UIImage(data: data)
            } catch {
                return nil
            }
        }
        
        static func getMaimaiB50Image(authToken: String) async -> UIImage? {
            do {
                let (imageData, _) = try await CFQServer.fetchFromServer(method: "GET", path: "api/user/maimai/image/b50", token: authToken, shouldThrowByCode: false)
                return UIImage(data: imageData)
            } catch {
                return nil
            }
        }
    }
    
    struct Stats {
        static func getAvgUploadTime(for mode: Int) async throws -> String {
            let queries = [URLQueryItem(name: "type", value: String(mode))]
            let (data, _) = try await CFQServer.fetchFromServer(method: "GET", path: "api/stats/upload-time", query: queries)
            return String(decoding: data, as: UTF8.self)
        }
        
        static func checkUploadStatus(authToken: String) async throws -> [Int] {
            let (data, _) = try await CFQServer.fetchFromServer(method: "GET", path: "api/user/upload-status", token: authToken)
            let decoded = try decoder.decode(CFQUserUploadStatus.self, from: data)
            return [decoded.chunithm, decoded.maimai]
        }
        
        static func checkSongListVersion(tag: String) async -> String {
            do {
                let query = [URLQueryItem(name: "tag", value: tag)]
                let (data, _) = try await CFQServer.fetchFromServer(method: "GET", path: "api/stats/version/resource", query: query, shouldThrowByCode: false)
                let result = String(decoding: data, as: UTF8.self)
                return result
            } catch {
                print("[CFQStatsServer] Failed to fetch song list version, defaulting to 0.")
                return ""
            }
        }
        
        static func fetchMusicStat(authToken: String, mode: Int, musicId: Int, diffIndex: Int, type: String = "SD") async -> CFQMusicStat {
            let queries = [URLQueryItem(name: "musicId", value: String(musicId)), URLQueryItem(name: "levelIndex", value: String(diffIndex)), URLQueryItem(name: "type", value: type)]
            let gameString = mode == 0 ? "chunithm" : "maimai"
            do {
                let (data, _) = try await fetchFromServer(method: "GET", path: "api/user/\(gameString)/stat", query: queries, token: authToken, shouldThrowByCode: false)
                return try decoder.decode(CFQMusicStat.self, from: data)
            } catch {
                print("[CFQServer] Failed to retrieve \(gameString) music stat for music \(musicId) diff \(diffIndex), type \(type).")
                return CFQMusicStat()
            }
        }
        
        static func fetchMaimaiLeaderboard(authToken: String, musicId: Int, type: String, diffIndex: Int) async -> CFQMaimaiLeaderboard {
            let queries = [
                URLQueryItem(name: "music_id", value: String(musicId)),
                URLQueryItem(name: "type", value: type == "DX" ? "dx" : "standard"),
                URLQueryItem(name: "level_index", value: String(diffIndex))
            ]
            do {
                let (data, _) = try await fetchFromServer(method: "GET", path: "api/user/maimai/leaderboard", query: queries, token: authToken, shouldThrowByCode: false)
                return try decoder.decode(CFQMaimaiLeaderboard.self, from: data)
            } catch {
                print("[CFQServer] Failed to retrieve maimai leaderboard for music \(musicId) diff \(diffIndex) type \(type).\n\(error)")
                return []
            }
        }
        
        static func fetchChunithmLeaderboard(authToken: String, musicId: Int, diffIndex: Int) async -> CFQChunithmLeaderboard {
            let queries = [URLQueryItem(name: "music_id", value: String(musicId)), URLQueryItem(name: "level_index", value: String(diffIndex))]
            do {
                let (data, _) = try await fetchFromServer(method: "GET", path: "api/user/chunithm/leaderboard", query: queries, token: authToken, shouldThrowByCode: false)
                return try decoder.decode(CFQChunithmLeaderboard.self, from: data)
            } catch {
                print("[CFQServer] Failed to retrieve chunithm leaderboard for music \(musicId) diff \(diffIndex).\n\(error)")
                return []
            }
        }
        
        static func fetchTotalLeaderboard<T: Decodable>(authToken: String, game: GameType, type: T.Type) async -> T? {
            let gameName = game == .Chunithm ? "chunithm" : "maimai"
            var typeString = ""
            switch type {
            case is ChunithmRatingLeaderboard.Type, is MaimaiRatingLeaderboard.Type:
                typeString = "rating"
            case is ChunithmTotalScoreLeaderboard.Type, is MaimaiTotalScoreLeaderboard.Type:
                typeString = "total-score"
            case is ChunithmTotalPlayedLeaderboard.Type, is MaimaiTotalPlayedLeaderboard.Type:
                typeString = "total-played"
            case is ChunithmFirstLeaderboard.Type, is MaimaiFirstLeaderboard.Type:
                typeString = "first"
            default:
                return nil
            }
            
            let path = "api/user/\(gameName)/leaderboard/\(typeString)"
            do {
                let (data, _) = try await fetchFromServer(method: "GET", path: path, token: authToken, shouldThrowByCode: false)
                return try decoder.decode(T.self, from: data)
            } catch {
                print("Error fetching total leaderboard of type \(typeString) from game \(gameName): \(error)")
                return nil
            }
        }
    }
    
    struct Comment {
        static func loadComments(authToken: String, mode: Int, musicId: Int) async throws -> [UserComment] {
            let gameTypeString = mode == 0 ? "chunithm" : "maimai"
            let queries = [URLQueryItem(name: "musicId", value: String(musicId))]
            let (data, _) = try await CFQServer.fetchFromServer(method: "GET", path: "api/comment/\(gameTypeString)", query: queries, token: authToken)
            return try CFQServer.decoder.decode(Array<UserComment>.self, from: data)
        }
        
        static func postComment(authToken: String, content: String, mode: Int, musicId: Int, reply: Int = -1) async throws -> Bool {
            let gameTypeString = mode == 0 ? "chunithm" : "maimai"
            let timestamp = Int(Date().timeIntervalSince1970)
            let payload = try JSONSerialization.data(withJSONObject: [
                "content": content,
                "musicId": musicId,
                "timestamp": timestamp
            ] as [String : Any])
            let (_, response) = try await CFQServer.fetchFromServer(method: "POST", path: "api/comment/\(gameTypeString)", payload: payload, token: authToken)
            return response.statusCode() == 200
        }
        
        static func deleteComment(authToken: String, mode: Int, commentId: Int) async throws -> Bool {
            let gameTypeString = mode == 0 ? "chunithm" : "maimai"
            let queries = [URLQueryItem(name: "comment_id", value: String(commentId))]
            let (_, response) = try await CFQServer.fetchFromServer(method: "DELETE", path: "api/comment/\(gameTypeString)", query: queries, token: authToken)
            return response.statusCode() == 200
        }
    }
    
    struct Maimai {
        var authToken: String
        
        init(authToken: String) {
            self.authToken = authToken
        }
        
        func fetchUserInfo() async throws -> UserMaimaiPlayerInfos {
            try await fetchGameData(UserMaimaiPlayerInfos.self, path: "api/user/maimai/info", authToken: authToken)
        }
        func fetchBestEntries() async throws -> UserMaimaiBestScores {
            try await fetchGameData(UserMaimaiBestScores.self, path: "api/user/maimai/best", authToken: authToken)
        }
        func fetchRecentEntries() async throws -> UserMaimaiRecentScores {
            try await fetchGameData(UserMaimaiRecentScores.self, path: "api/user/maimai/recent", authToken: authToken)
        }
        func fetchExtraEntry() async throws -> UserMaimaiExtra {
            try await fetchGameData(UserMaimaiExtra.self, path: "api/user/maimai/extra", authToken: authToken)
        }
        
        static func fetchMusicData() async throws -> Data {
            let (data, resp) = try await CFQServer.fetchFromServer(method: "GET", path: "api/resource/maimai/song-list")
            if resp.statusCode() == 200 && !data.isEmpty {
                return data
            } else {
                throw CFQServerError.ServerDatabaseError
            }
        }
        static func fetchVersionData() async throws -> Data {
            let (data, resp) = try await CFQServer.fetchFromServer(method: "GET", path: "api/resource/maimai/version-list")
            if resp.statusCode() == 200 && !data.isEmpty {
                return data
            } else {
                throw CFQServerError.ServerDatabaseError
            }
        }
        static func fetchGenreData() async throws -> Data {
            let (data, resp) = try await CFQServer.fetchFromServer(method: "GET", path: "api/resource/maimai/genre-list")
            if resp.statusCode() == 200 && !data.isEmpty {
                return data
            } else {
                throw CFQServerError.ServerDatabaseError
            }
        }
    }
    
    struct Chunithm {
        var authToken: String
        
        init(authToken: String) {
            self.authToken = authToken
        }
        
        func fetchUserInfo() async throws -> UserChunithmPlayerInfos {
            try await fetchGameData(UserChunithmPlayerInfos.self, path: "api/user/chunithm/info", authToken: authToken)
        }
        func fetchBestEntries() async throws -> UserChunithmBestScores {
            try await fetchGameData(UserChunithmBestScores.self, path: "api/user/chunithm/best", authToken: authToken)
        }
        func fetchRecentEntries() async throws -> UserChunithmRecentScores {
            try await fetchGameData(UserChunithmRecentScores.self, path: "api/user/chunithm/recent", authToken: authToken)
        }
        func fetchExtraEntries() async throws -> UserChunithmExtra {
            try await fetchGameData(UserChunithmExtra.self, path: "api/user/chunithm/extra", authToken: authToken)
        }
        func fetchRatingEntries() async throws -> UserChunithmRatingList {
            try await fetchGameData(UserChunithmRatingList.self, path: "api/user/chunithm/rating", authToken: authToken)
        }
        static func fetchMusicData() async throws -> Data {
            let (data, resp) = try await CFQServer.fetchFromServer(method: "GET", path: "api/resource/chunithm/song-list")
            if resp.statusCode() == 200 && !data.isEmpty {
                return data
            } else {
                throw CFQServerError.ServerDatabaseError
            }
        }
        static func coverUrl(musicId: Int) -> String {
            return "\(serverAddress)api/resource/chunithm/cover?musicId=\(musicId)"
        }
    }
    
    static func fetchFromServer(method: String, path: String, payload: Data = Data(), query: [URLQueryItem] = [], token: String = "", shouldThrowByCode: Bool = true) async throws -> (Data, URLResponse) {
        guard method == "GET" || method == "POST" || method == "DELETE" else { throw CFQServerError.InvalidParameterError }
        var url = URLComponents(string: CFQServer.serverAddress + path)!
        if !query.isEmpty {
            url.queryItems = query
        }
        var request = URLRequest(url: url.url!)
        request.httpMethod = method
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        if (!payload.isEmpty) {
            request.setValue("\(payload.count)", forHTTPHeaderField: "Content-Length")
            request.httpBody = payload
        }
        if (!token.isEmpty) {
            request.setValue("bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let (data, response) = try await session.data(for: request)
        print("Response from \(path)")
        print("Status Code: \(response.statusCode())")
        print("Response Body Length: \(data.count)")
        if shouldThrowByCode {
            let _ = try throwByCode(data: data, response: response)
        }
        return (data, response)
    }
    
    static func throwByCode(data: Data, response: URLResponse) throws -> String {
        guard response.statusCode() != 200 else { return "" }
        let serverCode = String(decoding: data, as: UTF8.self)
        for error in CFQServerError.allCases {
            if error.serverCode == serverCode {
                throw error
            }
        }
        return serverCode
    }
    
    static func fetchGameData<T: Decodable>(_ type: T.Type, path: String, authToken: String) async throws -> T {
        let (data, _) = try await fetchFromServer(method: "GET", path: path, token: authToken)
//        print(type.self)
//        print(String(data: data, encoding: .utf8) ?? "")
        return try decoder.decode(T.self, from: data)
    }
    
    static func triggerUpload(game: GameType, authToken: String, forwarding: Bool) async throws {
        let payload = try JSONSerialization.data(withJSONObject: ["dest": game == .Chunithm ? "0" : "1", "forwarding": forwarding ? "1" : "0"])
        let _ = try await fetchFromServer(method: "POST", path: "api/quick_upload", payload: payload, token: authToken)
    }
}

enum CFQServerError: Error, CaseIterable {
    case InvalidParameterError
    case InvalidTokenError
    case UsernameOccupiedError
    case UserNotFoundError
    case UserNotPremiumError
    case EntryNotFoundError
    case ServerDatabaseError
    case CredentialsMismatchError
}

extension CFQServerError: CustomStringConvertible {
    var description: String {
        switch self {
        case .InvalidParameterError:
            return "客户端参数错误"
        case .InvalidTokenError:
            return "Token错误或已失效"
        case .UserNotFoundError:
            return "用户不存在"
        case .EntryNotFoundError:
            return "记录不存在"
        case .ServerDatabaseError:
            return "服务器数据库出错"
        case .UserNotPremiumError:
            return "非赞助用户"
        case .UsernameOccupiedError:
            return "用户名已存在"
        case .CredentialsMismatchError:
            return "用户名或密码错误"
        }
    }
}
extension CFQServerError {
    var serverCode: String {
        switch self {
        case .InvalidParameterError:
            return ""
        case .InvalidTokenError:
            return "INVALID"
        case .UserNotFoundError:
            return "NOT FOUND"
        case .EntryNotFoundError:
            return "EMPTY"
        case .ServerDatabaseError:
            return "DATABASE ERROR"
        case .UserNotPremiumError:
            return "NOT PREMIUM"
        case .UsernameOccupiedError:
            return "NOT UNIQUE"
        case .CredentialsMismatchError:
            return "MISMATCH"
        }
    }
}
extension CFQServerError {
    func alertToast() -> AlertToast {
        return AlertToast(displayMode: .hud, type: .error(.red), title: "发生错误", subTitle: self.description)
    }
}

extension String {
    var sha256String: String {
        SHA256.hash(data: Data(self.utf8))
            .compactMap { String(format: "%02x", $0) }.joined()
    }
}

typealias CFQUserServer = CFQServer.User
typealias CFQMaimaiServer = CFQServer.Maimai
typealias CFQChunithmServer = CFQServer.Chunithm
typealias CFQStatsServer = CFQServer.Stats
typealias CFQCommentServer = CFQServer.Comment
typealias CFQImageServer = CFQServer.Image
