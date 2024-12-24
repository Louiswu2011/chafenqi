//
//  SettingsWidgetConfig.swift
//  chafenqi
//
//  Created by xinyue on 2023/7/5.
//

import SwiftUI
import CoreData
import WidgetKit

enum WidgetBackgroundOption: String, CaseIterable, Identifiable, Hashable {
    var id: Self {
        return self
    }
    
    case plate = "当前背景版"
    case custom = "自定义"
    case defaultBg = "默认"
}

enum WidgetMediumBackgroundOption: String, CaseIterable, Identifiable, Hashable {
    var id: Self {
        return self
    }
    
    case defaultBg = "默认"
    case gradient = "渐变色"
    case color = "纯色"
}

enum WidgetCharacterOption: String, CaseIterable, Identifiable, Hashable {
    var id: Self {
        return self
    }
    
    case captain = "当前队长/角色"
    case custom = "自定义"
    case defaultChar = "默认"
}

enum WidgetPreviewTypeOption: String, CaseIterable, Identifiable, Hashable {
    var id : Self {
        return self
    }
    
    case chunithm = "中二节奏NEW"
    case maimai = "舞萌DX"
}

enum WidgetPreviewSizeOption: CaseIterable, Identifiable, Hashable {
    var id: Self {
        return self
    }
    
    case medium
    case large
}

struct SettingsWidgetConfig: View {
    @ObservedObject var user: CFQNUser
    
    @State private var didLoad = false
    @State private var customization = true
    @State private var didChange = false
    
    @State private var maiBackground: WidgetBackgroundOption = .defaultBg
    @State private var chuBackground: WidgetBackgroundOption = .defaultBg
    @State private var maiMediumBackground: WidgetMediumBackgroundOption = .defaultBg
    @State private var chuMediumBackground: WidgetMediumBackgroundOption = .defaultBg
    
    @State private var maiBgColor: Color = Color(red: 0, green: 0, blue: 0)
    @State private var maiBgGradient: LinearGradient = LinearGradient(colors: [], startPoint: .top, endPoint: .bottom)
    
    @State private var chuBgColor: Color = Color(red: 0, green: 0, blue: 0)
    @State private var chuBgGradient: LinearGradient = LinearGradient(colors: [], startPoint: .top, endPoint: .bottom)
    
    @State private var maiChar: WidgetCharacterOption = .defaultChar
    @State private var chuChar: WidgetCharacterOption = .defaultChar
    
    @State private var selectedChuBg: UserChunithmNameplateEntry?
    @State private var selectedMaiBg: UserMaimaiFrameEntry?
    
    @State private var selectedMaiChar: UserMaimaiCharacterEntry?
    @State private var selectedChuChar: UserChunithmCharacterEntry?
    
    @State private var currentPreviewType: WidgetPreviewTypeOption = .maimai
    @State private var currentPreviewSize: WidgetPreviewSizeOption = .medium
    
    @Binding var currentWidgetSettings: WidgetData.Customization
    
