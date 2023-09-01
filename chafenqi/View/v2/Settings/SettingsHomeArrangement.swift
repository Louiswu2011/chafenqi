//
//  SettingsHomeArrangement.swift
//  chafenqi
//
//  Created by xinyue on 2023/6/6.
//

import SwiftUI

struct SettingsHomeArrangement: View {
    @AppStorage("settingsHomeArrangement") var homeArrangement = "最近动态|Rating分析|出勤记录"
    @State private var editMode = EditMode.active
    
    @State private var homeModules = [String]()
    
    var body: some View {
        List {
            ForEach(homeModules, id: \.hashValue) { value in
                Text(value)
            }
            .onMove { index, newIndex in
                homeModules.move(fromOffsets: index, toOffset: newIndex)
            }
        }
        .environment(\.editMode, $editMode)
        .navigationTitle("主页排序")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            homeModules = homeArrangement.components(separatedBy: "|")
        }
        .onDisappear {
            homeArrangement = homeModules.joined(separator: "|")
        }
    }
}

struct SettingsHomeArrangement_Previews: PreviewProvider {
    static var previews: some View {
        SettingsHomeArrangement()
    }
}
