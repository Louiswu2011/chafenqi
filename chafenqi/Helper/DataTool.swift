//
//  DataTool.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/21.
//

import Foundation

let teamNameLimit = 24
let teamStyleLimit = 16
let teamRemarksLimit = 120

let difficulty = ["Expert": "exp", "Master": "mst", "Ultima": "ult"]
let chunithmRanks = ["SSS+", "SSS", "SS+", "SS", "S+", "S", "其他"]

let maimaiLevelLabel = [
    0: "Basic",
    1: "Advanced",
    2: "Expert",
    3: "Master",
    4: "Re:Master"
]

let chunithmLevelLabel = [
    0: "Basic",
    1: "Advanced",
    2: "Expert",
    3: "Master",
    4: "Ultima",
    5: "World's End"
]

class DataTool {
    static let shared = DataTool()
    
    let numberFormatter = NumberFormatter()
    
    init() {
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.numberStyle = .decimal
        numberFormatter.roundingMode = .down
    }
}


func getCoverNumber(id: String) -> String {
    if let id = Int(id) {
        if id >= 100000 {
            return getCoverNumber(id: String(id - 100000))
        } else if (10000...11000).contains(id) {
            let pad = id - 10000
            var padded = String(pad)
            while padded.count < 5 {
                padded = "0" + padded
            }
            return padded
        } else if id < 10000 {
            var padded = String(id)
            while padded.count < 5 {
                padded = "0" + padded
            }
            return padded
        } else {
            return String(id)
        }
    } else {
        return id
    }
}