    var body: some View {
        Form {
            Section {
                Toggle(isOn: $customization.animation()) {
                    Text("自定义小组件")
                }
            }
            
            if customization && didLoad {
                Section {
                    Picker("预览类型", selection: $currentPreviewType) {
                        ForEach(WidgetPreviewTypeOption.allCases) { value in
                            Text(value.rawValue)
                                .tag(value)
                        }
                    }
                    .pickerStyle(.segmented)
                    
                    VStack(alignment: .center) {
                        // Preview
                        TabView(selection: $currentPreviewSize) {
                            WidgetMediumPreview(previewType: currentPreviewType, config: $currentWidgetSettings, user: user)
                                .tag(WidgetPreviewSizeOption.medium)
                            
                            WidgetLargePreview(previewType: currentPreviewType, config: $currentWidgetSettings, user: user)
                                .tag(WidgetPreviewSizeOption.large)
                        }
                        .tabViewStyle(.page(indexDisplayMode: .automatic))
                    }
                    .frame(height: 190)
                    
                    if currentPreviewSize == .large {
                        WidgetLargeBgPicker(user: user, currentPreviewType: $currentPreviewType, maiBackground: $maiBackground, chuBackground: $chuBackground, selectedChuBg: $selectedChuBg, selectedMaiBg: $selectedMaiBg, currentWidgetSettings: $currentWidgetSettings)
                    } else {
                        WidgetMediumBgPicker(user: user, currentPreviewType: $currentPreviewType, maiMediumBackground: $maiMediumBackground, chuMediumBackground: $chuMediumBackground, maiBgColor: $maiBgColor, chuBgColor: $chuBgColor, currentWidgetSettings: $currentWidgetSettings)
                    }
                    
                    WidgetCharPicker(user: user, currentPreviewType: $currentPreviewType, maiChar: $maiChar, chuChar: $chuChar, selectedMaiChar: $selectedMaiChar, selectedChuChar: $selectedChuChar, currentWidgetSettings: $currentWidgetSettings)
                    
                    
                    Toggle("深色背景", isOn: currentPreviewType == .chunithm ? (currentPreviewSize == .large ? $currentWidgetSettings.darkModes[0] : $currentWidgetSettings.darkModes[1]) : (currentPreviewSize == .large ? $currentWidgetSettings.darkModes[2] : $currentWidgetSettings.darkModes[3]))
                }
                .onChange(of: currentWidgetSettings) { newValue in
                    guard !didChange else { return }
                    didChange = true
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
            loadSettings()
            didLoad = true
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    saveSettings()
                    Task {
                        do {
                            try user.widgetCustom = JSONEncoder().encode(currentWidgetSettings)
                            try await WidgetDataController.shared.save(data: user.makeWidgetData(), context: WidgetDataController.shared.container.viewContext)
                        } catch {
                            print(error)
                        }
                        WidgetCenter.shared.reloadAllTimelines()
                        print("[WidgetSettings] Committed changes to widget center.")
                    }
                    didChange = false
                } label: {
                    Text("应用")
                }
                .disabled(!didChange)
            }
        }
        .navigationTitle("小组件")
        .navigationBarTitleDisplayMode(.inline)
    }

    
    func makeSettings() {
        var config = WidgetData.Customization()
        if user.maimai.isNotEmpty {
            switch maiBackground {
            case .plate:
                config.maiBgUrl = user.maimai.extra.frames.first { $0.current }?.url
            case .custom:
                config.maiBgUrl = selectedMaiBg?.url
            case .defaultBg:
                config.maiBgUrl = ""
            }
            switch maiChar {
            case .captain:
                config.maiCharUrl = user.maimai.extra.characters.first { $0.current }?.url
            case .custom:
                config.maiCharUrl = selectedMaiChar?.url
            case .defaultChar:
                config.maiCharUrl = ""
            }
        }
        if user.chunithm.isNotEmpty {
            switch chuBackground {
            case .plate:
                config.chuBgUrl = user.chunithm.extra.nameplates.first { $0.current }?.url
            case .custom:
                config.chuBgUrl = selectedChuBg?.url
            case .defaultBg:
                config.chuBgUrl = ""
            }
            switch chuChar {
            case .captain:
                config.chuCharUrl = user.chunithm.extra.nameplates.first { $0.current }?.url
            case .custom:
                config.chuCharUrl = selectedChuChar?.url
            case .defaultChar:
                config.chuCharUrl = ""
            }
        }
        currentWidgetSettings = config
    }
    
    func loadSettings() {
        if let char = currentWidgetSettings.maiCharUrl, let first = user.maimai.extra.characters.first(where: { $0.current }), char == first.url {
            maiChar = .captain
        } else if currentWidgetSettings.maiCharUrl != nil {
            maiChar = .custom
        } else {
            maiChar = .defaultChar
        }
        if let bg = currentWidgetSettings.maiBgUrl, let current = user.maimai.extra.frames.first(where: { $0.current }), bg == current.url {
            maiBackground = .plate
        } else if currentWidgetSettings.maiBgUrl != nil {
            maiBackground = .custom
        } else {
            maiBackground = .defaultBg
        }
        if let colors = currentWidgetSettings.maiColor {
            if colors.count > 1 {
                maiMediumBackground = .gradient
            } else {
                maiMediumBackground = .color
            }
        } else {
            maiMediumBackground = .defaultBg
        }
        
        if let char = currentWidgetSettings.chuCharUrl, let first = user.chunithm.extra.characters.first(where: { $0.current }), char == first.url {
            chuChar = .captain
        } else if currentWidgetSettings.chuCharUrl != nil {
            chuChar = .custom
        } else {
            chuChar = .defaultChar
        }
        if let bg = currentWidgetSettings.chuBgUrl, let first = user.chunithm.extra.nameplates.first(where: { $0.current }), bg == first.url {
            chuBackground = .plate
        } else if currentWidgetSettings.chuBgUrl != nil {
            chuBackground = .custom
        } else {
            chuBackground = .defaultBg
        }
        if let colors = currentWidgetSettings.chuColor {
            if colors.count > 1 {
                chuMediumBackground = .gradient
            } else {
                chuMediumBackground = .color
            }
        } else {
            chuMediumBackground = .defaultBg
        }
    }
    
    func saveSettings() {
        do {
            print("[WidgetSettings] Saved settings.")
            user.widgetCustom = try JSONEncoder().encode(currentWidgetSettings)
        } catch {
            // TODO: Add error toast
        }
    }
}

