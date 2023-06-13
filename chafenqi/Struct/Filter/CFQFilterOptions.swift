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
    
    static let chuGenreOptions = ["ORIGINAL", "POPS & ANIME", "VARIETY", "niconico", "東方Project", "イロドリミドリ", "ゲキマイ"]
    static let maiGenreOptions = ["maimai", "POPSアニメ", "ゲームバラエティ", "niconicoボーカロイド", "東方Project", "オンゲキCHUNITHM"]
    static let chuVersionOptions = [
        "CHUNITHM",
        "CHUNITHM PLUS",
        "CHUNITHM AIR",
        "CHUNITHM AIR PLUS",
        "CHUNITHM STAR",
        "CHUNITHM STAR PLUS",
        "CHUNITHM AMAZON",
        "CHUNITHM AMAZON PLUS",
        "CHUNITHM CRYSTAL",
        "CHUNITHM CRYSTAL PLUS",
        "CHUNITHM PARADISE",
        "CHUNITHM PARADISE LOST",
        "CHUNITHM NEW"
    ]
    static let maiVersionOptions = [
        "maimai",
        "maimai PLUS",
        "maimai GreeN",
        "maimai GreeN PLUS",
        "maimai ORANGE",
        "maimai ORANGE PLUS",
        "maimai PiNK",
        "maimai PiNK PLUS",
        "maimai MURASAKI",
        "maimai MURASAKI PLUS",
        "maimai MILK",
        "maimai MILK PLUS",
        "maimai FiNALE",
        "maimai \u{3067}\u{3089}\u{3063}\u{304f}\u{3059}",
        "maimai \u{3067}\u{3089}\u{3063}\u{304f}\u{3059} Splash",
        "maimai \u{3067}\u{3089}\u{3063}\u{304f}\u{3059} Splash PLUS",
        "maimai \u{3067}\u{3089}\u{3063}\u{304f}\u{3059} UNiVERSE",
        "maimai \u{3067}\u{3089}\u{3063}\u{304f}\u{3059} FESTiVAL"
    ]
    static let sortOptions = [
        "无",
        "等级",
        "定数",
        "BPM"
    ]
    static let sortMethods = [
        "升序",
        "降序"
    ]
    
    var filterMaiLevelToggles: [Bool] = []
    var filterMaiGenreToggles: [Bool] = []
    var filterMaiVersionToggles: [Bool] = []
    var sortMaiSelection: String = "无"
    
    var filterChuGenreToggles: [Bool] = []
    var filterChuLevelToggles: [Bool] = []
    var filterChuVersionToggles: [Bool] = []
    var sortChuSelection: String = "无"
    
    var excludeChuWEChart: Bool = true
}
