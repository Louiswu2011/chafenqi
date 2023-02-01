//
//  CutCircularProgressView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/6.
//

import SwiftUI

struct CutCircularProgressView: View {
    let progress: Double
    let lineWidth: Double
    let width: Double
    let color: Color
    
    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: 0.666)
                .stroke(
                    color.opacity(0.3),
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(150.0))
                .frame(width: width, height: width)
                
            
            Circle()
                .trim(from: 0, to: progress / 3 * 2)
                .stroke(
                    color,
                    style: StrokeStyle(
                        lineWidth: lineWidth,
                        lineCap: .round
                    )
                    
                )
                .rotationEffect(.degrees(150.0))
                .frame(width: width, height: width)
                .animation(.easeInOut, value: progress)
        }
    }
}

struct CutCircularProgressView_Previews: PreviewProvider {
    static var previews: some View {
        CutCircularProgressView(progress: 0.5, lineWidth: 20.0, width: 100.0, color: Color.pink)
    }
}
