//
//  CFQSharedValue.swift
//  chafenqi
//
//  Created by Louis Wu on 2025/01/26.
//

import Foundation

struct SharedValues {
    static let serverAddress = "43.139.107.206"
    static let alternativeServerAddress = "chafenqi.nltv.online"
    static let apiServerAddress = "http://\(serverAddress):8998/"
    static let uploadServerAddress = "http://\(serverAddress):9030/"
    static let alternativeUploadServerAddress = "http://\(alternativeServerAddress):9030/"
    static let proxyServerPort = 8999
}
