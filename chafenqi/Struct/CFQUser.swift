//
//  CFQUserData.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/3/18.
//

import Foundation
import SwiftUI

class CFQUser: ObservableObject {
    @Published var didLogin = false
    
    @Published var token = ""
    
    @AppStorage("settingsCurrentMode") var currentMode = 0
    @AppStorage("settingsRecentLogEntryCount") var entryCount = "30"
    @AppStorage("settingsChunithmCoverSource") var chunithmCoverSource = 1
    @AppStorage("settingsMaimaiCoverSource") var maimaiCoverSource = 0
    
    @AppStorage("userToken") var cachedToken = ""
    @AppStorage("userMaimaiCache") var maimaiCache = Data()
    @AppStorage("userChunithmCache") var chunithmCache = Data()
    
    @AppStorage("firstTimeLaunch") var firstTime = true
    
    @AppStorage("proxyDidInstallProfile") var installed = false
    
    var username = ""
    var nickname = ""
    var displayName = ""
    
    var maimai: Maimai? = Maimai()
    var chunithm: Chunithm? = Chunithm()
    
    var data = CFQPersistentData()
    
    var shouldReload = true
    
    let dateFormat = "MM-dd HH:mm"
    
    struct Maimai: Codable {
        var profile: MaimaiPlayerProfile = MaimaiPlayerProfile.shared
        var record: MaimaiPlayerRecord = MaimaiPlayerRecord.shared
        var recent: Array<MaimaiRecentRecord> = []
        
        var custom: Custom = Custom()
        
        struct Custom: Codable {
            var pastRating = 0
            var currentRating = 0
            var pastSlice: Array<MaimaiRecordEntry> = []
            var currentSlice: Array<MaimaiRecordEntry> = []
            var rawRating = 0
            var totalCharts = 0
            var totalPlayed = 0
            var avgAchievement = 0.0
            var nationalRanking = 0
            var recentSong: Array<MaimaiSongData?> = []
            
            var lastUpdateDate = ""
        }
    }
    
    struct Chunithm: Codable {
        var profile: ChunithmUserData = ChunithmUserData.shared
        var rating: ChunithmUserScoreData = ChunithmUserScoreData.shared
        var recent: Array<ChunithmRecentRecord> = []
        var custom: Custom = Custom()
        
        struct Custom: Codable {
            var overpower = 0.0
            var maxRating = 0.0
            var recentSong: Array<ChunithmSongData?> = []
            
            var lastUpdateDate = ""
        }
    }
    
    private func calculateMaimaiData() {
        let songlist = self.data.maimai.songlist
        let records = self.maimai!.record.records
        let ranking = self.data.maimai.ranking
        
        let pastSlice = self.maimai!.record.getPastSlice(songData: songlist)
        let currentSlice = self.maimai!.record.getCurrentSlice(songData: songlist)
        
        self.maimai!.custom.pastRating = pastSlice.reduce(0) { $0 + $1.rating }
        self.maimai!.custom.currentRating = currentSlice.reduce(0) { $0 + $1.rating }
        self.maimai!.custom.rawRating = self.maimai!.custom.pastRating + self.maimai!.custom.currentRating
        
        self.maimai!.custom.pastSlice = Array(self.maimai!.record.getPastSlice(songData: self.data.maimai.songlist))
        self.maimai!.custom.currentSlice = Array(self.maimai!.record.getCurrentSlice(songData: self.data.maimai.songlist))
        
        self.maimai!.custom.totalCharts = songlist.reduce(0) {
            $0 + $1.charts.count
        }
        self.maimai!.custom.totalPlayed = records.count
        
        self.maimai!.custom.avgAchievement = records.reduce(0.0) {
            $0 + $1.achievements / Double(records.count)
        }
        
        let sortedRanking = ranking.sorted {
            $0.rating > $1.rating
        }
        self.maimai!.custom.nationalRanking = (sortedRanking.firstIndex(where: {
            $0.username == self.maimai!.profile.username
        }) ?? -1) + 1
        
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        
        let lastDate = Date(timeIntervalSince1970: TimeInterval(self.maimai!.recent.sorted {
            $0.timestamp > $1.timestamp
        }[0].timestamp))
        self.maimai!.custom.lastUpdateDate = formatter.string(from: lastDate)
        
        for entry in self.maimai!.recent {
            let song = self.data.maimai.songlist.filter {
                $0.title == entry.title
            }.first
            
            self.maimai!.custom.recentSong.append(song)
        }
    }
    
    private func calculateChunithmData() {
        self.chunithm!.custom.overpower = self.chunithm!.profile.getOverpower()
        self.chunithm!.custom.maxRating = self.chunithm!.profile.getMaximumRating()
        
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        
        let lastDate = Date(timeIntervalSince1970: TimeInterval(self.chunithm!.recent.sorted {
            $0.timestamp > $1.timestamp
        }[0].timestamp))
        self.chunithm!.custom.lastUpdateDate = formatter.string(from: lastDate)
        
        for entry in self.chunithm!.recent {
            let song = self.data.chunithm.songs.filter {
                String($0.musicId) == entry.music_id
            }.first
            
            self.chunithm!.custom.recentSong.append(song)
        }
    }
    
    func refresh() async throws {
        shouldReload = true
        try await self.loadFromToken(token: token)
    }
    
