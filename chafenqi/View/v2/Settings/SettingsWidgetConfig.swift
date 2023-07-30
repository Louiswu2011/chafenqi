//
//  SettingsWidgetConfig.swift
//  chafenqi
//
//  Created by xinyue on 2023/7/5.
//

import SwiftUI
import CoreData

fileprivate enum WidgetBackgroundOption: String, CaseIterable, Identifiable, Hashable {
    var id: Self {
        return self
    }
    
    case plate = "当前背景版"
    case custom = "自定义"
    case defaultBg = "默认"
}

fileprivate enum WidgetCharacterOption: String, CaseIterable, Identifiable, Hashable {
    var id: Self {
        return self
    }
    
    case captain = "当前队长/角色"
    case custom = "自定义"
    case defaultChar = "默认"
}

fileprivate enum WidgetPreviewTypeOption: String, CaseIterable, Identifiable, Hashable {
    var id : Self {
        return self
    }
    
    case chunithm = "中二节奏NEW"
    case maimai = "舞萌DX"
}

struct SettingsWidgetConfig: View {
    @ObservedObject var user: CFQNUser
    
    @State private var didLoad = false
    @State private var customization = true
    
    @State private var maiBackground: WidgetBackgroundOption = .defaultBg
    @State private var chuBackground: WidgetBackgroundOption = .defaultBg
    
    @State private var maiChar: WidgetCharacterOption = .defaultChar
    @State private var chuChar: WidgetCharacterOption = .defaultChar
    
    @State private var selectedChuBg: CFQData.Chunithm.ExtraEntry.NameplateEntry?
    @State private var selectedMaiBg: CFQData.Maimai.ExtraEntry.FrameEntry?
    
    @State private var selectedMaiChar: CFQData.Maimai.ExtraEntry.CharacterEntry?
    @State private var selectedChuChar: CFQData.Chunithm.ExtraEntry.CharacterEntry?
    
    @State private var currentPreivewType: WidgetPreviewTypeOption = .maimai
    
    @State var currentWidgetSettings = WidgetData.Customization()

