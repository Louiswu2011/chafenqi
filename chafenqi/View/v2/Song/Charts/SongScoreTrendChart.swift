//
//  SongScoreTrendChart.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/6/18.
//

import SwiftUI
import SwiftUICharts

struct SongScoreTrendChart: View {
    @Binding var rawDataPoints: [(Double, String)]
    var mode = 0
    
    var body: some View {
        let chartData = addDataPoints()
        VStack {
            LineChart(chartData: chartData)
                .pointMarkers(chartData: chartData)
                .touchOverlay(chartData: chartData, specifier: mode == 0 ? "%0.f" : "%.4f", unit: mode == 0 ? .none : .suffix(of: "%"))
                .yAxisGrid(chartData: chartData)
                .yAxisLabels(chartData: chartData, specifier: mode == 0 ? "%0.f" : "%.2f")
                .floatingInfoBox(chartData: chartData)
                .headerBox(chartData: chartData)
                .transaction { transaction in
                    transaction.animation = nil
                }
                .id(UUID())
        }
    }
    
    func addDataPoints() -> LineChartData {
        var dataPoints = [LineChartDataPoint]()
        for (point, description) in rawDataPoints {
            dataPoints.append(LineChartDataPoint(value: point, xAxisLabel: description, description: description))
        }
        let data = LineDataSet(
            dataPoints: dataPoints,
            legendTitle: "成绩",
            pointStyle: .init(),
            style: .init(lineColour: .init(colour: .blue), lineType: .line)
        )
        let metadata = ChartMetadata(title: "成绩趋势", subtitle: "全部数据")
        let chartStyle = LineChartStyle(
            infoBoxPlacement: .floating,
            infoBoxBorderColour: Color.primary,
            infoBoxBorderStyle: StrokeStyle(lineWidth: 1),
            markerType: .indicator(style: .init()),
            baseline: .minimumValue,
            topLine: .maximumValue
        )
        return LineChartData(dataSets: data, metadata: metadata, chartStyle: chartStyle)
    }
}

