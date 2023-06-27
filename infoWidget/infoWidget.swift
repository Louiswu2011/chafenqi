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
        SimpleEntry(date: Date(), configuration: ConfigurationIntent(), mode: 0)
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration, mode: 0)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration, mode: 0)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let mode: Int
}

struct infoWidgetEntryView : View {
    @Environment(\.widgetFamily) var size
    var entry: Provider.Entry
    
    var nameplateChuniColorTop = Color(red: 254, green: 241, blue: 65)
    var nameplateChuniColorBottom = Color(red: 243, green: 200, blue: 48)
    
    var nameplateMaiColorTop = Color(red: 167, green: 243, blue: 254)
    var nameplateMaiColorBottom = Color(red: 93, green: 166, blue: 247)

    var body: some View {
        ZStack {
            LinearGradient(colors: entry.mode == 0 ? [nameplateChuniColorTop, nameplateChuniColorBottom] : [nameplateMaiColorTop, nameplateMaiColorBottom], startPoint: .top, endPoint: .bottom)

            VStack {
                HStack {
                    Text("LOUISE")
                        .bold()
                    Spacer()
//                    Text("你已经有5天没出勤啦！")
//                        .font(.system(size: 15))
//                        .padding(.trailing, 5)
                }
                .padding([.top, .leading])
                
                HStack {
                    WidgetInfoBox(content: "16161", title: "Rating")
                    WidgetInfoBox(content: "1000", title: "游玩次数")
                    WidgetInfoBox(content: "06/28", title: "最近更新")
                    Spacer()
                }
                .padding(.horizontal)
                
                Spacer()
            }
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Image(entry.mode == 0 ? "penguin" : "salt")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 105)
                        .shadow(radius: 3, x: 4, y: 4)
                }
            }
        }
        
    }
}

struct WidgetInfoBox: View {
    var content: String
    var title: String
    
    var body: some View {
        VStack {
            Text(content)
                .font(.system(size: 15))
                .bold()
            Text(title)
                .font(.system(size: 10))
        }
        .padding(5)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.gray.opacity(0.25))
                .frame(width: 70)
                .shadow(radius: 2, x: 2, y: 2)
        )
        .frame(width: 70)
        
    }
}

struct infoWidget: Widget {
    let kind: String = "userInfoWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            infoWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("玩家信息")
        .description("此小组件将显示您的玩家信息和概况")
        .supportedFamilies([.systemMedium])
    }
}

struct infoWidget_Previews: PreviewProvider {
    static var previews: some View {
        infoWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), mode: 1))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

extension Color {
    init(red: Int, green: Int, blue: Int){
        self.init(red: Double(red) / 255, green: Double(green) / 255, blue: Double(blue) / 255)
    }
}
