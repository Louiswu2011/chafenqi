//
//  WidgetData.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/6/30.
//

import Foundation

struct WidgetData {
    struct Customization: Codable {
        enum Module: Codable {
            case playCount, rating, lastUpload
        }
        
        var charUrl: String?
        var bgUrl: String?
        
        var smallModuleList: [Module]?
        var mediumModuleList: [Module]?
        var bigModuleList: [Module]?
    }
    
    var username: String
    var isPremium: Bool
    
    var maimaiInfo: CFQMaimai.UserInfo?
    var chunithmInfo: CFQChunithm.UserInfo?
    
    var maiRecentOne: CFQMaimai.RecentScoreEntry?
    var chuRecentOne: CFQChunithm.RecentScoreEntry?
    
    var chuCover: Data?
    var maiCover: Data?
    
    var custom: Customization?
}
