//
//  ErrorLogger.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/9/4.
//

import Foundation

class Logger {
    struct Log {
        var timestamp: TimeInterval
        var log: String
    }
    
    static let shared = Logger()
    
    var logs: Array<Log> = []
    
    func append(_ log: String) {
        let item = Log(timestamp: Date().timeIntervalSince1970, log: log)
        if self.logs.count >= 50 {
            self.logs.removeFirst()
        }
        self.logs.append(item)
    }
}
