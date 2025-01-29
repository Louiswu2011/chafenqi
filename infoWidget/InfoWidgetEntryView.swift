//
//  InfoWidgetEntryView.swift
//  chafenqi
//
//  Created by xinyue on 2023/7/6.
//

import WidgetKit
import Intents
import SwiftUI

struct infoWidgetEntryView : View {
    @Environment(\.widgetFamily) var size
    var entry: Provider.Entry
    
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
                    let color: Color = entry.configuration.currentMode == .chunithm ? (entry.custom?.darkModes[0] ?? false ? .white : .black) : (entry.custom?.darkModes[2] ?? false ? .white : .black)
                    
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Group {
                                if entry.custom != nil {
                                    if entry.configuration.currentMode == .chunithm {
                                        if let image = UIImage(data: entry.chuChar) {
                                            Image(uiImage: image)
                                                .resizable()
                                        } else {
                                            Image("penguin")
                                                .resizable()
                                        }
                                    } else {
                                        if let image = UIImage(data: entry.maiChar) {
                                            Image(uiImage: image)
                                                .resizable()
                                        } else {
                                            Image("salt")
                                                .resizable()
                                        }
                                    }
                                } else {
                                    Image(entry.configuration.currentMode == .chunithm ? "penguin" : "salt")
                                        .resizable()
                                }
                            }
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 105)
                        }
                    }
                    
                    VStack {
                        HStack {
                            Text(username)
                                .bold()
                                .foregroundColor(color)
                            Spacer()
                        }
                        .padding([.top, .leading])
                        
                        HStack {
                            WidgetInfoBox(content: rating, title: "Rating")
                                .foregroundColor(color)
                            WidgetInfoBox(content: playCount, title: "游玩次数")
                                .foregroundColor(color)
                            WidgetInfoBox(content: lastUpdate, title: "最近更新")
                                .foregroundColor(color)
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
                                        .foregroundColor(color)
                                    Text(score)
                                        .bold()
                                        .font(.system(size: 15))
                                        .foregroundColor(color)
                                }
                                Spacer()
                            }
                            .frame(height: 40)
                            .padding([.leading])
                            .padding(.top, 7)
                        }
                        Spacer()
                    }
                } else if size == .systemSmall {
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Group {
                                if entry.custom != nil {
                                    if entry.configuration.currentMode == .chunithm {
                                        if let image = UIImage(data: entry.chuChar) {
                                            Image(uiImage: image)
                                                .resizable()
                                        } else {
                                            Image("penguin")
                                                .resizable()
                                        }
                                    } else {
                                        if let image = UIImage(data: entry.maiChar) {
                                            Image(uiImage: image)
                                                .resizable()
                                        } else {
                                            Image("salt")
                                                .resizable()
                                        }
                                    }
                                } else {
                                    Image(entry.configuration.currentMode == .chunithm ? "penguin" : "salt")
                                        .resizable()
                                }
                            }
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 85)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        HStack {
                            if let custom = entry.custom {
                                Text(username)
                                    .bold()
                                    .foregroundColor(entry.configuration.currentMode == .chunithm ? (custom.darkModes[1] ? .white : .black) : (custom.darkModes[3] ? .white : .black))
                            } else {
                                Text(username)
                                    .bold()
                            }
                            Spacer()
                        }
                        
                        if let custom = entry.custom {
                            Group {
                                WidgetInfoBox(content: rating, title: "Rating")
                                WidgetInfoBox(content: playCount, title: "游玩次数")
                            }
                            .foregroundColor(entry.configuration.currentMode == .chunithm ? (custom.darkModes[1] ? .white : .black) : (custom.darkModes[3] ? .white : .black))
                        } else {
                            WidgetInfoBox(content: rating, title: "Rating")
                            WidgetInfoBox(content: playCount, title: "游玩次数")
                        }
                    }
                    .padding(.leading)
                }
            }
        }
        .onAppear {
            if entry.configuration.currentMode == .chunithm {
                if let chunithm = entry.chunithm {
                    rating = String(format: "%.2f", chunithm.rating)
                    username = transformingHalfwidthFullwidth(chunithm.nickname)
                    playCount = "\(chunithm.playCount)"
                    lastUpdate = toDateString(TimeInterval(chunithm.timestamp))
                    if let chu = entry.chuRecentOne {
                        hasRecent = true
                        cover = UIImage(data: entry.chuCover) ?? UIImage()
                        title = chu.associatedSong?.title ?? ""
                        score = String(chu.score)
                    }
                }
            } else {
                if let maimai = entry.maimai {
                    rating = String(maimai.rating)
                    username = transformingHalfwidthFullwidth(maimai.nickname)
                    playCount = "\(maimai.playCount)"
                    lastUpdate = toDateString(TimeInterval(maimai.timestamp))
                    if let mai = entry.maiRecentOne {
                        hasRecent = true
                        cover = UIImage(data: entry.maiCover) ?? UIImage()
                        title = mai.associatedSong?.title ?? ""
                        score = String(format: "%.4f", mai.achievements) + "%"
                    }
                }
            }
        }
        .widgetBackground(WidgetBackgroundView(entry: entry))
    }
    
    func toDateString(_ epoch: TimeInterval) -> String {
        let f = DateTool.shared.premiumTransformer
        return f.string(from: Date(timeIntervalSince1970: epoch))
    }
    
    func transformingHalfwidthFullwidth(_ string: String) -> String {
        let str = NSMutableString(string: string)
        CFStringTransform(str, nil, kCFStringTransformFullwidthHalfwidth, false)
        return str as String
    }
}

