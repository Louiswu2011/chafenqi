//
//  ProberDataGrabber.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/8.
//

import Foundation
import Moya

struct ProbeDataGrabber {
    static func getSongDataSetFromServer() async throws -> Set<SongData> {
        let provider = MoyaProvider<ProberService>()
        var data = Set<SongData>()
        provider.request(.getSongInfo) { result in
            switch result {
            case let .success(response):
                let decoder = JSONDecoder()
                data = try! decoder.decode(Set<SongData>.self, from: response.data)
                
            case .failure(_):
                data = Set<SongData>()
            }
        }
        
        if (data.isEmpty) {
            throw CFQError.emptyResponseError
        }
        
        return data
    }
    
    static func getUserInfo(id: String) async throws -> UserScoreData {
        return try await getUserInfoBy(type: "qq", payload: id)
    }
    
    static func getUserInfo(username: String) async throws -> UserScoreData {
        return try await getUserInfoBy(type: "username", payload: username)
    }
    
    static private func getUserInfoBy(type: String, payload: String) async throws -> UserScoreData {
        let body = [type: payload]
        let bodyData = try! JSONSerialization.data(withJSONObject: body)

        var request = URLRequest(url: URL(string: "https://www.diving-fish.com/api/chunithmprober/query/player")!)

        request.httpMethod = "POST"
        request.httpBody = bodyData
        request.setValue("\(bodyData.count)", forHTTPHeaderField: "Content-Length")
        request.setValue(
            "application/json",
            forHTTPHeaderField: "Content-Type"
        )
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, _) = try await URLSession.shared.data(for: request)
        let decoder = JSONDecoder()
        
        do {
            return try decoder.decode(UserScoreData.self, from: data)
        } catch {
            throw CFQError.invalidResponseError(response: String(decoding: data, as: UTF8.self))
        }
        
    }
}
