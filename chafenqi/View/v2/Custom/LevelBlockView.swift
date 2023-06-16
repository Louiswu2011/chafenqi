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
        let levelColor = mode == 0 ? chunithmLevelColor : maimaiLevelColor
        
        HStack {
            LevelBlockView(color: levelColor[0]!, level: levels[0])
            LevelBlockView(color: levelColor[1]!, level: levels[1])
            LevelBlockView(color: levelColor[2]!, level: levels[2])
            LevelBlockView(color: levelColor[3]!, level: levels[3])
            if (levels.count > 4 && levels[4] != "0") {
                LevelBlockView(color: levelColor[4]!, level: levels[4])
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
