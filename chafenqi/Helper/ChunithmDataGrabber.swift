//
//  ProberDataGrabber.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/8.
//

import Foundation

struct ChunithmDataGrabber {
    static func getSongCoverUrl(source: Int, musicId: String) -> URL {
        return URL(string: "\(SharedValues.serverAddress)api/resource/chunithm/cover?musicId=\(musicId)")!
    }
}
