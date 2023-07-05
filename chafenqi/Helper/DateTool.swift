//
//  DateTool.swift
//  chafenqi
//
//  Created by xinyue on 2023/7/5.
//

import Foundation

class DateTool {
    let formatter = ISO8601DateFormatter()
    let freeTransformer = DateFormatter()
    let defaultTransformer = DateFormatter()
    let intTransformer = DateFormatter()
    let premiumTransformer = DateFormatter()
    let updateFormatter = ISO8601DateFormatter()
    let yyyymmddTransformer = DateFormatter()
    
    static let shared = DateTool()
    
    init() {
        yyyymmddTransformer.timeZone = .autoupdatingCurrent
        yyyymmddTransformer.dateFormat = "yyyy-MM-dd"
        premiumTransformer.timeZone = .autoupdatingCurrent
        premiumTransformer.dateFormat = "MM-dd"
        updateFormatter.timeZone = .autoupdatingCurrent
        updateFormatter.formatOptions = [.withFractionalSeconds, .withInternetDateTime, .withTimeZone]
        defaultTransformer.timeZone = .autoupdatingCurrent
        defaultTransformer.dateFormat = "MM-dd HH:mm"
        intTransformer.timeZone = .autoupdatingCurrent
        intTransformer.dateFormat = "yy-MM-dd HH:mm"
        freeTransformer.timeZone = .autoupdatingCurrent
        formatter.timeZone = .autoupdatingCurrent
        formatter.formatOptions = [.withColonSeparatorInTimeZone, .withSpaceBetweenDateAndTime, .withFractionalSeconds, .withInternetDateTime]
    }
    
    static func defaultDateString(from: String) -> String {
        let date = DateTool.shared.formatter.date(from: from)
        if let date = date {
            return DateTool.shared.defaultTransformer.string(from: date)
        }
        return ""
    }
    
    static func updateDateString(from: String) -> String {
        let date = DateTool.shared.updateFormatter.date(from: from)
        if let date = date {
            return DateTool.shared.defaultTransformer.string(from: date)
        }
        return ""
    }
    
    static func premiumDateString(from: String) -> String {
        let date = DateTool.shared.formatter.date(from: from)
        if let date = date {
            return DateTool.shared.premiumTransformer.string(from: date)
        }
        return ""
    }
    
    static func toDateString(from: String, format: String) -> String {
        let date = DateTool.shared.formatter.date(from: from)
        if let date = date {
            DateTool.shared.freeTransformer.dateFormat = format
            return DateTool.shared.freeTransformer.string(from: date)
        }
        return ""
    }
    
    static func toDate(from: String) -> Date? {
        return DateTool.shared.formatter.date(from: from)
    }
}