    func loadFromToken(token: String) async throws {
        guard shouldReload else { return }
        
        self.token = token
        cachedToken = token
        
        let data = try await CFQPersistentData.loadFromCacheOrRefresh()
        
        self.data = data
        
        do {
            let maimaiProfile = try await JSONDecoder().decode(MaimaiPlayerProfile.self, from: MaimaiDataGrabber.getPlayerProfile(token: token))
            let maimaiRecord = try await JSONDecoder().decode(MaimaiPlayerRecord.self, from: MaimaiDataGrabber.getPlayerRecord(token: token))
            let maimaiRecent = try await JSONDecoder().decode(Array<MaimaiRecentRecord>.self, from: MaimaiDataGrabber.getRecentData(username: maimaiProfile.username, limit: Int(entryCount) ?? 30))
            
            self.maimai = Maimai(profile: maimaiProfile, record: maimaiRecord, recent: maimaiRecent)
            calculateMaimaiData()
        } catch {
            print(error)
            self.maimai = nil
        }
        
        do {
            let chunithmProfile = try await JSONDecoder().decode(ChunithmUserData.self, from: ChunithmDataGrabber.getUserRecord(token: token))
            let chunithmRecent = try await JSONDecoder().decode(Array<ChunithmRecentRecord>.self, from: ChunithmDataGrabber.getRecentData(username: chunithmProfile.username, limit: Int(entryCount) ?? 30))
            let chunithmUserScore = try await JSONDecoder().decode(ChunithmUserScoreData.self, from: ChunithmDataGrabber.getUserScoreData(username: chunithmProfile.username))
            
            self.chunithm = Chunithm(profile: chunithmProfile, rating: chunithmUserScore, recent: chunithmRecent)
            calculateChunithmData()
        } catch {
            print(error)
            self.chunithm = nil
        }
        
        self.username = self.maimai?.profile.username ?? self.chunithm?.profile.username ?? ""
        self.nickname = self.maimai?.profile.nickname ?? self.chunithm?.profile.username ?? ""
        
        self.displayName = self.nickname.isEmpty ? self.username : self.nickname
        
        shouldReload = false
        
        try saveToCache()
    }
    
    static func loadFromCache() -> CFQUser {
        @AppStorage("userToken") var cachedToken = ""
        @AppStorage("userMaimaiCache") var maimaiCache = Data()
        @AppStorage("userChunithmCache") var chunithmCache = Data()
        
        guard (!maimaiCache.isEmpty && !chunithmCache.isEmpty) else {
            print("User cache is empty, returning.")
            return CFQUser()
        }
        
        let user = CFQUser()
        user.token = cachedToken
        
        do {
            user.maimai = try JSONDecoder().decode(Maimai.self, from: maimaiCache)
        } catch {
            user.maimai = nil
        }
        
        do {
            user.chunithm = try JSONDecoder().decode(Chunithm.self, from: chunithmCache)
        } catch {
            user.chunithm = nil
        }
        
        user.username = user.maimai?.profile.username ?? user.chunithm?.profile.username ?? ""
        user.nickname = user.maimai?.profile.nickname ?? user.chunithm?.profile.username ?? ""
        
        user.displayName = user.nickname.isEmpty ? user.username : user.nickname
        
        user.shouldReload = false
        user.didLogin = true
        
        return user
    }
    
    func saveToCache() throws {
        maimaiCache = try JSONEncoder().encode(maimai)
        chunithmCache = try JSONEncoder().encode(chunithm)
        print("Saved user cache.")
    }
    
    static func hasCache() -> Bool {
        @AppStorage("userMaimaiCache") var maimaiCache = Data()
        @AppStorage("userChunithmCache") var chunithmCache = Data()
        return !maimaiCache.isEmpty || !chunithmCache.isEmpty
    }
    
    func clear() {
        self.username = ""
        self.nickname = ""
        self.displayName = ""
        self.maimai = Maimai()
        self.chunithm = Chunithm()
        self.data = CFQPersistentData()
        self.shouldReload = true
    }
}

extension Int {
    mutating func flip() {
        self = 1 - self
    }
}

extension Double {
    func cut(remainingDigits: Int) -> Double {
        return floor(self * pow(10, Double(remainingDigits))) / pow(10, Double(remainingDigits))
    }
}

extension Array<MaimaiRecentRecord> {
    func getLatestNewRecord() -> (Int?, MaimaiRecentRecord?) {
        let new = self.filter {
            $0.is_new_record == 1
        }.sorted {
            $0.timestamp > $1.timestamp
        }.first
        return (self.firstIndex {
            $0.timestamp == new?.timestamp
        }, new)
    }
    
    func getLatestHighscore() -> (Int?, MaimaiRecentRecord?) {
        let high = self.filter {
            $0.getRawAchievement() >= 100.0
        }.sorted {
            $0.getRawAchievement() > $1.getRawAchievement()
        }.first
        return (self.firstIndex {
            $0.timestamp == high?.timestamp
        }, high)
    }
}

extension Array<ChunithmRecentRecord> {
    func getLatestNewRecord() -> (Int?, ChunithmRecentRecord?) {
        let new = self.filter {
            $0.is_new_record == 1
        }.sorted {
            $0.timestamp > $1.timestamp
        }.first
        return (self.firstIndex {
            $0.timestamp == new?.timestamp
        }, new)
    }
    
    func getLatestHighscore() -> (Int?, ChunithmRecentRecord?) {
        let high = self.filter {
            $0.getRawScore() > 1000000
        }.sorted {
            $0.getRawScore() > $1.getRawScore()
        }.first
        return (self.firstIndex {
            $0.timestamp == high?.timestamp
        }, high)
    }
}
