//
//  DataTool.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/21.
//

import Foundation

let difficulty = ["Expert": "exp", "Master": "mst", "Ultima": "ult"]

class DataTool {
    static let shared = DataTool()
    
    let numberFormatter = NumberFormatter()
    
    init() {
        numberFormatter.maximumFractionDigits = 2
        numberFormatter.numberStyle = .decimal
        numberFormatter.roundingMode = .down
    }
}

func getMaxRatingPossible(songList: Set<ChunithmSongData>) -> Double {
    var max = 0.0
    
    let sortedList = songList.sorted(by: { (a, b) in
        return a.constant.last! > b.constant.last!
    })
    
    for i in 0..<30 {
        max += sortedList[i].constant.last!
    }
    
    return max / 30.0
}


func getCoverNumber(id: String) -> String {
    print("from", id)
    if let id = Int(id) {
        if (10000...11000).contains(id) {
            let pad = id - 10000
            var padded = String(pad)
            while padded.count < 5 {
                padded = "0" + padded
            }
            print("to", padded)
            return padded
        } else if id < 10000 {
            var padded = String(id)
            while padded.count < 5 {
                padded = "0" + padded
            }
            print("to", padded)
            return padded
        } else {
            print("to", String(id))
            return String(id)
        }
    } else {
        print("to", id)
        return id
    }
}

