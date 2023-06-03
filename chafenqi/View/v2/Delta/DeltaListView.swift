//
//  DeltaListView.swift
//  chafenqi
//
//  Created by xinyue on 2023/5/29.
//

import SwiftUI

struct DeltaListView: View {
    @ObservedObject var user = CFQNUser()
    
    @State var deltaCount = 0
    @State var playCount = 0
    @State var avgPlayCount: Double = 0
    @State var avgRatingGrowth: Double = 0
    @State var ratingChartData: [(Double, String)] = []
    @State var pcChartData: [(Double, String)] = []
    @State var chuDayPlayData: [(CFQChunithmRecentScoreEntries, String)] = []
    @State var maiDayPlayData: [(CFQMaimaiRecentScoreEntries, String)] = []

    @State var isLoaded = false
    
    var body: some View {
        ScrollView {
            if isLoaded {
                HStack(spacing: 10) {
                    VStack(alignment: .leading) {
                        Text("上传次数")
                        Text("\(deltaCount)")
                            .font(.system(size: 25))
                            .bold()
                    }
                    VStack(alignment: .leading) {
                        Text("游玩次数")
                        Text("\(playCount)")
                            .font(.system(size: 25))
                            .bold()
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("估算花费")
                        Text("¥\(playCount * 2)")
                            .font(.system(size: 25))
                            .bold()
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 5)
                HStack(spacing: 10) {
                    VStack(alignment: .leading) {
                        Text("平均游玩次数")
                        Text("\(avgPlayCount, specifier: "%.2f")")
                            .font(.system(size: 20))
                    }
                    VStack(alignment: .leading) {
                        Text("近7次Rating平均增长")
                        Text("\(avgRatingGrowth, specifier: "%.3f")")
                            .font(.system(size: 20))
                    }
                    Spacer()
                }
                .padding([.horizontal, .bottom])
                PCDeltaChart(rawDataPoints: $pcChartData)
                    .padding(.horizontal)
                    .padding(.bottom)
                HStack {
                    Text("出勤记录")
                        .font(.system(size: 18))
                        .bold()
                    Spacer()
                }
                .padding(.horizontal)
                if user.currentMode == 0 && user.chunithm.delta.count > 2 {
                    DeltaList(user: user, chuDelta: user.chunithm.delta)
                } else if user.currentMode == 1 && user.maimai.delta.count > 2 {
                    DeltaList(user: user, maiDelta: user.maimai.delta)
                } else {
                    DeltaList(user: user)
                }
            }
        }
        .onAppear {
            loadVar()
        }
        .navigationTitle("上传记录")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func loadVar() {
        let chuDelta = user.chunithm.delta
        let maiDelta = user.maimai.delta
        ratingChartData = []
        pcChartData = []
        
        if user.currentMode == 0 && !chuDelta.isEmpty {
            let latest7 = user.chunithm.delta.suffix(7)
            
            deltaCount = user.chunithm.delta.count
            playCount = user.chunithm.info.playCount
            
            if let latest = latest7.last {
                if let first = latest7.first {
                    avgRatingGrowth = (latest.rating - first.rating) / Double(latest7.count)
                }
            }
            
            let latestStamp = user.chunithm.recent.first?.timestamp ?? 0
            var firstStamp = user.chunithm.recent.last?.timestamp ?? 0
            var t = firstStamp
            var dayPlayed = 0
            while t <= latestStamp {
                t += 86400
                let playInDay = user.chunithm.recent.filter { entry in
                    (firstStamp...t).contains(entry.timestamp)
                }
                if !playInDay.isEmpty {
                    let dateString = firstStamp.toDateString(format: "MM-dd")
                    chuDayPlayData.append((playInDay, dateString))
                    dayPlayed += 1
                }
                firstStamp += 86400
            }
            avgPlayCount = Double(deltaCount) / Double(dayPlayed)
            
            for datum in chuDayPlayData {
                pcChartData.append((Double(datum.0.count), datum.1))
            }
        } else if user.currentMode == 1 && !maiDelta.isEmpty {
            let latest7 = user.maimai.delta.suffix(7)
            
            deltaCount = user.maimai.delta.count
            playCount = user.maimai.info.playCount
            if let latest = latest7.last {
                if let first = latest7.first {
                    avgRatingGrowth = Double(latest.rating - first.rating) / Double(latest7.count)
                }
            }
            
            let latestStamp = user.maimai.recent.first?.timestamp ?? 0
            var firstStamp = user.maimai.recent.last?.timestamp ?? 0
            var t = firstStamp
            var dayPlayed = 0
            while t <= latestStamp {
                t += 86400
                let playInDay = user.maimai.recent.filter { entry in
                    (firstStamp...t).contains(entry.timestamp)
                }
                if !playInDay.isEmpty {
                    let dateString = firstStamp.toDateString(format: "MM-dd")
                    maiDayPlayData.append((playInDay, dateString))
                    dayPlayed += 1
                }
                firstStamp += 86400
            }
            avgPlayCount = Double(deltaCount) / Double(dayPlayed)
            
            for datum in maiDayPlayData {
                pcChartData.append((Double(datum.0.count), datum.1))
            }
        }
        isLoaded = true
    }
}

struct DeltaList: View {
    @ObservedObject var user: CFQNUser
    
    @State var chuDelta: CFQChunithmDeltaEntries?
    @State var maiDelta: CFQMaimaiDeltaEntries?
    
    var body: some View {
        VStack {
            if let deltas = chuDelta {
                ForEach(Array(deltas.enumerated()), id: \.offset) { index, value in
                    NavigationLink {
                        DeltaDetailView(user: user, deltaIndex: index)
                    } label: {
                        HStack {
                            Text(value.createdAt.toDateString(format: "yyyy-MM-dd hh:mm"))
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                    }
                }
            } else if let deltas = maiDelta {
                ForEach(Array(deltas.enumerated()), id: \.offset) { index, value in
                    NavigationLink {
                        DeltaDetailView(user: user, deltaIndex: index)
                    } label: {
                        HStack {
                            Text(value.createdAt.toDateString(format: "yyyy-MM-dd hh:mm"))
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                    }
                }
            } else {
                HStack(alignment: .center) {
                    Text("未找到数据\n请先进行一次成绩上传")
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding(.top, 5)
        .padding(.horizontal)
    }
    
}

struct DeltaListView_Previews: PreviewProvider {
    static var previews: some View {
        DeltaListView()
    }
}
