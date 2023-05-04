//
//  CFQNUser.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/5/4.
//

import Foundation
import SwiftUI

class CFQNUser: ObservableObject {
    @Published var token: String {
        willSet {
            Task {
                if (!token.isEmpty) {
                    try await fetchUserData(token: token)
                }
            }
            objectWillChange.send()
        }
    }
    
    var maimai: Maimai
    var chunithm: Chunithm
    var data: CFQPersistentData
    
    struct Maimai: Codable {
        var info: CFQMaimaiUserInfo = .empty
        var best: CFQMaimaiBestScoreEntries = []
        var recent: CFQMaimaiRecentScoreEntries = []
        var delta: CFQMaimaiDeltaEntries = []
        var isNotEmpty: Bool = false
        
        init(token: String) async throws {
            let server = CFQMaimaiServer(authToken: token)
            do {
                self.info = try await server.fetchUserInfo()
                self.best = try await server.fetchBestEntries()
                self.recent = try await server.fetchRecentEntries()
                isNotEmpty = true
            } catch {
                
            }
            do {
                self.delta = try await server.fetchDeltaEntries()
            } catch CFQServerError.UserNotPremiumError {
                self.delta = []
            }
        }
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
                self.info = try await server.fetchUserInfo()
                self.best = try await server.fetchBestEntries()
                self.recent = try await server.fetchRecentEntries()
                self.rating = try await server.fetchRatingEntries()
                isNotEmpty = true
            } catch CFQServerError.EntryNotFoundError {
                
            }
            do {
                self.delta = try await server.fetchDeltaEntries()
                self.extra = try await server.fetchExtraEntries()
            } catch CFQServerError.UserNotPremiumError {
                
            }
        }
    }
    
    init(token: String) async throws {
        self.token = token
        self.data = try await CFQPersistentData.loadFromCacheOrRefresh()
        try await fetchUserData(token: token)
    }
    
    func fetchUserData(token: String) async throws {
        self.maimai = try await Maimai(token: token)
        self.chunithm = try await Chunithm(token: token)
        if (self.maimai.isNotEmpty && !self.data.maimai.songlist.isEmpty) {
            self.maimai.best = CFQMaimai.assignAssociated(songs: self.data.maimai.songlist, bests: self.maimai.best)
            self.maimai.recent = CFQMaimai.assignAssociated(songs: self.data.maimai.songlist, recents: self.maimai.recent)
        }
        if (self.chunithm.isNotEmpty && !self.data.chunithm.songs.isEmpty) {
            self.chunithm.best = CFQChunithm.assignAssociated(songs: self.data.chunithm.songs, bests: self.chunithm.best)
            self.chunithm.recent = CFQChunithm.assignAssociated(songs: self.data.chunithm.songs, recents: self.chunithm.recent)
            self.chunithm.rating = CFQChunithm.assignAssociated(songs: self.data.chunithm.songs, ratings: self.chunithm.rating)
        }
    }
}
