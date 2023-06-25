//
//  InfoMaimaiClearList.swift
//  chafenqi
//
//  Created by xinyue on 2023/6/21.
//

import SwiftUI

struct InfoMaimaiClearList: View {
    
    var body: some View {
        ScrollView {
            HStack(alignment: .bottom) {
                Text("等级")
                Text("14")
                    .bold()
                    .font(.system(size: 25))
                Spacer()
            }
            .padding()
            
            MaimaiClearBarView()
                .frame(height: 25)
                .mask(RoundedRectangle(cornerRadius: 5))
                .padding([.bottom, .horizontal])
            HStack {
                ForEach(Array(maiRankDesc.enumerated()), id: \.offset) { index, string in
                    Circle()
                        .foregroundColor(maiRankHex[index])
                        .frame(width: 8)
                    Text(string)
                }
            }
            .padding(.bottom)
            HStack {
                Text("歌曲列表")
                    .bold()
                Spacer()
                Text("SSS+")
            }
            .padding(.horizontal)
            VStack {
                
            }
        }
    }
}

struct InfoMaimaiClearList_Previews: PreviewProvider {
    static var previews: some View {
        InfoMaimaiClearList()
    }
}

struct MaimaiClearBarView: View {
    var data = [0.003, 0.017, 0.08, 0.09, 0.11, 0.13, 0.27]
    
    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                ForEach(Array(data.enumerated()), id: \.offset) { index, dataPoint in
                    Rectangle()
                        .foregroundColor(maiRankHex[index])
                        .frame(width: geo.size.width * dataPoint)
                }
                Rectangle()
                    .foregroundColor(.gray)
            }
        }
    }
}

extension Shape {
    /// fills and strokes a shape
    public func fill<S:ShapeStyle>(
        _ fillContent: S,
        strokeContent: S,
        strokeStyle: StrokeStyle
    ) -> some View {
        ZStack {
            self.fill(fillContent)
            self.stroke(strokeContent, style: strokeStyle)
        }
    }
}
