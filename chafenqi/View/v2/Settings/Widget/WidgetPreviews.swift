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
    
    var body: some View {
        ZStack {
            WidgetPreviewBackground(previewType: previewType, config: $config, size: 0)
        }
        .frame(width: 141, height: 141)
    }
}

struct WidgetLargePreview: View {
    @Environment(\.managedObjectContext) var context
    
    var previewType: WidgetPreviewTypeOption
    @Binding var config: WidgetData.Customization
    
    var body: some View {
        ZStack {
            WidgetPreviewBackground(previewType: previewType, config: $config, size: 1)
        }
        .frame(width: 305.5, height: 141)
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
                if !(config.chuBgUrl ?? "").isEmpty && size == 1 {
                    AsyncImage(url: URL(string: config.chuBgUrl!)!, context: context, placeholder: {
                        ProgressView()
                    }, image: { image in
                        Image(uiImage: image)
                            .resizable()
                    })
                    .blur(radius: config.chuBgBlur ?? 0.0)
                    .aspectRatio(contentMode: .fill)
                } else if !(config.chuColor ?? []).isEmpty && size == 0 {
                    if let colors = config.chuColor {
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
                    }
                } else {
                    LinearGradient(colors: previewType == .chunithm ? [nameplateChuniColorTop, nameplateChuniColorBottom] : [nameplateMaiColorTop, nameplateMaiColorBottom], startPoint: .top, endPoint: .bottom)
                }
            } else if previewType == .maimai {
                if !(config.maiBgUrl ?? "").isEmpty && size == 1 {
                    AsyncImage(url: URL(string: config.maiBgUrl!)!, context: context, placeholder: {
                        ProgressView()
                    }, image: { image in
                        Image(uiImage: image)
                            .resizable()
                    })
                    .blur(radius: config.maiBgBlur ?? 0.0)
                    .aspectRatio(contentMode: .fill)
                } else if !(config.maiColor ?? []).isEmpty && size == 0 {
                    if let colors = config.maiColor {
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
                    }
                } else {
                    LinearGradient(colors: previewType == .chunithm ? [nameplateChuniColorTop, nameplateChuniColorBottom] : [nameplateMaiColorTop, nameplateMaiColorBottom], startPoint: .top, endPoint: .bottom)
                }
            }
        }
        .frame(width: size == 0 ? 141 : 305.5, height: 141)
        .mask(RoundedRectangle(cornerRadius: 15))
    }
}

