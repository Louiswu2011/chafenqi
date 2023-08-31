//
//  WidgetOptionPickers.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/7/31.
//

import SwiftUI

struct WidgetMediumBgPicker: View {
    @ObservedObject var user: CFQNUser
    
    @Binding var currentPreviewType: WidgetPreviewTypeOption
    @Binding var maiMediumBackground: WidgetMediumBackgroundOption
    @Binding var chuMediumBackground: WidgetMediumBackgroundOption
    
    @Binding var maiBgColor: Color
    @State private var maiGradientStartColor = Color(white: 0)
    @State private var maiGradientStopColor = Color(white: 0)
    
    @Binding var chuBgColor: Color
    @State private var chuGradientStartColor = Color(white: 0)
    @State private var chuGradientStopColor = Color(white: 0)
    
    @Binding var currentWidgetSettings: WidgetData.Customization
    
    var body: some View {
        Picker("背景", selection: currentPreviewType == .maimai ? $maiMediumBackground : $chuMediumBackground) {
            ForEach(WidgetMediumBackgroundOption.allCases) { value in
                Text(value.rawValue)
                    .tag(value)
            }
        }
        if currentPreviewType == .maimai {
            if maiMediumBackground == .color {
                ColorPicker(selection: $maiBgColor) {
                    Text("填充色")
                }
                .onChange(of: maiBgColor) { color in
                    currentWidgetSettings.maiColor = [color.cgColor!.components!]
                }
            } else if maiMediumBackground == .gradient {
                ColorPicker(selection: $maiGradientStartColor) {
                    Text("顶部颜色")
                }
                .onChange(of: maiGradientStartColor) { color in
                    currentWidgetSettings.maiColor = [color.cgColor!.components!, maiGradientStopColor.cgColor!.components!]
                }
                ColorPicker(selection: $maiGradientStopColor) {
                    Text("底部颜色")
                }
                .onChange(of: maiGradientStopColor) { color in
                    currentWidgetSettings.maiColor = [maiGradientStartColor.cgColor!.components!, color.cgColor!.components!]
                }
            }
        } else if currentPreviewType == .chunithm {
            if chuMediumBackground == .color {
                ColorPicker(selection: $chuBgColor) {
                    Text("填充色")
                }
                .onChange(of: chuBgColor) { color in
                    currentWidgetSettings.chuColor = [color.cgColor!.components!]
                }
            } else if chuMediumBackground == .gradient {
                ColorPicker(selection: $chuGradientStartColor) {
                    Text("顶部颜色")
                }
                .onChange(of: chuGradientStartColor) { color in
                    currentWidgetSettings.chuColor = [color.cgColor!.components!, chuGradientStopColor.cgColor!.components!]
                }
                ColorPicker(selection: $chuGradientStopColor) {
                    Text("底部颜色")
                }
                .onChange(of: chuGradientStopColor) { color in
                    currentWidgetSettings.chuColor = [chuGradientStartColor.cgColor!.components!, color.cgColor!.components!]
                }
            }
        }
    }
}

struct WidgetLargeBgPicker: View {
    @ObservedObject var user: CFQNUser
    
    @Binding var currentPreviewType: WidgetPreviewTypeOption
    @Binding var maiBackground: WidgetBackgroundOption
    @Binding var chuBackground: WidgetBackgroundOption
    @Binding var selectedChuBg: CFQData.Chunithm.ExtraEntry.NameplateEntry?
    @Binding var selectedMaiBg: CFQData.Maimai.ExtraEntry.FrameEntry?
    
    @State var maiBgBlur: Double = 0.0
    @State var chuBgBlur: Double = 0.0
    
    let blurUpperbound = 10.0
    
    @Binding var currentWidgetSettings: WidgetData.Customization
    
