//
//  DataTool.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/21.
//

import Foundation

let difficulty = ["Expert": "exp", "Master": "mst", "Ultima": "ult"]

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
    if let id = Double(id) {
        if (1e4...11e3).contains(id) {
            let pad = id - 1e4
            return String(String(String(Int(pad)).reversed()).padding(toLength: 5, withPad: "0", startingAt: 0).reversed())
        } else {
            return String(String(String(Int(id)).reversed()).padding(toLength: 5, withPad: "0", startingAt: 0).reversed())
        }
    }
    
    if (id.count == 5) {
        return String(id[id.index(after: id.startIndex)..<id.endIndex])
    } else {
        return String(format: "%04d", Int(id)!)
    }
}

