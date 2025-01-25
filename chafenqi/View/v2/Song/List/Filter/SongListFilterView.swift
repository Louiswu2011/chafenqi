//
//  SongListFilterView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2024/08/27.
//

import Foundation
import SwiftUI

struct SongListFilterView: View {
    @ObservedObject var user: CFQNUser
    
    var versionOptions: [String] { user.currentMode == 0 ? user.chunithm.custom.versionList : user.data.maimai.versionList.map { version in version.title } }
    var levelOptions: [String] = ["1", "2", "3", "4", "5", "6", "7", "7+", "8", "8+", "9", "9+", "10", "10+", "11", "11+", "12", "12+", "13", "13+", "14", "14+", "15"]
    var genreOptions: [String] { user.currentMode == 0 ? user.chunithm.custom.genreList : user.data.maimai.genreList.map { genre in genre.title } }
    var diffOptions: [String] {
        user.currentMode == 0 ? CFQChunithmSortDifficulty.allCases.map { value in value.rawValue } : CFQMaimaiSortDifficulty.allCases.map { value in value.rawValue }
    }
    
    @Binding var selection: SongListFilterOptions
    
    @State var showAlertDialog: Bool = false
    
    @Binding var showFilterView: Bool
    
    var body: some View {
        Form {
            Section {
                MultiplePicker(title: "等级", options: levelOptions, selections: $selection.levelSelection)
                    .tag(0)
                MultiplePicker(title: "分类", options: genreOptions, selections: $selection.genreSelection)
                    .tag(1)
                MultiplePicker(title: "版本", options: versionOptions, selections: $selection.versionSelection)
                    .tag(2)
            } header: {
                Text("筛选")
            }
            
            Section {
                Toggle(isOn: $selection.sortEnabled) {
                    Text("启用排序")
                }
                
                if selection.sortEnabled {
                    Picker("方向", selection: $selection.sortOrientation) {
                        ForEach(CFQSortMethod.allCases) { value in
                            Text(value.rawValue)
                                .tag(value)
                        }
                    }
                    Picker("依据", selection: $selection.sortBy) {
                        ForEach(CFQSortKey.allCases) { value in
                            Text(value.rawValue)
                                .tag(value)
                        }
                    }
                    if (selection.sortBy != .bpm) {
                        Picker("难度", selection: $selection.sortDifficulty) {
                            ForEach(diffOptions, id: \.self) { value in
                                Text(value)
                                    .tag(diffOptions.firstIndex(of: value) ?? -1)
                            }
                        }
                    }
                }
            } header: {
                Text("排序")
            }
            
            Section {
                Toggle(isOn: $selection.hideNotPlayed) {
                    Text("隐藏未游玩歌曲")
                }
                if user.currentMode == 0 {
                    Toggle(isOn: $selection.hideWorldsEnd) {
                        Text("隐藏World's End谱面")
                    }
                }
                if user.currentMode == 1 {
                    Toggle(isOn: $selection.hideUtage) {
                        Text("隐藏宴会场谱面")
                    }
                }
                Toggle(isOn: $selection.onlyShowLoved) {
                    Text("仅显示喜爱歌曲")
                }
            }
            
            Section {
                Button(role: .destructive) {
                    showAlertDialog.toggle()
                } label: {
                    Text("重置...")
                }
            }
        }
        .navigationTitle("筛选和排序")
        .navigationBarTitleDisplayMode(.inline)
        .alert("确定要重置吗？", isPresented: $showAlertDialog) {
            Button(role: .destructive) {
                reset()
            } label: {
                Text("确定")
            }
            Button(role: .cancel) {
                
            } label: {
                Text("取消")
            }
        }
    }
    
    func reset() {
        selection = SongListFilterOptions()
    }
}
