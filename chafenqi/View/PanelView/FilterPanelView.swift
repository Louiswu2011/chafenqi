//
//  FilterPanelView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/1.
//

import SwiftUI

struct FilterPanelView: View {
    @Binding var searchText: String
    
    @State private var searchTitle = false
    @State private var searchArtist = false
    @State private var searchCharter = false
    
    @State private var filterPlayedOnly = false
    
    @State private var filterConstant = true
    @State private var filterConstantUpperBound = ""
    @State private var filterConstantLowerBound = ""
    
    @State private var filterLevel = true
    @State private var filterLevelUpperBound = "1"
    @State private var filterLevelLowerBound = "15"
    
    @State private var sortOptions = ["按等级", "按定数", "按版本", "按标题"]
    @State private var sortWays = ["升序", "降序"]
    @State private var sortBy = ""
    @State private var sortIn = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("关键词", text: $searchText)
                    Toggle(isOn: $searchTitle) {
                        Text("搜索标题")
                    }
                    Toggle(isOn: $searchArtist) {
                        Text("搜索作者")
                    }
                    Toggle(isOn: $searchCharter) {
                        Text("搜索谱师")
                    }
                } header: {
                    Text("搜索")
                }
                
                Section {
                    Toggle(isOn: $filterPlayedOnly) {
                        Text("仅显示已游玩曲目")
                    }
                    Toggle(isOn: $filterConstant.animation(.easeInOut(duration: 0.3))) {
                        Text("筛选定数")
                    }
                    if (filterConstant) {
                        HStack {
                            Text("定数范围")
                            Spacer()
                            TextField("0.0", text: $filterConstantLowerBound)
                                .frame(width: 35)
                            Text("到")
                            TextField("0.0", text: $filterConstantUpperBound)
                                .frame(width: 35)
                        }
                        
                    }
                    Toggle(isOn: $filterLevel.animation(.easeInOut(duration: 0.3))) {
                        Text("筛选等级")
                    }
                    if (filterLevel) {
                        HStack {
                            Text("等级范围")
                            Spacer()
                            Picker("", selection: $filterLevelLowerBound) {
                                ForEach(1..<7) { text in
                                    Text(String(text))
                                }
                                ForEach(8..<15) { text in
                                    Text(String(text))
                                    Text("\(text)+")
                                }
                                Text("15")
                            }
                            .pickerStyle(.menu)
                            Text("到")
                            Picker("", selection: $filterLevelLowerBound) {
                                ForEach(1..<7) { text in
                                    Text(String(text))
                                }
                                ForEach(8..<15) { text in
                                    Text(String(text))
                                    Text("\(text)+")
                                }
                                Text("15")
                            }
                            .pickerStyle(.menu)
                        }
                    }
                } header: {
                    Text("筛选")
                }
                
                Section {
                    Picker("", selection: $sortBy) {
                        
                    }
                } header: {
                    Text("排序")
                }
            }
            .navigationTitle("筛选和排序")
        }
    }
}

struct FilterPanelView_Previews: PreviewProvider {
    static var previews: some View {
        FilterPanelView(searchText: .constant(""))
    }
}
