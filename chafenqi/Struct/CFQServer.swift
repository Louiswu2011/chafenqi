//
//  CFQServer.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/5/4.
//

import Foundation
import Crypto
import AlertToast

struct CFQServer {
    static let session = URLSession(configuration: .default)
    static let encoder = JSONEncoder()
    static let decoder = JSONDecoder()
    
    struct User {
        static func auth(username: String, password: String) async throws -> String {
            let payload = try JSONSerialization.data(withJSONObject: ["username": username, "password": password.sha256String])
            let (data, _) = try await CFQServer.fetchFromServer(method: "POST", path: "api/auth", payload: payload)
            let token = String(decoding: data, as: UTF8.self)
            return token
        }
        
        static func register(username: String, password: String) async throws {
            let payload = try JSONSerialization.data(withJSONObject: ["username": username])
            let (_, _) = try await CFQServer.fetchFromServer(method: "POST", path: "api/checkUsername", payload: payload)
            let registerPayload = try JSONSerialization.data(withJSONObject: ["username": username, "password": password.sha256String])
            let (_, _) = try await CFQServer.fetchFromServer(method: "POST", path: "api/register", payload: registerPayload)
        }
        
        static func checkPremium(username: String) async throws -> Bool {
            do {
                let payload = try JSONSerialization.data(withJSONObject: ["username": username])
                let (data, response) = try await CFQServer.fetchFromServer(method: "POST", path: "api/isPremium", payload: payload)
                let responseCode = response.statusCode()
                print("[CFQServer] Premium checking return \(String(decoding: data, as: UTF8.self)), response code: \(responseCode)")
                return responseCode == 200
            } catch CFQServerError.UserNotPremiumError {
                return false
            }
        }
        
        static func checkPremiumExpireTime(username: String) async throws -> Double {
            let payload = try JSONSerialization.data(withJSONObject: ["username": username])
            let (data, response) = try await CFQServer.fetchFromServer(method: "POST", path: "api/premiumTime", payload: payload)
            if response.statusCode() == 200 {
                return Double(String(decoding: data, as: UTF8.self)) ?? 0
            } else {
                return 0
            }
        }
    }
    
    struct Fish {
        static func uploadToken(authToken: String, fishToken: String) async throws {
            let payload = try JSONSerialization.data(withJSONObject: ["token": fishToken])
            let (_, _) = try await CFQServer.fetchFromServer(method: "POST", path: "fish/upload_token", payload: payload, token: authToken)
        }
        
        static func fetchToken(authToken: String) async throws -> String {
            let (data, _) = try await CFQServer.fetchFromServer(method: "GET", path: "fish/fetch_token", token: authToken)
            let token = String(decoding: data, as: UTF8.self)
            return token
        }
    }
    
    struct Maimai {
        var authToken: String
        
        init(authToken: String) {
            self.authToken = authToken
        }
        
        func fetchUserInfo() async throws -> CFQMaimaiUserInfo {
            try await fetchGameData(CFQMaimaiUserInfo.self, path: "api/maimai/info", authToken: authToken)
        }
        func fetchBestEntries() async throws -> CFQMaimaiBestScoreEntries {
            try await fetchGameData(CFQMaimaiBestScoreEntries.self, path: "api/maimai/best", authToken: authToken)
        }
        func fetchRecentEntries() async throws -> CFQMaimaiRecentScoreEntries {
            try await fetchGameData(CFQMaimaiRecentScoreEntries.self, path: "api/maimai/recent", authToken: authToken)
        }
        func fetchDeltaEntries() async throws -> CFQMaimaiDeltaEntries {
            try await fetchGameData(CFQMaimaiDeltaEntries.self, path: "api/maimai/delta", authToken: authToken)
        }
        func fetchExtraEntry() async throws -> CFQMaimaiExtraEntry {
            try await fetchGameData(CFQMaimaiExtraEntry.self, path: "api/maimai/extra", authToken: authToken)
        }
    }
    
    struct Chunithm {
        var authToken: String
        
        init(authToken: String) {
            self.authToken = authToken
        }
        
        func fetchUserInfo() async throws -> CFQChunithmUserInfo {
            try await fetchGameData(CFQChunithmUserInfo.self, path: "api/chunithm/info", authToken: authToken)
        }
        func fetchBestEntries() async throws -> CFQChunithmBestScoreEntries {
            try await fetchGameData(CFQChunithmBestScoreEntries.self, path: "api/chunithm/best", authToken: authToken)
        }
        func fetchRecentEntries() async throws -> CFQChunithmRecentScoreEntries {
            try await fetchGameData(CFQChunithmRecentScoreEntries.self, path: "api/chunithm/recent", authToken: authToken)
        }
        func fetchDeltaEntries() async throws -> CFQChunithmDeltaEntries {
            try await fetchGameData(CFQChunithmDeltaEntries.self, path: "api/chunithm/delta", authToken: authToken)
        }
        func fetchExtraEntries() async throws -> CFQChunithmExtraEntry {
            try await fetchGameData(CFQChunithmExtraEntry.self, path: "api/chunithm/extras", authToken: authToken)
        }
        func fetchRatingEntries() async throws -> CFQChunithmRatingEntries {
            try await fetchGameData(CFQChunithmRatingEntries.self, path: "api/chunithm/rating", authToken: authToken)
        }
        static func fetchMusicData() async throws -> Data {
            let (data, resp) = try await CFQServer.fetchFromServer(method: "GET", path: "api/chunithm/music_data")
            if resp.statusCode() == 200 && !data.isEmpty {
                return data
            } else {
                throw CFQServerError.ServerDatabaseError
            }
        }
    }
    
    static func fetchFromServer(method: String, path: String, payload: Data = Data(), query: [URLQueryItem] = [], token: String = "") async throws -> (Data, URLResponse) {
        guard method == "GET" || method == "POST" else { throw CFQServerError.InvalidParameterError }
        var url = URLComponents(string: "http://43.139.107.206:8083/" + path)!
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
        let _ = try throwByCode(data: data, response: response)
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
typealias CFQFishServer = CFQServer.Fish
typealias CFQMaimaiServer = CFQServer.Maimai
typealias CFQChunithmServer = CFQServer.Chunithm
