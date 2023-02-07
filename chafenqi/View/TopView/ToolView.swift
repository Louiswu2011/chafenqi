//
//  ToolView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/1.
//

import SwiftUI

struct ToolView: View {
    @AppStorage("settingsCurrentMode") var currentMode = 0
    
    @State private var showingUpdaterView = false
    
    var body: some View {
        VStack {
            Form {
                Section {
                    
                    HStack {
                        NavigationLink {
                            SongRandomizerView(randomOnAppear: true)
                        } label: {
                            Image(systemName: "dice")
                                .resizable()
                                .aspectRatio(1, contentMode: .fit)
                                .padding(5)
                            VStack(alignment: .leading) {
                                Text("随机歌曲")
                                    .font(.title2)
                                    .bold()
                                Text(currentMode == 0 ? "今天中二打什么？" : "今天maimai打什么？")
                                    .font(.system(size: 15))
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(height: 50)
                    
//                    HStack {
//                        NavigationLink {
//
//                        } label: {
//                            Image(systemName: "plus.forwardslash.minus")
//                                .resizable()
//                                .aspectRatio(1, contentMode: .fit)
//                                .padding(5)
//                            VStack(alignment: .leading) {
//                                Text("分数计算器")
//                                    .font(.title2)
//                                    .bold()
//                                Text("我不要再鸟寸了！")
//                                    .font(.footnote)
//                            }
//                            Spacer()
//                        }
//                        .buttonStyle(.plain)
//                    }
//                    .frame(height: 50)
                    
                    NavigationLink {
                        UpdaterRouterView()
                    } label: {
                        Text("Updater")
                    }
                    
                    
                } header: {
                    Text("常规")
                }
            }
            .navigationTitle("工具箱")
        }
    }
}

struct ToolView_Previews: PreviewProvider {
    static var previews: some View {
        ToolView()
    }
}
