//
//  DeltaDetailView.swift
//  chafenqi
//
//  Created by xinyue on 2023/5/29.
//

import SwiftUI

struct DeltaDetailView: View {
    @ObservedObject var user = CFQNUser()
    
    @State var deltaIndex = 0
    
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
    
    @State var rating: String = ""
    @State var ratingDelta: String = ""
    @State var pc: String = ""
    @State var pcDelta: String = ""
    @State var ratingChartData: [(Double, String)] = []
    @State var pcChartData: [(Double, String)] = []
    
    @State var chartType = 0
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    DeltaTextBlock(title: "Rating", currentValue: rating, deltaValue: ratingDelta)
                        .padding(.trailing, 5)
                    DeltaTextBlock(title: "游玩次数", currentValue: pc, deltaValue: pcDelta)
                    Spacer()
                }
                
                if chartType == 0 {
                    RatingDeltaChart(rawDataPoints: ratingChartData)
                        .frame(height: 250)
                } else {
                    PCDeltaChart(rawDataPoints: pcChartData)
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
        .onAppear {
            loadVar()
        }
    }
    
    func loadVar() {
        if user.currentMode == 0 && user.chunithm.delta.count > 1 {
            let latestDelta = user.chunithm.delta[deltaIndex]
            rating = String(format: "%.2f", latestDelta.rating)
            pc = "\(latestDelta.playCount)"
            if deltaIndex == user.chunithm.delta.count - 1 {
                ratingDelta = getRatingDelta(current: 0, past: 0)
                pcDelta = getPCDelta(current: 0, past: 0)
            } else {
                let secondDelta = user.chunithm.delta[deltaIndex + 1]
                ratingDelta = getRatingDelta(current: latestDelta.rating, past: secondDelta.rating)
                pcDelta = getPCDelta(current: latestDelta.playCount, past: secondDelta.playCount)
            }
            let deltas = user.chunithm.delta.prefix(7)
            for delta in deltas {
                ratingChartData.append((delta.rating, convertDate(delta.createdAt)))
                pcChartData.append((Double(delta.playCount), convertDate(delta.createdAt)))
            }
        } else if user.currentMode == 1 && user.maimai.delta.count > 1 {
            let latestDelta = user.maimai.delta[deltaIndex]
            rating = "\(latestDelta.rating)"
            pc = "\(latestDelta.playCount)"
            if deltaIndex == user.maimai.delta.count - 1 {
                ratingDelta = getRatingDelta(current: 0, past: 0)
                pcDelta = getPCDelta(current: 0, past: 0)
            } else {
                let secondDelta = user.maimai.delta[deltaIndex + 1]
                ratingDelta = getRatingDelta(current: latestDelta.rating, past: secondDelta.rating)
                pcDelta = getPCDelta(current: latestDelta.playCount, past: secondDelta.playCount)
            }
            let deltas = user.maimai.delta.prefix(7)
            for delta in deltas {
                ratingChartData.append((Double(delta.rating), convertDate(delta.createdAt)))
                pcChartData.append((Double(delta.playCount), convertDate(delta.createdAt)))
            }
        }
        ratingChartData.reverse()
        pcChartData.reverse()
    }
    
    func getRatingDelta(current lhs: Double, past rhs: Double) -> String {
        let rawValue = lhs - rhs
        if rawValue > 0 {
            return "+" + String(format: "%.2f", rawValue)
        } else if rawValue < 0 {
            return String(format: "%.2f", rawValue)
        } else {
            return "\u{00B1}0"
        }
    }
    
    func getRatingDelta(current lhs: Int, past rhs: Int) -> String {
        let rawValue = lhs - rhs
        if rawValue > 0 {
            return "+\(rawValue)"
        } else if rawValue < 0 {
            return "\(rawValue)"
        } else {
            return "\u{00B1}0"
        }
    }
    
    func getPCDelta(current lhs: Int, past rhs: Int) -> String {
        let rawValue = lhs - rhs
        if rawValue > 0 {
            return "+\(rawValue)"
        } else if rawValue < 0 {
            return "\(rawValue)"
        } else {
            return "\u{00B1}0"
        }
    }
    
    func convertDate(_ dateString: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd hh:mm:ss.SSS Z"
        if let date = dateFormatter.date(from: dateString) {
            let mmddFormatter = DateFormatter()
            mmddFormatter.dateFormat = "MM-dd"
            return mmddFormatter.string(from: date)
        }
        return ""
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
