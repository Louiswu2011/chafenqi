//
//  RegexManager.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/3/6.
//

import Foundation


final class RegexManager {
    static let shared = RegexManager()
    
    let constantRegex = try! NSRegularExpression(pattern: #"\[(?<lowerDigit>[0-9]{1,2})(?<lowerDecimal>\.[0-9])?-(?<upperDigit>[0-9]{1,2})(?<upperDecimal>\.[0-9])?\]"#)
    let levelRegex = try! NSRegularExpression(pattern: #"<(?<lower>[0-9]{1,2}[+]?)-(?<upper>[0-9]{1,2}[+]?)>"#)
    let difficultyRegex = try! NSRegularExpression(pattern: #"\{[0-4]{1}\}"#)
}
