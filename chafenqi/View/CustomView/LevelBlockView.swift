//
//  LevelBlockView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/5.
//

import SwiftUI

struct LevelStripView: View {
    var mode: Int
    var levels: Array<String>
    
    var body: some View {
        HStack {
            LevelBlockView(color: Color.green, level: levels[0])
            LevelBlockView(color: Color.yellow, level: levels[1])
            LevelBlockView(color: Color.red, level: levels[2])
            LevelBlockView(color: Color.purple, level: levels[3])
            if (levels.count == 5) {
                LevelBlockView(color: mode == 0 ? Color.black : remasterColor, level: levels[4])
            }
        }
    }
}

struct LevelBlockView: View {
    var color: Color
    var level: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .foregroundColor(color)
            
            Text(level)
                .font(.system(size: 15))
                .foregroundColor(.white)
        }
        .frame(width: 30, height: 20)
    }
}

struct LevelBlockView_Previews: PreviewProvider {
    static var previews: some View {
        LevelStripView(mode: 0, levels: ["7", "9", "11", "13+", "14+"])
    }
}
