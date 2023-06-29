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
        SimpleEntry(date: Date(), configuration: ConfigurationIntent(), maimai: Maimai.empty, chunithm: Chunithm.empty, error: "")
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration, maimai: UserInfoFetcher.cachedMaimai, chunithm: UserInfoFetcher.cachedChunithm, error: "")
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        
        Task {
            do {
                try await UserInfoFetcher.refreshData()
                let entry = SimpleEntry(date: currentDate, configuration: configuration, maimai: UserInfoFetcher.cachedMaimai, chunithm: UserInfoFetcher.cachedChunithm, error: "未出现错误")
                let timeline = Timeline(entries: [entry], policy: .atEnd)
                completion(timeline)
            } catch {
                var mai = Maimai.empty
                var chu = Chunithm.empty
                mai.nickname = "刷新失败"
                chu.nickname = "刷新失败"
                let timeline = Timeline(entries: [SimpleEntry(date: currentDate, configuration: configuration, maimai: mai, chunithm: chu, error: UserInfoFetcher.lastErrorCause + error.localizedDescription)], policy: .atEnd)
                completion(timeline)
            }
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let maimai: Maimai
    let chunithm: Chunithm
    let error: String
}

struct infoWidgetEntryView : View {
    @Environment(\.widgetFamily) var size
    var entry: Provider.Entry
    
    var nameplateChuniColorTop = Color(red: 254, green: 241, blue: 65)
    var nameplateChuniColorBottom = Color(red: 243, green: 200, blue: 48)
    
    var nameplateMaiColorTop = Color(red: 167, green: 243, blue: 254)
    var nameplateMaiColorBottom = Color(red: 93, green: 166, blue: 247)
    
    @State private var username = ""
    @State private var rating = ""
    @State private var lastUpdate = ""
    @State private var playCount = ""
    @State private var cover = UIImage()
    @State private var title = ""
    @State private var score = ""
    @State private var hasRecent = false

    @ViewBuilder
    var body: some View {
        ZStack {
            if entry.configuration.debugMode == 1 {
                Text(entry.error)
            } else {
                if size == .systemMedium {
                    LinearGradient(colors: entry.configuration.currentMode == .chunithm ? [nameplateChuniColorTop, nameplateChuniColorBottom] : [nameplateMaiColorTop, nameplateMaiColorBottom], startPoint: .top, endPoint: .bottom)
                    
                    VStack {
                        HStack {
                            Text(username)
                                .bold()
                            Spacer()
                        }
                        .padding([.top, .leading])
                        
                        HStack {
                            WidgetInfoBox(content: rating, title: "Rating")
                            WidgetInfoBox(content: playCount, title: "游玩次数")
                            WidgetInfoBox(content: lastUpdate, title: "最近更新")
                            Spacer()
                        }
                        .padding(.horizontal)
                        
//                        if hasRecent {
//                            HStack {
//                                Image(uiImage: cover)
//                                    .resizable()
//                                    .aspectRatio(1, contentMode: .fit)
//                                    .frame(width: 30)
//                                    .mask(RoundedRectangle(cornerRadius: 5))
//                                    .shadow(radius: 2, x: 2, y: 2)
//
//                                Text(title)
//                                    .frame(maxWidth: 150)
//                                    .lineLimit(1)
//                                Text(score)
//                                    .bold()
//                                Spacer()
//                            }
//                            .padding([.leading, .top])
//                        }
                        
                        Spacer()
                    }
                    
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(entry.configuration.currentMode == .chunithm ? "penguin" : "salt")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 105)
                                .shadow(radius: 3, x: 4, y: 4)
                        }
                    }
                } else if size == .systemSmall {
                    LinearGradient(colors: entry.configuration.currentMode == .chunithm ? [nameplateChuniColorTop, nameplateChuniColorBottom] : [nameplateMaiColorTop, nameplateMaiColorBottom], startPoint: .top, endPoint: .bottom)
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text(username)
                                .bold()
                            Spacer()
                        }
                        
                        WidgetInfoBox(content: rating, title: "Rating")
                        WidgetInfoBox(content: playCount, title: "游玩次数")
                    }
                    .padding(.leading)
                    
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Image(entry.configuration.currentMode == .chunithm ? "penguin" : "salt")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 85)
                                .shadow(radius: 3, x: 4, y: 4)
                        }
                    }
                }
            }
        }
        .onAppear {
            if entry.configuration.currentMode == .chunithm {
                rating = String(format: "%.2f", entry.chunithm.rating)
                username = transformingHalfwidthFullwidth(entry.chunithm.nickname)
                playCount = "\(entry.chunithm.playCount)"
                lastUpdate = toDateString(entry.chunithm.updatedAt, format: "MM-dd")
//                if let chu = entry.chuRecent {
//                    hasRecent = true
//                    cover = UserInfoFetcher.cachedChunithmCover
//                    title = chu.title
//                    score = String(chu.score)
//                }
            } else {
                rating = String(entry.maimai.rating)
                username = transformingHalfwidthFullwidth(entry.maimai.nickname)
                playCount = "\(entry.maimai.playCount)"
                lastUpdate = toDateString(entry.maimai.updatedAt, format: "MM-dd")
//                if let mai = entry.maiRecent {
//                    hasRecent = true
//                    cover = UserInfoFetcher.cachedMaimaiCover
//                    title = mai.title
//                    score = String(format: "%.4f", mai.score) + "%"
//                }
            }
        }
    }
    
    func toDateString(_ string: String, format: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFractionalSeconds, .withInternetDateTime, .withTimeZone]
        formatter.timeZone = .autoupdatingCurrent
        if let date = formatter.date(from: string) {
            let f = DateFormatter()
            f.dateFormat = "MM-dd"
            f.timeZone = .autoupdatingCurrent
            f.locale = .autoupdatingCurrent
            return f.string(from: date)
        }
        return ""
    }
    
    func transformingHalfwidthFullwidth(_ string: String) -> String {
        let str = NSMutableString(string: string)
        CFStringTransform(str, nil, kCFStringTransformFullwidthHalfwidth, false)
        return str as String
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
        .supportedFamilies([.systemMedium, .systemSmall])
    }
}

struct infoWidget_Previews: PreviewProvider {
    static var previews: some View {
        infoWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), maimai: Maimai.empty, chunithm: Chunithm.empty, error: ""))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

extension Color {
    init(red: Int, green: Int, blue: Int){
        self.init(red: Double(red) / 255, green: Double(green) / 255, blue: Double(blue) / 255)
    }
}