    var body: some View {
        Form {
            Section {
                Toggle(isOn: $customization.animation()) {
                    Text("自定义小组件")
                }
            }

            if customization {
                Section {
                    Picker("预览类型", selection: $currentPreivewType) {
                        ForEach(WidgetPreviewTypeOption.allCases) { value in
                            Text(value.rawValue)
                                .tag(value)
                        }
                    }
                    .pickerStyle(.segmented)

                    VStack(alignment: .center) {
                        // Preview
                        TabView {
                            WidgetMediumPreview(previewType: currentPreivewType, config: $currentWidgetSettings)

                            WidgetLargePreview(previewType: currentPreivewType, config: $currentWidgetSettings)
                        }
                        .tabViewStyle(.page(indexDisplayMode: .automatic))
                    }
                    .frame(height: 190)

                    Picker("背景", selection: currentPreivewType == .maimai ? $maiBackground : $chuBackground) {
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
                    .onChange(of: selectedMaiBg) { bg in
                        if let selected = bg {
                            currentWidgetSettings.maiBgUrl = selected.image
                        }
                    }
                    .onChange(of: selectedChuBg) { bg in
                        if let selected = bg {
                            currentWidgetSettings.chuBgUrl = selected.url
                        }
                    }
                    if currentPreivewType == .maimai && maiBackground == .custom {
                        NavigationLink {
                            WidgetBgCustomSelectionView(availableMaiBgs: user.maimai.extra.frames, selectedChuBg: $selectedChuBg, selectedMaiBg: $selectedMaiBg)
                        } label: {
                            HStack {
                                Text("选择背景...")
                                Spacer()
                                Text("\(selectedMaiBg?.name ?? "")")
                                    .foregroundColor(.gray)
                            }
                        }
                    } else if currentPreivewType == .chunithm && chuBackground == .custom {
                        NavigationLink {
                            WidgetBgCustomSelectionView(availableChuBgs: user.chunithm.extra.nameplates, selectedChuBg: $selectedChuBg, selectedMaiBg: $selectedMaiBg)
                        } label: {
                            HStack {
                                Text("选择背景...")
                                Spacer()
                                Text("\(selectedChuBg?.name ?? "")")
                                    .foregroundColor(.gray)
                            }
                        }
                    }


                    Picker("人物", selection: currentPreivewType == .maimai ? $maiChar : $chuChar) {
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
                    if currentPreivewType == .maimai && maiChar == .custom {
                        NavigationLink {
                            WidgetCharCustomSelectionView(availableMaiChars: user.maimai.extra.characters, selectedChuChar: $selectedChuChar, selectedMaiChar: $selectedMaiChar)
                        } label: {
                            HStack {
                                Text("选择人物...")
                                Spacer()
                                Text("\(selectedMaiChar?.name ?? "")")
                                    .foregroundColor(.gray)
                            }
                        }
                    } else if currentPreivewType == .chunithm && chuChar == .custom {
                        NavigationLink {
                            WidgetCharCustomSelectionView(availableChuChars: user.chunithm.extra.characters, selectedChuChar: $selectedChuChar, selectedMaiChar: $selectedMaiChar)
                        } label: {
                            HStack {
                                Text("选择人物...")
                                Spacer()
                                Text("\(selectedChuChar?.name ?? "")")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }

                Section {
                    NavigationLink {

                    } label: {
                        Text("排序")
                    }
                } header: {
                    Text("2x2")
                }

                Section {
                    NavigationLink {

                    } label: {
                        Text("排序")
                    }
                } header: {
                    Text("2x4")
                }
            }
        }
        .onAppear {
            guard !didLoad else { return }
            do {
                currentWidgetSettings = try JSONDecoder().decode(WidgetData.Customization.self, from: user.widgetCustom)
            } catch {
                currentWidgetSettings = WidgetData.Customization()
            }
            didLoad = true
        }
        .navigationTitle("小组件")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func makeSettings() {
        var config = WidgetData.Customization()
        if user.maimai.isNotEmpty {
            switch maiBackground {
            case .plate:
                config.maiBgUrl = user.maimai.extra.frames.first { $0.selected == 1 }?.image
            case .custom:
                config.maiBgUrl = selectedMaiBg?.image
            case .defaultBg:
                config.maiBgUrl = ""
            }
            switch maiChar {
            case .captain:
                config.maiCharUrl = user.maimai.extra.characters.first { $0.selected == 1 }?.image
            case .custom:
                config.maiCharUrl = selectedMaiChar?.image
            case .defaultChar:
                config.maiCharUrl = ""
            }
        }
        if user.chunithm.isNotEmpty {
            switch chuBackground {
            case .plate:
                config.chuBgUrl = user.chunithm.extra.nameplates.first { $0.current == 1 }?.url
            case .custom:
                config.chuBgUrl = selectedChuBg?.url
            case .defaultBg:
                config.chuBgUrl = ""
            }
            switch chuChar {
            case .captain:
                config.chuCharUrl = user.chunithm.extra.nameplates.first { $0.current == 1 }?.url
            case .custom:
                config.chuCharUrl = selectedChuChar?.url
            case .defaultChar:
                config.chuCharUrl = ""
            }
        }
        currentWidgetSettings = config
    }
    
    func loadSettings() {
        
    }
    
    func saveSettings() {
        
    }
}

fileprivate var nameplateChuniColorTop = Color(red: 254, green: 241, blue: 65)
fileprivate var nameplateChuniColorBottom = Color(red: 243, green: 200, blue: 48)

fileprivate var nameplateMaiColorTop = Color(red: 167, green: 243, blue: 254)
fileprivate var nameplateMaiColorBottom = Color(red: 93, green: 166, blue: 247)

struct WidgetMediumPreview: View {
    @Environment(\.managedObjectContext) var context
    
    fileprivate var previewType: WidgetPreviewTypeOption
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
    
    fileprivate var previewType: WidgetPreviewTypeOption
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
    
    fileprivate var previewType: WidgetPreviewTypeOption
    @Binding var config: WidgetData.Customization
    var size: Int
    
    var body: some View {
        if previewType == .chunithm && !(config.chuBgUrl ?? "").isEmpty {
            AsyncImage(url: URL(string: config.chuBgUrl!)!, context: context, placeholder: {
                ProgressView()
            }, image: { image in
                Image(uiImage: image)
                    .resizable()
            })
            .aspectRatio(contentMode: .fill)
            .frame(width: size == 0 ? 141 : 305.5, height: 141)
            .mask(RoundedRectangle(cornerRadius: 15))
        } else if previewType == .maimai && !(config.maiBgUrl ?? "").isEmpty {
            AsyncImage(url: URL(string: config.maiBgUrl!)!, context: context, placeholder: {
                ProgressView()
            }, image: { image in
                Image(uiImage: image)
                    .resizable()
            })
            .aspectRatio(contentMode: .fill)
            .frame(width: size == 0 ? 141 : 305.5, height: 141)
            .mask(RoundedRectangle(cornerRadius: 15))
        } else {
            LinearGradient(colors: previewType == .chunithm ? [nameplateChuniColorTop, nameplateChuniColorBottom] : [nameplateMaiColorTop, nameplateMaiColorBottom], startPoint: .top, endPoint: .bottom)
                .mask(RoundedRectangle(cornerRadius: 15))
        }
        
        
    }
}

struct WidgetBgCustomSelectionView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.presentationMode) var presentationMode
    
    var availableChuBgs: [CFQData.Chunithm.ExtraEntry.NameplateEntry]? = nil
    var availableMaiBgs: [CFQData.Maimai.ExtraEntry.FrameEntry]? = nil
    
    @Binding var selectedChuBg: CFQData.Chunithm.ExtraEntry.NameplateEntry?
    @Binding var selectedMaiBg: CFQData.Maimai.ExtraEntry.FrameEntry?
    
    var body: some View {
        Form {
            if let entries = availableChuBgs {
                ForEach(entries, id: \.url) { nameplate in
                    HStack {
                        Spacer()
                        VStack(alignment: .center) {
                            AsyncImage(url: URL(string: nameplate.url)!, context: context, placeholder: {
                                ProgressView()
                            }, image: { img in
                                Image(uiImage: img)
                                    .resizable()
                            })
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 60)
                            Text(nameplate.name)
                                .bold()
                        }
                        Spacer()
                    }
                    .onTapGesture {
                        selectedChuBg = nameplate
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            } else if let entries = availableMaiBgs {
                ForEach(entries, id: \.image) { frame in
                    VStack {
                        AsyncImage(url: URL(string: frame.image)!, context: context, placeholder: {
                            ProgressView()
                        }, image: { img in
                            Image(uiImage: img)
                                .resizable()
                        })
                        .aspectRatio(contentMode: .fit)
                        Text(frame.name)
                            .bold()
                        Text(frame.description)
                    }
                    .onTapGesture {
                        selectedMaiBg = frame
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct WidgetCharCustomSelectionView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.presentationMode) var presentationMode
    
    var availableChuChars: [CFQData.Chunithm.ExtraEntry.CharacterEntry]?
    var availableMaiChars: [CFQData.Maimai.ExtraEntry.CharacterEntry]?
    
    @Binding var selectedChuChar: CFQData.Chunithm.ExtraEntry.CharacterEntry?
    @Binding var selectedMaiChar: CFQData.Maimai.ExtraEntry.CharacterEntry?
    
    var body: some View {
        Form {
            if let entries = availableChuChars {
                ForEach(entries, id: \.name) { character in
                    HStack {
                        AsyncImage(url: URL(string: character.url)!, context: context, placeholder: {
                            ProgressView()
                        }, image: { img in
                            Image(uiImage: img)
                                .resizable()
                        })
                        .aspectRatio(1 ,contentMode: .fit)
                        .mask(RoundedRectangle(cornerRadius: 5))
                        .frame(width: 50)
                        
                        VStack {
                            HStack {
                                Text(character.name)
                                    .lineLimit(1)
                                Spacer()
                                if character.current == 1 {
                                    Text("当前角色")
                                        .bold()
                                }
                                Text("LV \(character.rank)")
                            }
                            Spacer()
                            ProgressView(value: character.exp)
                        }
                        .padding(.vertical, 5)
                    }
                    .frame(height: 60)
                    .onTapGesture {
                        selectedChuChar = character
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            } else if let entries = availableMaiChars {
                ForEach(entries, id: \.image) { char in
                    HStack {
                        AsyncImage(url: URL(string: char.image)!, context: context, placeholder: {
                            ProgressView()
                        }, image: { img in
                            Image(uiImage: img)
                                .resizable()
                        })
                        .aspectRatio(contentMode: .fit)
                        .mask(RoundedRectangle(cornerRadius: 5))
                        .frame(width: 60, height: 60)
                        VStack {
                            HStack {
                                Text(char.name)
                                    .bold()
                                Spacer()
                                Text(char.level)
                            }
                        }
                    }
                    .onTapGesture {
                        selectedMaiChar = char
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct SettingsWidgetConfig_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsWidgetConfig(user: CFQNUser())
        }
    }
}