struct WidgetBackgroundView: View {
    var entry: Provider.Entry
    
    var nameplateChuniColorTop = Color(red: 254, green: 241, blue: 65)
    var nameplateChuniColorBottom = Color(red: 243, green: 200, blue: 48)
    
    var nameplateMaiColorTop = Color(red: 167, green: 243, blue: 254)
    var nameplateMaiColorBottom = Color(red: 93, green: 166, blue: 247)
    
    @Environment(\.widgetFamily) var size
    
    var body: some View {
        if size == .systemMedium {
            if let custom = entry.custom {
                let bg = entry.configuration.currentMode == .chunithm ? entry.chuBg : entry.maiBg
                if let image = UIImage(data: bg) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .blur(radius: entry.configuration.currentMode == .chunithm ? custom.chuBgBlur ?? 0.0 : custom.maiBgBlur ?? 0.0)
                } else {
                    LinearGradient(colors: entry.configuration.currentMode == .chunithm ? [nameplateChuniColorTop, nameplateChuniColorBottom] : [nameplateMaiColorTop, nameplateMaiColorBottom], startPoint: .top, endPoint: .bottom)
                }
            } else {
                LinearGradient(colors: entry.configuration.currentMode == .chunithm ? [nameplateChuniColorTop, nameplateChuniColorBottom] : [nameplateMaiColorTop, nameplateMaiColorBottom], startPoint: .top, endPoint: .bottom)
            }
        } else if size == .systemSmall {
            if let custom = entry.custom, let colors = entry.configuration.currentMode == .chunithm ? custom.chuColor : custom.maiColor {
                LinearGradient(
                    colors:
                        [Color(red: Double(colors.first?[0] ?? 0),
                               green: Double(colors.first?[1] ?? 0),
                               blue: Double(colors.first?[2] ?? 0),
                               opacity: Double(colors.first?[3] ?? 0)),
                         Color(red: Double(colors.last?[0] ?? 0),
                               green: Double(colors.last?[1] ?? 0),
                               blue: Double(colors.last?[2] ?? 0),
                               opacity: Double(colors.last?[3] ?? 0))],
                    startPoint: .top,
                    endPoint: .bottom)
            } else {
                LinearGradient(colors: entry.configuration.currentMode == .chunithm ? [nameplateChuniColorTop, nameplateChuniColorBottom] : [nameplateMaiColorTop, nameplateMaiColorBottom], startPoint: .top, endPoint: .bottom)
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

extension View {
    func widgetBackground(_ backgroundView: some View) -> some View {
            if #available(iOSApplicationExtension 17.0, *) {
                return containerBackground(for: .widget) {
                    backgroundView
                }
            } else {
                return background(backgroundView)
            }
        }
}
