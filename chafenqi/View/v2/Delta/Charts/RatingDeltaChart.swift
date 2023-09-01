//
//  RatingDeltaCharat.swift
//  chafenqi
//
//  Created by xinyue on 2023/5/29.
//

import SwiftUI
import SwiftUICharts

struct RatingDeltaChart: View {
    @Binding var rawDataPoints: [(Double, String)]
    @State var isChunithm = true
    @Binding var shouldShowMarkers: Bool
    
    var body: some View {
        let chartData = addDataPoints()
        VStack {
            if shouldShowMarkers {
                LineChart(chartData: chartData)
                    .pointMarkers(chartData: chartData)
                    .touchOverlay(chartData: chartData, specifier: isChunithm ? "%.2f" : "%.0f")
                    .yAxisGrid(chartData: chartData)
                    .yAxisLabels(chartData: chartData, specifier: isChunithm ? "%.2f" : "%.0f")
                    .floatingInfoBox(chartData: chartData)
                    .headerBox(chartData: chartData)
                    .transaction { transaction in
                        transaction.animation = nil
                    }
                    .id(UUID())
            } else {
                LineChart(chartData: chartData)
                    .touchOverlay(chartData: chartData, specifier: isChunithm ? "%.2f" : "%.0f")
                    .yAxisGrid(chartData: chartData)
                    .yAxisLabels(chartData: chartData, specifier: isChunithm ? "%.2f" : "%.0f")
                    .floatingInfoBox(chartData: chartData)
                    .headerBox(chartData: chartData)
                    .transaction { transaction in
                        transaction.animation = nil
                    }
                    .id(UUID())
            }
        }
    }
    
    func addDataPoints() -> LineChartData {
        var dataPoints = [LineChartDataPoint]()
        for (point, description) in rawDataPoints {
            dataPoints.append(LineChartDataPoint(value: point, xAxisLabel: description, description: description))
        }
        let data = LineDataSet(
            dataPoints: dataPoints,
            legendTitle: "Rating",
            pointStyle: .init(),
            style: .init(lineColour: .init(colour: .red), lineType: .curvedLine)
        )
        let metadata = ChartMetadata(title: "Rating", subtitle: "全部数据")
        let chartStyle = LineChartStyle(
            infoBoxPlacement: .floating,
            infoBoxBorderColour: Color.primary,
            infoBoxBorderStyle: StrokeStyle(lineWidth: 1),
            markerType: .bottomLeading(attachment: .line(dot: .style(.init()))),
            baseline: .minimumValue,
            topLine: .maximumValue
        )
        return LineChartData(dataSets: data, metadata: metadata, chartStyle: chartStyle)
    }
}
