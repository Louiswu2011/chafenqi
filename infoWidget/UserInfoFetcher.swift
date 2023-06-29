//
//  UserInfoFetcher.swift
//  chafenqi
//
//  Created by xinyue on 2023/6/28.
//

import Foundation
import SwiftUI

struct UserInfoFetcher {
    @FetchRequest(sortDescriptors: []) static var infos: FetchedResults<WidgetUser>
    
    static let decoder = JSONDecoder()
    
    static var isPremium = false
    static var maimai: CFQMaimai.UserInfo?
    static var chunithm: CFQChunithm.UserInfo?

    static func refreshData() async throws {
        if let currentUser = UserDefaults(suiteName: "group.com.nltv.chafenqi.shared")?.string(forKey: "currentUser") {
            NSLog("[CFQWidget] Current user: " + currentUser)
            let info = try WidgetDataController.shared.fetchBy(username: currentUser)
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
}
