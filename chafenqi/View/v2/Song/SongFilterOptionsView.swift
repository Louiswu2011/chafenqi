//
//  SongFilterOptionsView.swift
//  chafenqi
//
//  Created by xinyue on 2023/5/29.
//

import SwiftUI

struct SongFilterOptionsView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var user = CFQNUser()
    @State var hasAppeared = false
    @Binding var filters: CFQFilterOptions
    
    var body: some View {
        let genreOptions = user.currentMode == 0 ? CFQFilterOptions.chuGenreOptions : CFQFilterOptions.maiGenreOptions
        let versionOptions = user.currentMode == 0 ? CFQFilterOptions.chuVersionOptions : CFQFilterOptions.maiVersionOptions
        
        Form {
            Section {
                MultiplePickerView(title: "等级", options: CFQFilterOptions.levelOptions, selectionState: user.currentMode == 0 ? $filters.filterChuLevelToggles : $filters.filterMaiLevelToggles)
                MultiplePickerView(title: "分类", options: genreOptions, selectionState: user.currentMode == 0 ? $filters.filterChuGenreToggles : $filters.filterMaiGenreToggles)
                MultiplePickerView(title: "版本", options: versionOptions, selectionState: user.currentMode == 0 ? $filters.filterChuVersionToggles : $filters.filterMaiVersionToggles)
            } header: {
                Text("筛选")
            }
            
            Section {
                Toggle("启用排序", isOn: user.currentMode == 0 ? $filters.sortChu.animation() : $filters.sortMai.animation())
                if (user.currentMode == 0 && filters.sortChu) || (user.currentMode == 1 && filters.sortMai) {
                    Picker("方向", selection: user.currentMode == 0 ? $filters.sortChuMethod : $filters.sortMaiMethod) {
                        ForEach(CFQSortMethod.allCases) { value in
                            Text(value.rawValue)
                                .tag(value)
                        }
                    }
                    Picker("项目", selection: user.currentMode == 0 ? $filters.sortChuKey : $filters.sortMaiKey) {
                        ForEach(CFQSortKey.allCases) { value in
                            Text(value.rawValue)
                                .tag(value)
                        }
                    }
                    
                    if (user.currentMode == 0 && filters.sortChuKey != .bpm) || (user.currentMode == 1 && filters.sortMaiKey != .bpm) {
                        if user.currentMode == 0 {
                            Picker("难度", selection: $filters.sortChuDiff) {
                                ForEach(CFQChunithmSortDifficulty.allCases) { value in
                                    Text(value.rawValue)
                                        .tag(value)
                                }
                            }
                        } else if user.currentMode == 1 {
                            Picker("难度", selection: $filters.sortMaiDiff) {
                                ForEach(CFQMaimaiSortDifficulty.allCases) { value in
                                    Text(value.rawValue)
                                        .tag(value)
                                }
                            }
                        }
                    }
                }
            } header: {
                Text("排序")
            }
            
            Section {
                Toggle("隐藏未游玩歌曲", isOn: $filters.hideUnplayChart)
                if user.currentMode == 0 {
                    Toggle("隐藏World's End谱面", isOn: $filters.excludeChuWEChart)
                }
            }
        }
        .navigationTitle("筛选和排序")
        .navigationBarTitleDisplayMode(.inline)
        .analyticsScreen(name: "songlist_filter_screen")
    }
}

struct MultiplePickerView: View {
    var title: String
    var options: [String]
    @Binding var selectionState: [Bool]
    
    var body: some View {
        NavigationLink {
            Form {
                ForEach(Array(options.enumerated()), id: \.offset) { (index, option) in
                    MultiplePickerItem(option: option, isSelected: $selectionState[index])
                }
            }
        } label: {
            HStack {
                Text(title)
                
                Spacer()
                if !selectionState.trueIndices.isEmpty {
                    let trueIndicies = selectionState.trueIndices
                    if trueIndicies.count == 1 {
                        Text(options[trueIndicies.first!])
                            .foregroundColor(.gray)
                    } else {
                        Text("已选择\(trueIndicies.count)项")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
}

struct MultiplePickerItem: View {
    var option: String
    @Binding var isSelected: Bool
    
    var body: some View {
        Button {
            withAnimation {
                isSelected.toggle()
            }
        } label: {
            HStack {
                if option == "MiLK PLUS" {
                    Text("maimai MiLK PLUS")
                } else {
                    Text(option)
                }
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

extension Array where Self == Array<Bool> {
    var trueIndices: [Int] {
        return self.enumerated().filter{$1}.compactMap{$0.offset}
    }
}

struct SongFilterOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        SongFilterOptionsView(filters: .constant(CFQFilterOptions()))
    }
}
