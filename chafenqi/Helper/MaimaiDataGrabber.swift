//
//  MaimaiDataGrabber.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/3.
//

import Foundation

struct MaimaiDataGrabber {
    static func getSongCoverUrl(source: Int, coverId: Int) -> URL {
        return URL(string: "https://assets2.lxns.net/maimai/jacket/\(coverId).png")!
    }
}
