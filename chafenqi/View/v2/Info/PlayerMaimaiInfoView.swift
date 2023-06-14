//
//  PlayerMaimaiInfoView.swift
//  chafenqi
//
//  Created by xinyue on 2023/6/7.
//

import SwiftUI
import SwiftUICharts

let maiRankHex = [
    Color(hex: 0xf4d941),
    Color(hex: 0xf6ca3a),
    Color(hex: 0xf6bc35),
    Color(hex: 0xf5ad33),
    Color(hex: 0xf39f32),
    Color(hex: 0xf09033),
    Color(hex: 0xec8235),
    Color(hex: 0xBF682A)
]
let maiStatusHex = [
    Color(hex: 0x6eee87),
    Color(hex: 0x69e473),
    Color(hex: 0x65da5e),
    Color(hex: 0x62cf47),
    Color(hex: 0x5fc52e)
]
let maiRankDesc = ["SSS+", "SSS", "SS+", "SS", "S+", "S", "其他"]
let maiStatusDesc = ["AP+", "AP", "FC+", "FC", "Clear"]

struct PlayerMaimaiInfoView: View {
    @Environment(\.managedObjectContext) var context
    @ObservedObject var user: CFQNUser
    
    var body: some View {
        ScrollView {
            if user.isPremium {
                VStack(spacing: 5) {
                    AsyncImage(url: URL(string: user.maimai.info.charUrl)!, context: context, placeholder: {
                        ProgressView()
                    }, image: { img in
                        Image(uiImage: img)
                            .resizable()
                    })
                    .aspectRatio(1, contentMode: .fit)
                    .mask(RoundedRectangle(cornerRadius: 5))
                    .frame(width: 200)
                    .padding(.bottom)
                    
                    
                    HStack {
                        Text("Rating")
                        Spacer()
                        Text("\(user.maimai.info.rating)")
                            .bold()
                    }
                    HStack {
                        Text("称号")
                        Spacer()
                        Text(user.maimai.info.trophy)
                            .bold()
                    }
                    HStack {
                        Text("游玩次数")
                        Spacer()
                        Text("\(user.maimai.info.playCount)")
                            .bold()
                    }
                    HStack {
                        Text("觉醒数")
                        Spacer()
                        Text("\(user.maimai.info.star)")
                            .bold()
                    }
                }
                .padding()
                
                HStack(alignment: .top) {
                    let rankData = makeRankData()
                    let statusData = makeStatusData()
                    VStack {
                        PieChart(chartData: rankData)
                            .touchOverlay(chartData: rankData)
                            .headerBox(chartData: rankData)
                            .frame(width: 150, height: 150)
                            .id(rankData.id)
                            .padding(.bottom)
                        
                        ForEach(rankData.dataSets.dataPoints, id: \.id) { point in
                            HStack {
                                Text(point.description ?? "")
                                Spacer()
                                Text("\(point.value, specifier: "%.0f")")
                            }
                        }
                    }
                    VStack {
                        PieChart(chartData: statusData)
                            .touchOverlay(chartData: statusData)
                            .headerBox(chartData: statusData)
                            .frame(width: 150, height: 150)
                            .id(statusData.id)
                            .padding(.bottom)
                        
                        ForEach(statusData.dataSets.dataPoints, id: \.id) { point in
                            HStack {
                                Text(point.description ?? "")
                                Spacer()
                                Text("\(point.value, specifier: "%.0f")")
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("玩家信息")
        .navigationBarTitleDisplayMode(.large)
    }
    
    func makeRankData() -> PieChartData {
        var dataPoints = [PieChartDataPoint]()
        let array = user.maimai.custom.rankCounter
        for v in array.indices {
            dataPoints.append(PieChartDataPoint(value: Double(array[v]), description: maiRankDesc[v], colour: maiRankHex[v]))
        }
        return PieChartData(dataSets: PieDataSet(dataPoints: dataPoints, legendTitle: "评级"), metadata: ChartMetadata(title: "评级", subtitle: "所有难度"), chartStyle: PieChartStyle(infoBoxPlacement: .header))
    }
    
    func makeStatusData() -> PieChartData {
        var dataPoints = [PieChartDataPoint]()
        let array = user.maimai.custom.statusCounter
        for v in array.indices {
            dataPoints.append(PieChartDataPoint(value: Double(array[v]), description: maiStatusDesc[v], colour: maiStatusHex[v]))
        }
        return PieChartData(dataSets: PieDataSet(dataPoints: dataPoints, legendTitle: "状态"), metadata: ChartMetadata(title: "状态", subtitle: "所有难度"), chartStyle: PieChartStyle(infoBoxPlacement: .header))
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}
