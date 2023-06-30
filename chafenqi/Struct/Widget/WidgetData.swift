//
//  WidgetData.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/6/30.
//

import Foundation

struct WidgetData {
    struct Customization {
        
    }
    
    var username: String
    var isPremium: Bool
    
    var maimaiInfo: CFQMaimai.UserInfo
    var chunithmInfo: CFQChunithm.UserInfo
    
    var maiRecentOne: CFQMaimai.RecentScoreEntry?
    var chuRecentOne: CFQChunithm.RecentScoreEntry?
    
    var chuCover: Data?
    var maiCover: Data?
}
