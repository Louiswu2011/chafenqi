//
//  CFQNUser.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/5/4.
//

import Foundation
import SwiftUI

class CFQNUser: ObservableObject {
    @Published var didLogin = false
    
    @AppStorage("JWT") var jwtToken = ""
    @AppStorage("Fish") var fishToken = ""
    @AppStorage("MaimaiCache") var maimaiCache = Data()
    @AppStorage("ChunithmCache") var chunithmCache = Data()
    
    var maimai = Maimai()
    var chunithm = Chunithm()
    var data = CFQPersistentData()
    
    var username = ""
    var fishUsername = ""
    
    var isPremium = false
    
    struct Maimai: Codable {
        var info: CFQMaimaiUserInfo = .empty
        var best: CFQMaimaiBestScoreEntries = []
        var recent: CFQMaimaiRecentScoreEntries = []
        var delta: CFQMaimaiDeltaEntries = []
        var isNotEmpty: Bool = false
        
        init(token: String) async throws {
            let server = CFQMaimaiServer(authToken: token)
            do {
                async let info = try server.fetchUserInfo()
                async let best = try server.fetchBestEntries()
                async let recent = try server.fetchRecentEntries()
                
                self.info = try await info
                self.best = try await best
                self.recent = try await recent
                isNotEmpty = true
            } catch {
                print("No maimai data from server")
                print(String(describing: error))
            }
            do {
                self.delta = try await server.fetchDeltaEntries()
            } catch CFQServerError.UserNotPremiumError {
                self.delta = []
                print("User is not premium, skipping")
            }
        }
        
        init() {}
    }
    
    struct Chunithm: Codable {
        var info: CFQChunithmUserInfo = .empty
        var best: CFQChunithmBestScoreEntries = []
        var recent: CFQChunithmRecentScoreEntries = []
        var rating: CFQChunithmRatingEntries = []
        var delta: CFQChunithmDeltaEntries = []
        var extra: CFQChunithmExtraEntry = .empty
        var isNotEmpty: Bool = false
        
        init(token: String) async throws {
            let server = CFQChunithmServer(authToken: token)
            do {
                async let info = try server.fetchUserInfo()
                async let best = try server.fetchBestEntries()
                async let recent = try server.fetchRecentEntries()
                async let rating = try server.fetchRatingEntries()
                
                self.info = try await info
                self.best = try await best
                self.recent = try await recent
                self.rating = try await rating
                isNotEmpty = true
            } catch {
                print("No chunithm game data from server")
                print(String(describing: error))
            }
            do {
                async let delta = try server.fetchDeltaEntries()
                async let extra = try server.fetchExtraEntries()
                
                self.delta = try await delta
                self.extra = try await extra
            } catch CFQServerError.UserNotPremiumError {
                print("User is not premium, skipping")
            }
        }
        
        init() {}
    }
    
    init() {}
    
    func fetchUserData(token: String) async throws {
        self.maimai = try await Maimai(token: token)
        self.chunithm = try await Chunithm(token: token)
        print("[CFQNUser] Fetched User Data.")
        
        await withTaskGroup(of: Void.self) { group in
            group.addTask {
                if (self.maimai.isNotEmpty && !self.data.maimai.songlist.isEmpty) {
                    self.maimai.best = CFQMaimai.assignAssociated(songs: self.data.maimai.songlist, bests: self.maimai.best)
                    self.maimai.recent = CFQMaimai.assignAssociated(songs: self.data.maimai.songlist, recents: self.maimai.recent)
                }
            }
            group.addTask {
                if (self.chunithm.isNotEmpty && !self.data.chunithm.songs.isEmpty) {
                    self.chunithm.best = CFQChunithm.assignAssociated(songs: self.data.chunithm.songs, bests: self.chunithm.best)
                    self.chunithm.recent = CFQChunithm.assignAssociated(songs: self.data.chunithm.songs, recents: self.chunithm.recent)
                    self.chunithm.rating = CFQChunithm.assignAssociated(songs: self.data.chunithm.songs, ratings: self.chunithm.rating)
                }
            }
        }
        print("[CFQNUser] Assigned Associated Song Data.")
    }
    
    func checkAssociated() -> [String] {
        var failed: [String] = []
        
        for entry in self.maimai.best {
            if (entry.associatedSong == nil) {
                failed.append("maimai best: " + entry.title)
            }
        }
        for entry in self.maimai.recent {
            if (entry.associatedSong == nil) {
                failed.append("maimai recent: " + entry.title)
            }
        }
        for entry in self.chunithm.best {
            if (entry.associatedSong == nil) {
                failed.append("chunithm best: " + entry.title)
            }
        }
        for entry in self.chunithm.recent {
            if (entry.associatedSong == nil) {
                failed.append("chunithm recent: " + entry.title)
            }
        }
        for entry in self.chunithm.rating {
            if (entry.associatedSong == nil) {
                failed.append("chunithm rating: " + entry.title)
            }
        }
        
        return failed
    }
    
    func load(username: String, forceReload: Bool = false) async throws {
        self.data = try await forceReload ? .forceRefresh() : .loadFromCacheOrRefresh()

        try await fetchUserData(token: self.jwtToken)
//        if (!jwtToken.isEmpty || forceReload = true) {
//            try await fetchUserData(token: self.jwtToken)
//        } else {
//            self.maimai = try JSONDecoder().decode(Maimai.self, from: maimaiCache)
//            self.chunithm = try JSONDecoder().decode(Chunithm.self, from: chunithmCache)
//        }

        self.username = username
        print(checkAssociated())
    }
}

enum CFQNUserError: Error {
    case SavingError(cause: String, from: String)
    case LoadingError(cause: String, from: String)
}
