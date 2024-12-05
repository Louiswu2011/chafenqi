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
    @State var chuDayPlayData = CFQChunithmDayRecords()
    @State var maiDayPlayData = CFQMaimaiDayRecords()
    @State var shouldShowMarkers = true

    @State var isLoaded = false
    @State var isRatingChart = false
    
    var body: some View {
        ScrollView {
            if isLoaded {
                HStack(spacing: 10) {
                    VStack(alignment: .leading) {
                        Text("出勤天数")
                        Text("\(pcChartData.count)")
                            .font(.system(size: 25))
                            .bold()
                    }
                    VStack(alignment: .leading) {
                        Text("游玩次数")
                        Text("\(deltaCount)")
                            .font(.system(size: 25))
                            .bold()
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("估算花费")
                        Text("¥\(Double(deltaCount) * (Double(user.currentMode == 0 ? user.chuPricePerTrack : user.maiPricePerTrack) ?? 1), specifier: "%.2f")")
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
                ZStack {
                    VStack {
                        HStack {
                            Spacer()
                            Button {
                                withAnimation {
                                    isRatingChart.toggle()
                                }
                            } label: {
                                Image(systemName: "arrow.left.arrow.right")
                                Text("切换图表")
                            }
                        }
                        Spacer()
                    }
                    
                    if isRatingChart {
                        RatingDeltaChart(rawDataPoints: $ratingChartData, shouldShowMarkers: $shouldShowMarkers)
                    } else {
                        PCDeltaChart(rawDataPoints: $pcChartData, shouldShowMarkers: $shouldShowMarkers)
                    }
                }
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
                    DeltaList(user: user, chuDelta: chuDayPlayData)
                } else if user.currentMode == 1 && user.maimai.info.count > 2 {
                    DeltaList(user: user, maiDelta: maiDayPlayData)
                } else {
                    DeltaList(user: user)
                }
            }
        }
        .onAppear {
            loadVar()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    shouldShowMarkers.toggle()
                } label: {
                    Image(systemName: shouldShowMarkers ? "eye" : "eye.slash")
                }
            }
        }
        .navigationTitle("上传记录")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func loadVar() {
        guard !isLoaded else { return }
        let chuDelta = user.chunithm.delta
        let maiDelta = user.maimai.info
        ratingChartData = []
        pcChartData = []
        
        if user.currentMode == 0 && !chuDelta.isEmpty {
            chuDayPlayData = CFQChunithmDayRecords(recents: user.chunithm.recent, deltas: user.chunithm.delta)
            let latest7 = chuDayPlayData.records.suffix(7)
            
            deltaCount = chuDayPlayData.records.reduce(0) {
                $0 + $1.recentEntries.count
            }
            playCount = user.chunithm.info.playCount
            
            if let first = latest7.last?.latestDelta {
                if let latest = latest7.first?.latestDelta {
                    avgRatingGrowth = (latest.rating - first.rating) / Double(latest7.count)
                }
            }
            
            avgPlayCount = Double(deltaCount) / Double(chuDayPlayData.dayPlayed)
            
            for datum in chuDayPlayData.records {
                if let rating = datum.latestDelta?.rating {
                    ratingChartData.append((Double(rating), DateTool.shared.premiumTransformer.string(from: datum.date)))
                }
                pcChartData.append((Double(datum.recentEntries.count), DateTool.shared.premiumTransformer.string(from: datum.date)))
            }
        } else if user.currentMode == 1 && !maiDelta.isEmpty {
            maiDayPlayData = CFQMaimaiDayRecords(recents: user.maimai.recent, deltas: user.maimai.info)
            let latest7 = maiDayPlayData.records.suffix(7)
            
            deltaCount = maiDayPlayData.records.reduce(0) {
                $0 + $1.recentEntries.count
            }
            playCount = user.maimai.info.last?.playCount ?? 0
            if let first = latest7.last?.latestDelta {
                if let latest = latest7.first?.latestDelta {
                    avgRatingGrowth = Double(first.rating - latest.rating) / Double(latest7.count)
                }
            }
            
            avgPlayCount = Double(deltaCount) / Double(maiDayPlayData.dayPlayed)
            
            for datum in maiDayPlayData.records {
                if let rating = datum.latestDelta?.rating {
                    ratingChartData.append((Double(rating), DateTool.shared.premiumTransformer.string(from: datum.date)))
                }
                pcChartData.append((Double(datum.recentEntries.count), DateTool.shared.premiumTransformer.string(from: datum.date)))
            }
        }
        isLoaded = true
    }
}

struct DeltaList: View {
    @ObservedObject var user: CFQNUser
    
    @State var chuDelta: CFQChunithmDayRecords?
    @State var maiDelta: CFQMaimaiDayRecords?
    
    var body: some View {
        VStack {
            if let deltas = chuDelta {
                ForEach(Array(deltas.records.reversed().enumerated()), id: \.offset) { index, value in
                    NavigationLink {
                        DeltaDetailView(user: user, chuLog: value)
                    } label: {
                        HStack {
                            Text(DateTool.shared.yyyymmddTransformer.string(from: value.date))
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                    }
                }
            } else if let deltas = maiDelta {
                ForEach(Array(deltas.records.reversed().enumerated()), id: \.offset) { index, value in
                    NavigationLink {
                        DeltaDetailView(user: user, maiLog: value)
                    } label: {
                        HStack {
                            Text(DateTool.shared.yyyymmddTransformer.string(from: value.date))
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
