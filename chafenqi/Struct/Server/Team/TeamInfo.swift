//
//  TeamInfo.swift
//  chafenqi
//
//  Created by 刘易斯 on 2024/12/24.
//

import Foundation

struct TeamInfo: Codable {
    let info: TeamBasicInfo
    let members: [TeamMember]
    let pendingMembers: [TeamPendingMember]
    let activities: [TeamActivity]
    let bulletinBoard: [TeamBulletinBoardEntry]
    let courseRecords: [TeamCourseRecord]
    
    static let empty = TeamInfo(
        info: TeamBasicInfo.empty,
        members: [],
        pendingMembers: [],
        activities: [],
        bulletinBoard: [],
        courseRecords: []
    )
}
