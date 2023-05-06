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
    
    var currentMode = 0
    
    struct Maimai: Codable {
        struct Custom: Codable {
            var pastSlice: CFQMaimaiBestScoreEntries = []
            var currentSlice: CFQMaimaiBestScoreEntries = []
            var pastRating = 0
            var currentRating = 0
            var rawRating = 0
            
            init() {}
            
            init(orig: CFQMaimaiBestScoreEntries) {
                self.pastSlice = orig.filter { entry in
                    return !entry.associatedSong!.basicInfo.isNew
                }
                self.currentSlice = orig.filter { entry in
                    return entry.associatedSong!.basicInfo.isNew
                }
                self.pastRating = self.pastSlice.reduce(0) { orig, next in
                    orig + next.rating
                }
                self.currentRating = self.currentSlice.reduce(0) { orig, next in
                    orig + next.rating
                }
                self.rawRating = self.pastRating + self.currentRating
            }
        }
        
        var info: CFQMaimaiUserInfo = .empty
        var best: CFQMaimaiBestScoreEntries = []
        var recent: CFQMaimaiRecentScoreEntries = []
        var delta: CFQMaimaiDeltaEntries = []
        var custom: Custom = Custom()
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
        struct Custom: Codable {
            var b30Slice: CFQChunithmRatingEntries = []
            var r10Slice: CFQChunithmRatingEntries = []
            var candidateSlice: CFQChunithmRatingEntries = []
            var b30: Double = 0.0
            var r10: Double = 0.0
            var maxRating: Double = 0.0
            
            init() {}
            init(orig: CFQChunithmRatingEntries) {
                self.b30Slice = orig.filter {
                    $0.type == "best"
                }
                self.r10Slice = orig.filter {
                    $0.type == "recent"
                }
                self.candidateSlice = orig.filter {
                    $0.type == "candidate"
                }
                self.b30 = (self.b30Slice.reduce(0.0) { orig, next in
                    orig + next.rating
                } / 30.0).cut(remainingDigits: 2)
                self.r10 = (self.r10Slice.reduce(0.0) { orig, next in
                    orig + next.rating
                } / 10.0).cut(remainingDigits: 2)
                
                let r1 = self.r10Slice.sorted {
                    $0.rating > $1.rating
                }.first!
                self.maxRating = ((self.b30 * 30.0 + r1.rating * 10.0) / 40.0).cut(remainingDigits: 2)
            }
        }
        
        var info: CFQChunithmUserInfo = .empty
        var best: CFQChunithmBestScoreEntries = []
        var recent: CFQChunithmRecentScoreEntries = []
        var rating: CFQChunithmRatingEntries = []
        var delta: CFQChunithmDeltaEntries = []
        var extra: CFQChunithmExtraEntry = .empty
        var isNotEmpty: Bool = false
        var custom: Custom = Custom()
        
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
        
        self.maimai.custom = Maimai.Custom(orig: self.maimai.best)
        self.chunithm.custom = Chunithm.Custom(orig: self.chunithm.rating)
        print("[CFQNUser] Calculated Custom Values.")
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
        if (!checkAssociated().isEmpty) {
            throw CFQNUserError.AssociationError
        }
    }
    
    func logout() {
        self.maimaiCache = Data()
        self.chunithmCache = Data()
        self.jwtToken = ""
        self.fishToken = ""
        self.username = ""
        self.fishUsername = ""
        self.isPremium = false
    }
}

enum CFQNUserError: Error {
    case SavingError(cause: String, from: String)
    case LoadingError(cause: String, from: String)
    case AssociationError
}

extension CFQNUserError: CustomStringConvertible {
    var description: String {
        switch self {
        case .SavingError(cause: let cause, from: let from):
            return from + cause
        case .LoadingError(cause: let cause, from: let from):
            return from + cause
        case .AssociationError:
            return "关联歌曲出现错误"
        }
    }
}


