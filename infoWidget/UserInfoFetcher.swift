//
//  UserInfoFetcher.swift
//  chafenqi
//
//  Created by xinyue on 2023/6/28.
//

import Foundation
import CoreData

struct UserInfoFetcher {
    static let decoder = JSONDecoder()
    
    static var isPremium = false
    static var maimai: CFQMaimai.UserInfo?
    static var chunithm: CFQChunithm.UserInfo?


    static func refreshData() async throws {
        if let currentUser = UserDefaults(suiteName: "group.com.nltv.chafenqi.shared")?.string(forKey: "currentUser") {
            NSLog("[CFQWidget] Current user: " + currentUser)
            let info = try self.fetchBy(username: currentUser)
            if let info = info {
                self.isPremium = info.isPremium
                NSLog("[CFQWidget] Premium: " + (isPremium ? "true" : "false"))
                if let maiData = info.maimai {
                    self.maimai = try decoder.decode(CFQMaimai.UserInfo.self, from: maiData)
                }
                if let chuData = info.chunithm {
                    self.chunithm = try decoder.decode(CFQChunithm.UserInfo.self, from: chuData)
                }
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
