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
        SimpleEntry(date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
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
            LinearGradient(colors: [nameplateMaiColorTop, nameplateMaiColorBottom], startPoint: .top, endPoint: .bottom)
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Image("salt")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 110)
                        .shadow(radius: 5)
                }
            }
            
            VStack {
                HStack {
                    Text("Username")
                        .bold()
                        .padding(.bottom, 1)
                    Spacer()
                }
                .padding([.top, .leading])
                
                HStack {
                    VStack {
                        Text("1000")
                            .bold()
                        Text("游玩次数")
                    }
                    .padding(5)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 80)
                    )
                    .frame(width: 80)
                    VStack {
                        Text("16161")
                            .bold()
                        Text("Rating")
                    }
                    .padding(5)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 80)
                    )
                    .frame(width: 80)
                    VStack {
                        Text("06/27")
                            .bold()
                        Text("最近更新")
                    }
                    .padding(5)
                    .background(
                        RoundedRectangle(cornerRadius: 5)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 80)
                    )
                    .frame(width: 80)
                    Spacer()
                }
                .padding(.horizontal)
                
                Spacer()
            }
        }
        
    }
}

struct infoWidget: Widget {
    let kind: String = "infoWidget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            infoWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemMedium])
    }
}

struct infoWidget_Previews: PreviewProvider {
    static var previews: some View {
        infoWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

extension Color {
    init(red: Int, green: Int, blue: Int){
        self.init(red: Double(red) / 255, green: Double(green) / 255, blue: Double(blue) / 255)
    }
}
