//
//  SettingsWidgetConfig.swift
//  chafenqi
//
//  Created by xinyue on 2023/7/5.
//

import SwiftUI

struct SettingsWidgetConfig: View {
    // @ObservedObject var user: CFQNUser
    
    @State var customization = true
    
    @State var smallBackground: WidgetBackgroundOption = .defaultBg
    @State var mediumBackground: WidgetBackgroundOption = .defaultBg
    
    @State var smallChar: WidgetCharacterOption = .defaultChar
    @State var mediumChar: WidgetCharacterOption = .defaultChar

    enum WidgetBackgroundOption: String, CaseIterable, Identifiable, Hashable {
        var id: Self {
            return self
        }
        
        case plate = "当前背景版"
        case custom = "自定义"
        case defaultBg = "默认"
    }
    
    enum WidgetCharacterOption: String, CaseIterable, Identifiable, Hashable {
        var id: Self {
            return self
        }
        
        case captain = "当前队长"
        case custom = "自定义"
        case defaultChar = "默认"
    }
    
    var body: some View {
        Form {
            Toggle(isOn: $customization.animation()) {
                Text("自定义小组件")
            }
            
            if customization {
                Section {
                    VStack(alignment: .center) {
                        //
                        // Place preview here
                        //
                        TabView {
                            RoundedRectangle(cornerRadius: 15)
                                .frame(width: 141, height: 141)
                            
                            RoundedRectangle(cornerRadius: 15)
                                .frame(width: 305.5, height: 141)
                        }
                        .tabViewStyle(.page(indexDisplayMode: .automatic))
                        HStack {
                            Button {
                                
                            } label: {
                                HStack {
                                    Image(systemName: "arrow.left.arrow.right")
                                    Text("切换游戏")
                                }
                            }
                        }
                    }
                    .frame(height: 190)
                    
                    Picker("背景", selection: $smallBackground) {
                        ForEach(WidgetBackgroundOption.allCases) { value in
                            Text(value.rawValue)
                                .tag(value)
                        }
                    }
                    
                    Picker("人物", selection: $smallChar) {
                        ForEach(WidgetCharacterOption.allCases) { value in
                            Text(value.rawValue)
                                .tag(value)
                        }
                    }
                }
                
                Section {
                    
                } header: {
                    Text("2x4")
                }
            }
        }
        .navigationTitle("小组件")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct WidgetPreview {
    
}

struct SettingsWidgetConfig_Previews: PreviewProvider {
    static var previews: some View {
        SettingsWidgetConfig()
    }
}
