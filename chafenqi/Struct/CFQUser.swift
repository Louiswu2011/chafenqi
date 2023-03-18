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
    
    var username = ""
    var nickname = ""
    var displayName = ""
    
    var maimai: Maimai? = Maimai()
    var chunithm: Chunithm? = Chunithm()
    
    var data = CFQPersistentData()
    
    struct Maimai: Codable {
        var profile: MaimaiPlayerProfile = MaimaiPlayerProfile.shared
        var record: MaimaiPlayerRecord = MaimaiPlayerRecord.shared
        var recent: Array<MaimaiRecentRecord> = []
        
        var custom: Custom = Custom()
        
        struct Custom: Codable {
            var pastRating = 0
            var currentRating = 0
            var rawRating = 0
            var totalCharts = 0
            var totalPlayed = 0
            var avgAchievement = 0.0
            var nationalRanking = 0
        }
    }
    
    struct Chunithm: Codable {
        var profile: ChunithmUserData = ChunithmUserData.shared
        var rating: ChunithmUserScoreData = ChunithmUserScoreData.shared
        var recent: Array<ChunithmRecentRecord> = []
        var custom: Custom = Custom()
        
        struct Custom: Codable {
            var overpower = 0.0
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
    }
    
    private func calculateChunithmData() {
        let records = self.chunithm!.profile.records
        let qualifiedList = records.best.filter {
            ($0.levelIndex == 3 || $0.levelIndex == 4) && $0.score >= 975000
        }
        
        var overpower: Double = 0.0
        for entry in qualifiedList {
            let score = entry.score
            var rating: Double {
                switch (entry.score) {
                case 975000...999999:
                    return entry.constant + Double(entry.score - 975000) / 2500 * 0.1
                case 1000000...1004999:
                    return entry.constant + 1.0 + Double(entry.score - 1000000) / 1000 * 0.1
                case 1005000...1007499:
                    return entry.constant + 1.5 + Double(entry.score - 1005000) / 500 * 0.1
                case 1007500...1008999:
                    return entry.constant + 2.0 + Double(entry.score - 1007500) / 100 * 0.01
                case 1009000...1010000:
                    return entry.constant + 2.15
                default:
                    return 0
                }
            }
            var op: Double = 0.0
            var extra: Double {
                if (entry.getStatus() == "FC") {
                    return 0.5
                } else if (entry.getStatus() == "AJ") {
                    return 1.0
                } else {
                    return 0.0
                }
            }
            
            
            if (score <= 1007500) {
                op = rating * 5.0
            } else if (score < 1010000) {
                op = (entry.constant + 2.0) * 5.0 + Double((score - 1007500)) * 0.0015
            } else if (score == 1010000) {
                op = (entry.constant + 2.0) * 5.0 + 4.0
            }
            
            print("title \(entry.title), level \(entry.levelLabel), score \(score), base \(op), status \(entry.status), bonus \(extra)")
            if((extra == 0.0 && entry.getStatus() != "Clear") || (extra != 0.0 && entry.getStatus() == "Clear")) {
                print("Wrong extra value, got \(extra) while status is \(entry.getStatus())")
            }
            
            overpower += (op + extra)
        }
        
        for i in 10...15 {
            print("Level \(i): \(qualifiedList.filter {$0.level == "\(i)"}.count)")
            print("Level \(i)+: \(qualifiedList.filter {$0.level == "\(i)+"}.count)")
        }
        
        print(qualifiedList.count)
        
        self.chunithm!.custom.overpower = overpower
    }
    
    func refresh() async {
        await self.loadFromToken(token: token, data: data)
    }
    
    func loadFromToken(token: String, data: CFQPersistentData) async {
        self.token = token
        self.data = data
        
        do {
            let maimaiProfile = try await JSONDecoder().decode(MaimaiPlayerProfile.self, from: MaimaiDataGrabber.getPlayerProfile(token: token))
            let maimaiRecord = try await JSONDecoder().decode(MaimaiPlayerRecord.self, from: MaimaiDataGrabber.getPlayerRecord(token: token))
            let maimaiRecent = try await JSONDecoder().decode(Array<MaimaiRecentRecord>.self, from: MaimaiDataGrabber.getRecentData(username: maimaiProfile.username))
            
            self.maimai = Maimai(profile: maimaiProfile, record: maimaiRecord, recent: maimaiRecent)
            calculateMaimaiData()
        } catch {
            self.maimai = nil
        }
        
        do {
            let chunithmProfile = try await JSONDecoder().decode(ChunithmUserData.self, from: ChunithmDataGrabber.getUserRecord(token: token))
            let chunithmRecent = try await JSONDecoder().decode(Array<ChunithmRecentRecord>.self, from: ChunithmDataGrabber.getRecentData(username: chunithmProfile.username))
            let chunithmUserScore = try await JSONDecoder().decode(ChunithmUserScoreData.self, from: ChunithmDataGrabber.getUserScoreData(username: chunithmProfile.username))
            
            self.chunithm = Chunithm(profile: chunithmProfile, rating: chunithmUserScore, recent: chunithmRecent)
            calculateChunithmData()
        } catch {
            self.chunithm = nil
        }
        
        self.username = self.maimai?.profile.username ?? self.chunithm?.profile.username ?? ""
        self.nickname = self.maimai?.profile.nickname ?? self.chunithm?.profile.username ?? ""
        
        self.displayName = self.nickname.isEmpty ? self.username : self.nickname
        
    }
}

extension Int {
    mutating func flip() {
        self = 1 - self
    }
}
