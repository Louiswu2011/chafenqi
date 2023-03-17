//
//  CFQUserData.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/3/18.
//

import Foundation

class CFQUser: ObservableObject {
    @Published var token = ""
    
    @Published var username = ""
    @Published var nickname = ""
    
    @Published var maimai: Maimai?
    @Published var chunithm: Chunithm?
    
    struct Maimai: Codable {
        var profile: MaimaiPlayerProfile
        var record: MaimaiPlayerRecord
        var recent: Array<MaimaiRecentRecord>
    }
    
    struct Chunithm: Codable {
        var profile: ChunithmUserData
        var rating: ChunithmUserScoreData
        var recent: Array<ChunithmRecentRecord>
    }
    
    static func loadFromToken(token: String) async throws -> CFQUser {
        var user = CFQUser()
        user.token = token
        
        do {
            let maimaiProfile = try await JSONDecoder().decode(MaimaiPlayerProfile.self, from: MaimaiDataGrabber.getPlayerProfile(token: token))
            let maimaiRecord = try await JSONDecoder().decode(MaimaiPlayerRecord.self, from: MaimaiDataGrabber.getPlayerRecord(token: token))
            let maimaiRecent = try await JSONDecoder().decode(Array<MaimaiRecentRecord>.self, from: MaimaiDataGrabber.getRecentData(username: maimaiProfile.username))
            
            user.maimai = Maimai(profile: maimaiProfile, record: maimaiRecord, recent: maimaiRecent)
        } catch {
            user.maimai = nil
        }
        
        do {
            let chunithmProfile = try await JSONDecoder().decode(ChunithmUserData.self, from: ChunithmDataGrabber.getUserRecord(token: token))
            let chunithmRecent = try await JSONDecoder().decode(Array<ChunithmRecentRecord>.self, from: ChunithmDataGrabber.getRecentData(username: chunithmProfile.username))
            let chunithmUserScore = try await JSONDecoder().decode(ChunithmUserScoreData.self, from: ChunithmDataGrabber.getUserScoreData(username: chunithmProfile.username))

            user.chunithm = Chunithm(profile: chunithmProfile, rating: chunithmUserScore, recent: chunithmRecent)
        } catch {
            user.chunithm = nil
        }
        
        user.username = user.maimai?.profile.username ?? user.chunithm?.profile.username ?? ""
        user.nickname = user.maimai?.profile.nickname ?? user.chunithm?.profile.username ?? ""
        
        return user
    }
}
