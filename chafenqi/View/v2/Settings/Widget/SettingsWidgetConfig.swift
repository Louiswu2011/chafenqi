//
//  SettingsWidgetConfig.swift
//  chafenqi
//
//  Created by xinyue on 2023/7/5.
//

import SwiftUI
import CoreData

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
    
    @State private var selectedChuBg: CFQData.Chunithm.ExtraEntry.NameplateEntry?
    @State private var selectedMaiBg: CFQData.Maimai.ExtraEntry.FrameEntry?
    
    @State private var selectedMaiChar: CFQData.Maimai.ExtraEntry.CharacterEntry?
    @State private var selectedChuChar: CFQData.Chunithm.ExtraEntry.CharacterEntry?
    
    @State private var currentPreviewType: WidgetPreviewTypeOption = .maimai
    @State private var currentPreviewSize: WidgetPreviewSizeOption = .medium
    
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
                            WidgetMediumPreview(previewType: currentPreviewType, config: currentWidgetSettings)
                                .tag(WidgetPreviewSizeOption.medium)
                            
                            WidgetLargePreview(previewType: currentPreviewType, config: currentWidgetSettings)
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

struct SettingsWidgetConfig_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SettingsWidgetConfig(user: CFQNUser())
        }
    }
}
