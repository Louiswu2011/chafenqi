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
    @AppStorage("settingsRecentLogEntryCount") var entryCount = "30"
    @AppStorage("settingsChunithmCoverSource") var chunithmCoverSource = 1
    @AppStorage("settingsChunithmChartSource") var chunithmChartSource = 1
    @AppStorage("settingsMaimaiCoverSource") var maimaiCoverSource = 0
    @AppStorage("settingsShouldForwardToFish") var shouldForwardToFish = true
    
    var maimai = Maimai()
    var chunithm = Chunithm()
    var data = CFQPersistentData()
    
    @AppStorage("CFQUsername") var username = ""
    var fishUsername = ""
    
    var isPremium = false
    
    @Published var currentMode = 0
    
    struct Maimai: Codable {
        struct Custom: Codable {
            var pastSlice: CFQMaimaiBestScoreEntries = []
            var currentSlice: CFQMaimaiBestScoreEntries = []
            var pastRating = 0
            var currentRating = 0
            var rawRating = 0
            
            var recommended: [CFQMaimai.RecentScoreEntry: String] = [:]
            
            init() {}
            
            init(orig: CFQMaimaiBestScoreEntries, recent: CFQMaimaiRecentScoreEntries) {
                self.pastSlice = Array(orig.filter { entry in
                    return !entry.associatedSong!.basicInfo.isNew
                }.sorted { $0.rating > $1.rating }.prefix(upTo: 25))
                self.currentSlice = Array(orig.filter { entry in
                    return entry.associatedSong!.basicInfo.isNew
                }.sorted { $0.rating > $1.rating }.prefix(upTo: 15))
                self.pastRating = self.pastSlice.reduce(0) { orig, next in
                    orig + next.rating
                }
                self.currentRating = self.currentSlice.reduce(0) { orig, next in
                    orig + next.rating
                }
                self.rawRating = self.pastRating + self.currentRating
                
                var r = recent
                if let max = (r.filter {
                    $0.fc == "applus"
                }.first) {
                    recommended[max] = "MAX"
                    r.removeAll { $0.timestamp == max.timestamp }
                }
                
                if let ap = (r.filter {
                    $0.fc == "ap"
                }.first) {
                    recommended[ap] = "AP"
                    r.removeAll { $0.timestamp == ap.timestamp }
                }
                if let fc = (r.filter {
                    $0.fc.hasPrefix("fc") || $0.fs.hasPrefix("fs")
                }.first) {
                    recommended[fc] = "FC"
                    r.removeAll { $0.timestamp == fc.timestamp }
                }
                let hs = r.sorted {
                    $0.score > $1.score
                }.first!
                recommended[hs] = "HS"
                let ro = r.sorted {
                    $0.timestamp > $1.timestamp
                }.first!
                recommended[ro] = "RO"
                if let nr = (r.filter {
                    $0.isNewRecord == 1
                }.sorted { $0.timestamp > $1.timestamp }.first) { recommended[nr] = "NR" }
                
                print("[CFQNUser] Loaded maimai Custom Data.")
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
                print("[CFQNUser] No maimai data from server.")
                print(String(describing: error))
            }
            do {
                self.delta = try await server.fetchDeltaEntries()
            } catch CFQServerError.UserNotPremiumError {
                self.delta = []
                print("[CFQNUser] User is not premium, skipping maimai deltas.")
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
            
            var recommended: [CFQChunithm.RecentScoreEntry: String] = [:]
            
            init() {}
            init(orig: CFQChunithmRatingEntries, recent: CFQChunithmRecentScoreEntries) {
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
                
                var r = recent
                if let max = (r.filter {
                    $0.score == 1010000
                }.first) {
                    recommended[max] = "MAX"
                    r.removeAll { $0.timestamp == max.timestamp }
                }
                
                if let ap = (r.filter {
                    $0.fcombo == "alljustice"
                }.first) {
                    recommended[ap] = "AP"
                    r.removeAll { $0.timestamp == ap.timestamp }
                }
                if let fc = (r.filter {
                    $0.fcombo.contains("fullcombo") || $0.fchain.contains("fullchain")
                }.first) {
                    recommended[fc] = "FC"
                    r.removeAll { $0.timestamp == fc.timestamp }
                }
                let hs = r.sorted {
                    $0.score > $1.score
                }.first!
                recommended[hs] = "HS"
                let ro = r.sorted {
                    $0.timestamp > $1.timestamp
                }.first!
                recommended[ro] = "RO"
                if let nr = (r.filter {
                    $0.isNewRecord == 1
                }.sorted { $0.timestamp > $1.timestamp }.first) { recommended[nr] = "NR" }
                print("[CFQNUser] Loaded chunithm Custom Data.")
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
                print("[CFQNUser] No chunithm game data from server.")
                print(String(describing: error))
            }
            do {
                async let delta = try server.fetchDeltaEntries()
                async let extra = try server.fetchExtraEntries()
                
                self.delta = try await delta
                self.extra = try await extra
            } catch CFQServerError.UserNotPremiumError {
                print("[CFQNUser] User is not premium, skipping chunithm extras.")
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
        
        self.maimai.custom = Maimai.Custom(orig: self.maimai.best, recent: self.maimai.recent)
        self.chunithm.custom = Chunithm.Custom(orig: self.chunithm.rating, recent: self.chunithm.recent)
        print("[CFQNUser] Calculated Custom Values.")
        
        self.maimaiCache = try JSONEncoder().encode(self.maimai)
        self.chunithmCache = try JSONEncoder().encode(self.chunithm)
        print("[CFQNUser] Saved Data to Cache.")
        
        do {
            self.fishToken = try await CFQFishServer.fetchToken(authToken: token)
            print("[CFQNUser] Fetched Fish Token.")
        } catch CFQServerError.EntryNotFoundError {
            self.fishToken = ""
            print("[CFQNUser] No Fish Token Found.")
        }
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
        withAnimation {
            self.didLogin.toggle()
        }
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

let recommendWeights = [
    "MAX": 20, // AP+ / AJC
    "AP": 10,
    "FC": 9, // FC/FS/FC+/FS+/FDX
    "HS": 7, // Highscore
    "NR": 8, // New Record
    "RO": 5  // Recent
]

let recommendPrompts = [
    "MAX": "理论值",
    "AP": "AP",
    "FC": "FC",
    "HS": "高分",
    "NR": "新纪录",
    "RO": "最近一首"
]