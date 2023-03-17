//
//  CFQUserData.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/3/18.
//

import Foundation

class CFQUser: ObservableObject {
    @Published var token = ""
    
    @Published var username = ""
    @Published var nickname = ""
    
    @Published var maimai: Maimai?
    @Published var chunithm: Chunithm?
    
    struct Maimai: Codable {
        var profile: MaimaiPlayerProfile
        var record: MaimaiPlayerRecord
        var rating: MaimaiPlayerRating
        var recent: Array<MaimaiRecentRecord>
    }
    
    struct Chunithm: Codable {
        var profile: ChunithmUserData
        var rating: ChunithmUserScoreData
        var recent: Array<ChunithmRecentRecord>
    }
}
