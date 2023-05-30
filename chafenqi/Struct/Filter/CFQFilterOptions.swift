//
//  CFQFilterOptions.swift
//  chafenqi
//
//  Created by xinyue on 2023/5/29.
//

import Foundation

struct CFQFilterOptions {
    static let shared = CFQFilterOptions()
    
    static var levelOptions: [String] {
        var options: [String] = []
        for i in 1...15 {
            options.append("\(i)")
            if (7...14).contains(i) {
                options.append("\(i)+")
            }
        }
        return options
    }
    
    static var chuGenreOptions = [String]()
    static var maiGenreOptions = [String]()
    static var chuVersionOptions = [String]()
    static var maiVersionOptions = [String]()
    
    var filterMaiLevelToggles: [Bool] = []
    var filterChuLevelToggles: [Bool] = []
    var filterMaiGenreToggles: [Bool] = []
    var filterChuGenreToggles: [Bool] = []
    var filterMaiVersionToggles: [Bool] = []
    var filterChuVersionToggles: [Bool] = []
}
