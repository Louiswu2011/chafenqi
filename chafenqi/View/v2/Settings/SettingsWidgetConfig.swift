//
//  SettingsWidgetConfig.swift
//  chafenqi
//
//  Created by xinyue on 2023/7/5.
//

import SwiftUI

struct SettingsWidgetConfig: View {
    @ObservedObject var user: CFQNUser
    
    @State var customization = false

    
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
                        HStack {
                            
                        }
                    }
                } header: {
                    Text("2x2")
                }
                
                Section {
                    
                } header: {
                    Text("2x4")
                }
            }
        }
    }
}

