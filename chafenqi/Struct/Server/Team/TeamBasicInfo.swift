//
//  TeamBasicInfo.swift
//  chafenqi
//
//  Created by 刘易斯 on 2024/12/24.
//

import Foundation

struct TeamBasicInfo: Codable {
    let id: Int
    let displayName: String
    let nameLastModifiedAt: Int
    let teamCode: String
    let leaderUserId: Int
    let style: String
    let remarks: String
    let promotable: Bool
    let lastMonthActivityPoints: Int
    let currentActivityPoints: Int
    let courseName: String
    let courseTrack1: String
    let courseTrack2: String
    let courseTrack3: String
    let courseHealth: Int
    let coursePrimaryErrorPenalty: Int
    let courseSecondaryErrorPenalty: Int
    let courseTertiaryErrorPenalty: Int
    let courseLastModifiedAt: Int
    let pinnedMessageId: Int?
    let createdAt: Int
    let lastActivityAt: Int
    
    static let empty = TeamBasicInfo(
        id: 0,
        displayName: "",
        nameLastModifiedAt: 0,
        teamCode: "",
        leaderUserId: 0,
        style: "",
        remarks: "",
        promotable: false,
        lastMonthActivityPoints: 0,
        currentActivityPoints: 0,
        courseName: "",
        courseTrack1: "",
        courseTrack2: "",
        courseTrack3: "",
        courseHealth: 0,
        coursePrimaryErrorPenalty: 0,
        courseSecondaryErrorPenalty: 0,
        courseTertiaryErrorPenalty: 0,
        courseLastModifiedAt: 0,
        pinnedMessageId: nil,
        createdAt: 0,
        lastActivityAt: 0
    )
}

struct TeamCourseTrack {
    let musicId: Int
    let levelIndex: Int
    
    init(musicId: Int, levelIndex: Int) {
        self.musicId = musicId
        self.levelIndex = levelIndex
    }
    
    init(trackString: String) {
        self.musicId = Int(trackString.split(separator: ",")[0]) ?? 0
        self.levelIndex = Int(trackString.split(separator: ",")[1]) ?? 0
    }
}

extension TeamBasicInfo {
    func courseTracks() -> [TeamCourseTrack]? {
        guard courseTrack1 != "" else {
            return nil
        }
        
        let track1 = TeamCourseTrack(trackString: courseTrack1)
        let track2 = TeamCourseTrack(trackString: courseTrack2)
        let track3 = TeamCourseTrack(trackString: courseTrack3)
        
        return [track1, track2, track3]
    }
    
    func activeDays() -> Int {
        let now = Date().timeIntervalSince1970
        let interval = now - Double(createdAt)
        return Int(interval / 86400)
    }
}
