//
//  WidgetData.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/6/30.
//

import Foundation

struct WidgetData {
    struct Customization: Codable, Equatable {
        enum Module: Codable {
            case playCount, rating, lastUpload
        }
        
        var maiCharType: Int?
        var maiCharUrl: String?
        var maiBgUrl: String?
        var maiColor: [[CGFloat]]?
        var maiBgBlur: Double?
        var chuCharUrl: String?
        var chuBgUrl: String?
        var chuColor: [[CGFloat]]?
        var chuBgBlur: Double?
        
        var smallModuleList: [Module]?
        var mediumModuleList: [Module]?
        var bigModuleList: [Module]?
        
        // chu big, chu small, mai big, mai small
        var darkModes: [Bool] = [false, false, false, false]
    }
    
    var username: String
    var isPremium: Bool
    
    var maimaiInfo: UserMaimaiPlayerInfoEntry?
    var chunithmInfo: UserChunithmPlayerInfo?
    
    var maiRecentOne: UserMaimaiRecentScoreEntry?
    var chuRecentOne: UserChunithmRecentScoreEntry?
    
    var chuChar: Data?
    var chuBg: Data?
    var chuCover: Data?
    
    var maiChar: Data?
    var maiBg: Data?
    var maiCover: Data?
    
    var custom: Customization?
}
