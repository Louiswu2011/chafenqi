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
