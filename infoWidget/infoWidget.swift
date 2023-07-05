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

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
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
    var error: String
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
                VStack {
                    Text("error: \(entry.error)")
                    Text("isPremium: \(entry.isPremium ? "yes" : "no")")
                    Text("game: \(entry.maimai != nil ? "yes" : "no"), \(entry.chunithm != nil ? "yes" : "no")")
                    Text("recent: \(entry.maiRecentOne != nil ? "yes" : "no"), \(entry.chuRecentOne != nil ? "yes" : "no")")
                    Text("cover: \(entry.maiCover.count), \(entry.chuCover.count)")
                }
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
                        
                        if hasRecent {
                            HStack {
                                Image(uiImage: cover)
                                    .resizable()
                                    .aspectRatio(1, contentMode: .fit)
                                    .frame(width: 40)
                                    .mask(RoundedRectangle(cornerRadius: 5))
                                    .shadow(radius: 2, x: 2, y: 2)

                                VStack(alignment: .leading) {
                                    Text(title)
                                        .frame(maxWidth: 160, alignment: .leading)
                                        .lineLimit(1)
                                        .font(.system(size: 13))
                                    Text(score)
                                        .bold()
                                        .font(.system(size: 15))
                                }
                                Spacer()
                            }
                            .frame(height: 40)
                            .padding([.leading])
                            .padding(.top, 7)
                        }
                        
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
                if let chunithm = entry.chunithm {
                    rating = String(format: "%.2f", chunithm.rating)
                    username = transformingHalfwidthFullwidth(chunithm.nickname)
                    playCount = "\(chunithm.playCount)"
                    lastUpdate = toDateString(chunithm.updatedAt, format: "MM-dd")
                    if let chu = entry.chuRecentOne {
                        hasRecent = true
                        cover = UIImage(data: entry.chuCover) ?? UIImage()
                        title = chu.title
                        score = String(chu.score)
                    }
                }
            } else {
                if let maimai = entry.maimai {
                    rating = String(maimai.rating)
                    username = transformingHalfwidthFullwidth(maimai.nickname)
                    playCount = "\(maimai.playCount)"
                    lastUpdate = toDateString(maimai.updatedAt, format: "MM-dd")
                    if let mai = entry.maiRecentOne {
                        hasRecent = true
                        cover = UIImage(data: entry.maiCover) ?? UIImage()
                        title = mai.title
                        score = String(format: "%.4f", mai.score) + "%"
                    }
                }
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
        infoWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent(), error: ""))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}

extension Color {
    init(red: Int, green: Int, blue: Int){
        self.init(red: Double(red) / 255, green: Double(green) / 255, blue: Double(blue) / 255)
    }
}
