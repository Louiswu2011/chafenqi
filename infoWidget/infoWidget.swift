//
//  infoWidget.swift
//  infoWidget
//
//  Created by xinyue on 2023/6/27.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent(), error: "")
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration, maimai: UserInfoFetcher.maimai, chunithm: UserInfoFetcher.chunithm, error: "")
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        
        Task {
            do {
                try await UserInfoFetcher.refreshData()
                let entry = SimpleEntry(
                    date: currentDate,
                    configuration: configuration,
                    isPremium: UserInfoFetcher.isPremium,
                    maimai: UserInfoFetcher.maimai,
                    chunithm: UserInfoFetcher.chunithm,
                    maiRecentOne: UserInfoFetcher.maiRecentOne,
                    chuRecentOne: UserInfoFetcher.chuRecentOne,
                    maiCover: UserInfoFetcher.cachedMaiCover,
                    chuCover: UserInfoFetcher.cachedChuCover,
                    custom: UserInfoFetcher.custom,
                    error: "no error")
                let timeline = Timeline(entries: [entry], policy: .atEnd)
                completion(timeline)
            } catch {
                let timeline = Timeline(entries: [SimpleEntry(date: currentDate, configuration: configuration, error: error.localizedDescription)], policy: .atEnd)
                NSLog("[InfoWidget] Error: " + String(describing: error))
                completion(timeline)
                
            }
        }
    }
}

struct SimpleEntry: TimelineEntry {
    var date: Date
    var configuration: ConfigurationIntent
    var isPremium: Bool = false
    var maimai: CFQMaimai.UserInfo? = nil
    var chunithm: CFQChunithm.UserInfo? = nil
    var maiRecentOne: CFQMaimai.RecentScoreEntry? = nil
    var chuRecentOne: CFQChunithm.RecentScoreEntry? = nil
    var maiCover: Data = Data()
    var chuCover: Data = Data()
    var custom: WidgetData.Customization? = nil
    var error: String
}




struct infoWidget: Widget {
    let kind: String = "userInfoWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            infoWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("玩家信息")
        .description("此小组件将显示您的玩家信息和概况")
        .supportedFamilies([.systemMedium, .systemSmall])
    }
}

struct infoWidget_Previews: PreviewProvider {
    static var previews: some View {
        infoWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), error: ""))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

extension Color {
    init(red: Int, green: Int, blue: Int){
        self.init(red: Double(red) / 255, green: Double(green) / 255, blue: Double(blue) / 255)
    }
}