    var body: some View {
        Picker("背景", selection: currentPreviewType == .maimai ? $maiBackground : $chuBackground) {
            ForEach(WidgetBackgroundOption.allCases) { value in
                Text(value.rawValue)
                    .tag(value)
            }
        }
        .onChange(of: maiBackground) { newValue in
            if newValue == .defaultBg {
                currentWidgetSettings.maiBgUrl = ""
            } else if newValue == .plate {
                currentWidgetSettings.maiBgUrl = user.maimai.extra.frames.first { $0.selected == 1 }?.image
            }
        }
        .onChange(of: chuBackground) { newValue in
            if newValue == .defaultBg {
                currentWidgetSettings.chuBgUrl = ""
            } else if newValue == .plate {
                currentWidgetSettings.chuBgUrl = user.chunithm.extra.nameplates.first { $0.current == 1 }?.url
            }
        }
        if currentPreviewType == .maimai && maiBackground == .custom {
            NavigationLink {
                WidgetBgCustomSelectionView(availableMaiBgs: user.maimai.extra.frames, selectedChuBg: $selectedChuBg, selectedMaiBg: $selectedMaiBg)
            } label: {
                HStack {
                    Text("选择背景...")
                    Spacer()
                    Text("\(selectedMaiBg?.name ?? "")")
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            .onChange(of: selectedMaiBg) { bg in
                if let selected = bg {
                    currentWidgetSettings.maiBgUrl = selected.image
                }
            }
        } else if currentPreviewType == .chunithm && chuBackground == .custom {
            NavigationLink {
                WidgetBgCustomSelectionView(availableChuBgs: user.chunithm.extra.nameplates, selectedChuBg: $selectedChuBg, selectedMaiBg: $selectedMaiBg)
            } label: {
                HStack {
                    Text("选择背景...")
                    Spacer()
                    Text("\(selectedChuBg?.name ?? "")")
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
            .onChange(of: selectedChuBg) { bg in
                if let selected = bg {
                    currentWidgetSettings.chuBgUrl = selected.url
                }
            }
        }
        if currentPreviewType == .maimai && maiBackground != .defaultBg {
            HStack {
                Text("模糊度")
                Spacer()
                Slider(value: $maiBgBlur, in: 0.0...blurUpperbound)
            }
            .onAppear {
                maiBgBlur = currentWidgetSettings.maiBgBlur ?? 0.0
            }
            .onChange(of: maiBgBlur) { newValue in
                currentWidgetSettings.maiBgBlur = newValue
            }
        } else if currentPreviewType == .chunithm && chuBackground != .defaultBg {
            HStack {
                Text("模糊度")
                Spacer()
                Slider(value: $chuBgBlur, in: 0.0...blurUpperbound)
            }
            .onAppear {
                chuBgBlur = currentWidgetSettings.chuBgBlur ?? 0.0
            }
            .onChange(of: chuBgBlur) { newValue in
                currentWidgetSettings.chuBgBlur = newValue
            }
        }
    }
}

struct WidgetCharPicker: View {
    @ObservedObject var user: CFQNUser
    
    @Binding var currentPreviewType: WidgetPreviewTypeOption
    @Binding var maiChar: WidgetCharacterOption
    @Binding var chuChar: WidgetCharacterOption
    @Binding var selectedMaiChar: CFQData.Maimai.ExtraEntry.CharacterEntry?
    @Binding var selectedChuChar: CFQData.Chunithm.ExtraEntry.CharacterEntry?
    
    @Binding var currentWidgetSettings: WidgetData.Customization
    
    var body: some View {
        Picker("人物", selection: currentPreviewType == .maimai ? $maiChar : $chuChar) {
            ForEach(WidgetCharacterOption.allCases) { value in
                Text(value.rawValue)
                    .tag(value)
            }
        }
        .onChange(of: maiChar) { newValue in
            if newValue == .defaultChar {
                currentWidgetSettings.maiCharUrl = ""
            } else if newValue == .captain {
                currentWidgetSettings.maiCharUrl = user.maimai.info.charUrl
            }
        }
        .onChange(of: chuChar) { newValue in
            if newValue == .defaultChar {
                currentWidgetSettings.chuCharUrl = ""
            } else if newValue == .captain {
                currentWidgetSettings.chuCharUrl = user.chunithm.info.charUrl
            }
        }
        .onChange(of: selectedMaiChar) { char in
            if let selected = char {
                currentWidgetSettings.maiCharUrl = selected.image
            }
        }
        .onChange(of: selectedChuChar) { char in
            if let selected = char {
                currentWidgetSettings.chuCharUrl = selected.url
            }
        }
        if currentPreviewType == .maimai && maiChar == .custom {
            NavigationLink {
                WidgetCharCustomSelectionView(availableMaiChars: user.maimai.extra.characters, selectedChuChar: $selectedChuChar, selectedMaiChar: $selectedMaiChar)
            } label: {
                HStack {
                    Text("选择人物...")
                    Spacer()
                    Text("\(selectedMaiChar?.name ?? "")")
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
        } else if currentPreviewType == .chunithm && chuChar == .custom {
            NavigationLink {
                WidgetCharCustomSelectionView(availableChuChars: user.chunithm.extra.characters, selectedChuChar: $selectedChuChar, selectedMaiChar: $selectedMaiChar)
            } label: {
                HStack {
                    Text("选择人物...")
                    Spacer()
                    Text("\(selectedChuChar?.name ?? "")")
                        .foregroundColor(.gray)
                        .lineLimit(1)
                }
            }
        }
    }
}
