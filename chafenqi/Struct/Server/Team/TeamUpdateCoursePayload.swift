//
//  TeamUpdateCoursePayload.swift
//  chafenqi
//
//  Created by 刘易斯 on 2024/12/24.
//

import Foundation

struct TeamUpdateCoursePayload: Codable {
    let courseName: String
    let courseTrack1: CourseEntry
    let courseTrack2: CourseEntry
    let courseTrack3: CourseEntry
    let courseHealth: Int
    
    struct CourseEntry: Codable {
        let musicId: Int
        let levelIndex: Int
    }
}
