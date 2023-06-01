//
//  RatingDeltaCharat.swift
//  chafenqi
//
//  Created by xinyue on 2023/5/29.
//

import SwiftUI
import SwiftUICharts

struct RatingDeltaChart: View {
    @State var rawDataPoints = [(Double, String)]()
    
    var body: some View {
        let chartData = addDataPoints()
        VStack {
            LineChart(chartData: chartData)
                .pointMarkers(chartData: chartData)
                .touchOverlay(chartData: chartData)
                .xAxisGrid(chartData: chartData)
                .xAxisLabels(chartData: chartData)
                .yAxisGrid(chartData: chartData)
                .yAxisLabels(chartData: chartData)
                .floatingInfoBox(chartData: chartData)
                .headerBox(chartData: chartData)
                .id("ratingDeltaChart")
        }
    }
    
    func addDataPoints() -> LineChartData {
        var dataPoints = [LineChartDataPoint]()
        for (point, description) in rawDataPoints {
            dataPoints.append(LineChartDataPoint(value: point, xAxisLabel: description))
        }
        let data = LineDataSet(
            dataPoints: dataPoints,
            legendTitle: "Rating",
            pointStyle: .init(),
            style: .init(lineColour: .init(colour: .red), lineType: .line)
        )
        let metadata = ChartMetadata(title: "Rating", subtitle: "近7次上传")
        let chartStyle = LineChartStyle(
            infoBoxPlacement: .floating,
            infoBoxBorderColour: Color.primary,
            infoBoxBorderStyle: StrokeStyle(lineWidth: 1),
            markerType: .bottomLeading(attachment: .line(dot: .style(.init()))),
            baseline: .minimumValue,
            topLine: .maximumValue,
            globalAnimation: .easeOut(duration: 0.3)
        )
        return LineChartData(dataSets: data, metadata: metadata, chartStyle: chartStyle)
    }
}

struct RatingDeltaChart_Previews: PreviewProvider {
    static var previews: some View {
        DeltaDetailView()
    }
}