//
//  DeltaDetailView.swift
//  chafenqi
//
//  Created by xinyue on 2023/5/29.
//

import SwiftUI

struct DeltaDetailView: View {
    let testRatingData: [(Double, String)] = [
        (2050, "5-20"),
        (2060, "5-21"),
        (2063, "5-22"),
        (2070, "5-23"),
        (2075, "5-24"),
        (2090, "5-25"),
        (2111, "5-26")
    ]
    let testPCData: [(Double, String)] = [
        (120, "5-20"),
        (135, "5-21"),
        (142, "5-22"),
        (149, "5-23"),
        (153, "5-24"),
        (154, "5-25"),
        (163, "5-26")
    ]
    
    @State var chartType = 0
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    DeltaTextBlock(title: "Rating", currentValue: "2111", deltaValue: "+21")
                    DeltaTextBlock(title: "游玩次数", currentValue: "163", deltaValue: "+9")
                    Spacer()
                }
                
                if chartType == 0 {
                    RatingDeltaChart(rawDataPoints: testRatingData)
                        .frame(height: 250)
                } else {
                    PCDeltaChart(rawDataPoints: testPCData)
                        .frame(height: 250)
                }
                
                Button {
                    withAnimation(.spring()) {
                        chartType = 1 - chartType
                    }
                } label: {
                    Image(systemName: "arrow.left.arrow.right")
                    Text("切换图表")
                }
                .padding()
                
                HStack {
                    Text("游玩记录")
                        .font(.system(size: 20))
                        .bold()
                    Spacer()
                    NavigationLink {
                        
                    } label: {
                        Text("显示全部")
                    }
                }
                VStack {
                    
                }
            }
            .padding()
        }
    }
}

struct DeltaTextBlock: View {
    var title: String
    var currentValue: String
    var deltaValue: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
            HStack(alignment: .bottom) {
                Text(currentValue)
                    .font(.system(size: 25))
                Text(deltaValue)
            }
        }
    }
}

struct DeltaDetailView_Previews: PreviewProvider {
    static var previews: some View {
        DeltaDetailView()
    }
}
