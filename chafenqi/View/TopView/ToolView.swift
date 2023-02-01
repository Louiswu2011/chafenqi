//
//  ToolView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/1.
//

import SwiftUI

struct ToolView: View {
    var body: some View {
        VStack {
            Form {
                Section {
                    
                    HStack {
                        NavigationLink {
                            SongRandomizerView()
                        } label: {
                            Image(systemName: "dice")
                                .resizable()
                                .aspectRatio(1, contentMode: .fit)
                                .padding(5)
                            VStack(alignment: .leading) {
                                Text("随机歌曲")
                                    .font(.title2)
                                    .bold()
                                Text("今天中二打什么？")
                                    .font(.footnote)
                            }
                            Spacer()
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(height: 50)
                    
                    HStack {
                        NavigationLink {
                            
                        } label: {
                            Image(systemName: "plus.forwardslash.minus")
                                .resizable()
                                .aspectRatio(1, contentMode: .fit)
                                .padding(5)
                            VStack(alignment: .leading) {
                                Text("分数计算器")
                                    .font(.title2)
                                    .bold()
                                Text("我不要再鸟寸了！")
                                    .font(.footnote)
                            }
                            Spacer()
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(height: 50)
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
        MainView()
    }
}
