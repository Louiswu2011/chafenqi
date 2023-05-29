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
        
        Form {
//            Section {
//                Text("")
//            } header: {
//                Text("排序")
//            }
            
            Section {
                MultiplePickerView(title: "等级", options: CFQFilterOptions.levelOptions, selectionState: user.currentMode == 0 ? $filters.filterChuLevelToggles : $filters.filterMaiLevelToggles)
                MultiplePickerView(title: "分类", options: genreOptions, selectionState: user.currentMode == 0 ? $filters.filterChuGenreToggles : $filters.filterMaiGenreToggles)
            } header: {
                Text("筛选")
            }
        }
        .navigationTitle("筛选")
        .navigationBarTitleDisplayMode(.inline)
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
                Text(option)
                    .foregroundColor(.black)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark")
                }
            }
        }
        // .buttonStyle(.plain)
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
