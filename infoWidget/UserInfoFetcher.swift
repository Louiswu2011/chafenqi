//
//  UserInfoFetcher.swift
//  chafenqi
//
//  Created by xinyue on 2023/6/28.
//

import Foundation
import UIKit
import CoreData

struct UserInfoFetcher {
    static let decoder = JSONDecoder()
    static let session = URLSession.shared
    
    static var isPremium = false
    static var maimai: UserMaimaiPlayerInfoEntry?
    static var chunithm: UserChunithmPlayerInfo?
    static var maiRecentOne: UserMaimaiRecentScoreEntry?
    static var chuRecentOne: UserChunithmRecentScoreEntry?
    
    static var cachedMaiCover = Data()
    static var cachedChuCover = Data()
    static var cachedMaiBg = Data()
    static var cachedChuBg = Data()
    static var cachedMaiChar = Data()
    static var cachedChuChar = Data()
    
    static var custom: WidgetData.Customization?


    static func refreshData() async throws {
        if let currentUser = UserDefaults(suiteName: "group.com.nltv.chafenqi.shared")?.string(forKey: "currentUser") {
            NSLog("[CFQWidget] Current user: " + currentUser)
            let info = try self.fetchBy(username: currentUser)
            if let info = info {
                self.isPremium = info.isPremium
                NSLog("[CFQWidget] Premium: " + (isPremium ? "true" : "false"))
                if let maiData = info.maimai {
                    do {
                        self.maimai = try decoder.decode(UserMaimaiPlayerInfoEntry.self, from: maiData)
                    } catch {
                        self.maimai = nil
                    }
                }
                if let chuData = info.chunithm {
                    do {
                        self.chunithm = try decoder.decode(UserChunithmPlayerInfo.self, from: chuData)
                    } catch {
                        self.chunithm = nil
                    }
                }
                if let maiRecentOne = info.maiRecentOne {
                    do {
                        self.maiRecentOne = try decoder.decode(UserMaimaiRecentScoreEntry.self, from: maiRecentOne)
                        NSLog("[CFQWidget] Found maimai recent data")
                    } catch {
                        self.maiRecentOne = nil
                    }
                }
                if let chuRecentOne = info.chuRecentOne {
                    do {
                        self.chuRecentOne = try decoder.decode(UserChunithmRecentScoreEntry.self, from: chuRecentOne)
                        NSLog("[CFQWidget] Found chunithm recent data")
                    } catch {
                        self.chuRecentOne = nil
                    }
                }
                if let custom = info.custom, isPremium {
                    do {
                        self.custom = try decoder.decode(WidgetData.Customization.self, from: custom)
                        NSLog("[CFQWidget] Found customization data")
                    } catch {
                        self.custom = nil
                        NSLog("[CFQWidget] Customization data not found or parse error: \(error)")
                    }
                }
                self.cachedMaiCover = info.maiCover ?? Data()
                self.cachedChuCover = info.chuCover ?? Data()
                self.cachedMaiBg = info.maiBg ?? Data()
                self.cachedChuBg = info.chuBg ?? Data()
                self.cachedMaiChar = info.maiChar ?? Data()
                self.cachedChuChar = info.chuChar ?? Data()
            }
        }
    }
    
    static func fetchBy(username: String) throws -> WidgetUser? {
        let predicate = NSPredicate(format: "username == %@", username)
        let request = WidgetUser.fetchRequest()
        request.predicate = predicate
        let entries = try WidgetDataController.shared.container.viewContext.fetch(request)
        return entries.first
    }
}


