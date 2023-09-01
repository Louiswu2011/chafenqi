//
//  WidgetPreviews.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/7/31.
//

import SwiftUI

fileprivate var nameplateChuniColorTop = Color(red: 254, green: 241, blue: 65)
fileprivate var nameplateChuniColorBottom = Color(red: 243, green: 200, blue: 48)

fileprivate var nameplateMaiColorTop = Color(red: 167, green: 243, blue: 254)
fileprivate var nameplateMaiColorBottom = Color(red: 93, green: 166, blue: 247)

struct WidgetMediumPreview: View {
    @Environment(\.managedObjectContext) var context
    
    var previewType: WidgetPreviewTypeOption
    @Binding var config: WidgetData.Customization
    var user: CFQNUser
    
    var body: some View {
        ZStack {
            WidgetPreviewBackground(previewType: previewType, config: $config, size: 0)
            WidgetPreviewCharacter(previewType: previewType, config: $config, size: 0)
            WidgetPreviewInfo(previewType: previewType, config: $config, size: 0, user: user)
        }
        .frame(width: 141, height: 141)
    }
}

struct WidgetLargePreview: View {
    @Environment(\.managedObjectContext) var context
    
    var previewType: WidgetPreviewTypeOption
    @Binding var config: WidgetData.Customization
    var user: CFQNUser
    
    var body: some View {
        ZStack {
            WidgetPreviewBackground(previewType: previewType, config: $config, size: 1)
            WidgetPreviewCharacter(previewType: previewType, config: $config, size: 1)
            WidgetPreviewInfo(previewType: previewType, config: $config, size: 1, user: user)
        }
        .frame(width: 305.5, height: 141)
    }
}

struct WidgetPreviewCharacter: View {
    @Environment(\.managedObjectContext) var context
    
    var previewType: WidgetPreviewTypeOption
    @Binding var config: WidgetData.Customization
    var size: Int
    
    var body: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                if previewType == .chunithm, let charUrlString = config.chuCharUrl, let charUrl = URL(string: charUrlString) {
                    AsyncImage(url: charUrl, context: context, placeholder: {
                        ProgressView()
                    }, image: { img in
                        Image(uiImage: img)
                            .resizable()
                    })
                    .aspectRatio(contentMode: .fit)
                    .mask(RoundedRectangle(cornerRadius: 5))
                    .frame(width: size == 0 ? 85 : 105)
                } else if previewType == .maimai, let charUrlString = config.maiCharUrl, let charUrl = URL(string: charUrlString) {
                    AsyncImage(url: charUrl, context: context, placeholder: {
                        ProgressView()
                    }, image: { img in
                        Image(uiImage: img)
                            .resizable()
                    })
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size == 0 ? 85 : 105)
                }
            }
        }
    }
}

struct WidgetPreviewInfo: View {
    @Environment(\.managedObjectContext) var context
    
    var previewType: WidgetPreviewTypeOption
    @Binding var config: WidgetData.Customization
    var size: Int
    var user: CFQNUser
    
    var body: some View {
        if size == 1 {
            VStack {
                HStack {
                    Text(previewType == .chunithm ? user.chunithm.info.nickname : user.maimai.info.nickname)
                        .bold()
                        .foregroundColor(previewType == .chunithm ? (config.darkModes[0] ? .white : .black) : (config.darkModes[2] ? .white : .black))
                    Spacer()
                }
                .padding([.top, .leading])
                
                HStack {
                    Group {
                        WidgetInfoBox(content: previewType == .chunithm ? String(format: "%.2f", user.chunithm.info.rating) : String(user.maimai.info.rating), title: "Rating")
                        WidgetInfoBox(content: previewType == .chunithm ? String(user.chunithm.info.playCount) : String(user.maimai.info.playCount), title: "游玩次数")
                        WidgetInfoBox(content: previewType == .chunithm ? toDateString(user.chunithm.info.updatedAt) : toDateString(user.maimai.info.updatedAt), title: "最近更新")
                    }
                    .foregroundColor(previewType == .chunithm ? (config.darkModes[0] ? .white : .black) : (config.darkModes[2] ? .white : .black))
                    Spacer()
                }
                .padding(.horizontal)
                Spacer()
            }
        } else {
            VStack(alignment: .leading) {
                HStack {
                    Text(previewType == .chunithm ? user.chunithm.info.nickname : user.maimai.info.nickname)
                        .bold()
                        .foregroundColor(previewType == .chunithm ? (config.darkModes[1] ? .white : .black) : (config.darkModes[3] ? .white : .black))
                    Spacer()
                }
                Group {
                    WidgetInfoBox(content: previewType == .chunithm ? String(format: "%.2f", user.chunithm.info.rating) : String(user.maimai.info.rating), title: "Rating")
                    WidgetInfoBox(content: previewType == .chunithm ? String(user.chunithm.info.playCount) : String(user.maimai.info.playCount), title: "游玩次数")
                }
                .foregroundColor(previewType == .chunithm ? (config.darkModes[1] ? .white : .black) : (config.darkModes[3] ? .white : .black))
            }
            .padding(.leading)
        }
    }
    
    func toDateString(_ string: String) -> String {
        let formatter = DateTool.shared.updateFormatter
        if let date = formatter.date(from: string) {
            let f = DateTool.shared.premiumTransformer
            return f.string(from: date)
        }
        return ""
    }
}

struct WidgetPreviewBackground: View {
    @Environment(\.managedObjectContext) var context
    
    var previewType: WidgetPreviewTypeOption
    @Binding var config: WidgetData.Customization
    var size: Int
    
    var body: some View {
        Group {
            if previewType == .chunithm {
                if let url = config.chuBgUrl, !url.isEmpty, size == 1 {
                    AsyncImage(url: URL(string: url)!, context: context, placeholder: {
                        ProgressView()
                    }, image: { image in
                        Image(uiImage: image)
                            .resizable()
                    })
                    .blur(radius: config.chuBgBlur ?? 0.0)
                    .aspectRatio(contentMode: .fit)
                } else if let colors = config.chuColor, !colors.isEmpty, size == 0 {
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
                    LinearGradient(colors: previewType == .chunithm ? [nameplateChuniColorTop, nameplateChuniColorBottom] : [nameplateMaiColorTop, nameplateMaiColorBottom], startPoint: .top, endPoint: .bottom)
                }
            } else if previewType == .maimai {
                if let url = config.maiBgUrl, !url.isEmpty, size == 1 {
                    AsyncImage(url: URL(string: url)!, context: context, placeholder: {
                        ProgressView()
                    }, image: { image in
                        Image(uiImage: image)
                            .resizable()
                    })
                    .blur(radius: config.maiBgBlur ?? 0.0)
                    .aspectRatio(contentMode: .fill)
                } else if let colors = config.maiColor, !colors.isEmpty, size == 0 {
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
                    LinearGradient(colors: previewType == .chunithm ? [nameplateChuniColorTop, nameplateChuniColorBottom] : [nameplateMaiColorTop, nameplateMaiColorBottom], startPoint: .top, endPoint: .bottom)
                }
            }
        }
        .frame(width: size == 0 ? 141 : 305.5, height: 141)
        .mask(RoundedRectangle(cornerRadius: 15))
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
