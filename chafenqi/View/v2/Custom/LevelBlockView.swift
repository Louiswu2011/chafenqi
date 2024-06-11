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
            ForEach(levels.indices, id: \.self) { index in
                if let color = levelColor[index], levels[index] != "0" && !levels[index].isEmpty {
                    LevelBlockView(color: color, level: levels[index])
                }
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
