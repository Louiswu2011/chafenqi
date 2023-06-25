//
//  InfoMaimaiClearList.swift
//  chafenqi
//
//  Created by xinyue on 2023/6/21.
//

import SwiftUI

let clearListColors: [Color] = [maiRankHex[0], .pink, .green, .blue, .red, .purple, .gray]


struct InfoMaimaiClearList: View {
    @ObservedObject var user: CFQNUser
    
    @State private var isLoading = true
    @State private var currentLevel = 20
    @State private var currentRatio = [Double]()
    @State private var currentFold = [Bool]()
    @State private var info = CFQMaimaiLevelRecords()
    
    var body: some View {
        ScrollView {
            if !isLoading {
                HStack(alignment: .bottom) {
                    Text("等级")
                    Text("\(CFQMaimaiLevelRecords.maiLevelStrings[currentLevel])")
                        .bold()
                        .font(.system(size: 25))
                    Spacer()
                    Button {
                        if currentLevel < 22 {
                            withAnimation {
                                currentLevel += 1
                                currentRatio = info.levels[currentLevel].ratios
                                currentFold = Array(repeating: false, count: info.levels[currentLevel].grades.count)
                            }
                        }
                    } label: {
                        Image(systemName: "plus")
                            .resizable()
                            .frame(width: 15, height: 15)
                    }
                    .padding(.trailing, 20)
                    Button {
                        if currentLevel > 0 {
                            withAnimation {
                                currentLevel -= 1
                                currentRatio = info.levels[currentLevel].ratios
                                currentFold = Array(repeating: false, count: info.levels[currentLevel].grades.count)
                            }
                        }
                    } label: {
                        Image(systemName: "minus")
                            .frame(width: 15, height: 15)
                    }
                }
                .padding()
                
                MaimaiClearBarView(datas: $currentRatio)
                    .frame(height: 25)
                    .mask(RoundedRectangle(cornerRadius: 5))
                    .padding([.bottom, .horizontal])
                HStack {
                    ForEach(Array(maiRankDesc.enumerated()), id: \.offset) { index, string in
                        Circle()
                            .foregroundColor(clearListColors[index])
                            .frame(width: 8)
                        Text(string)
                    }
                }
                .padding(.bottom)
                
                let levelInfo = info.levels[currentLevel]
                ForEach(Array(maiRankDesc.enumerated()), id: \.offset) { index, rankString in
                    let gradeInfo = info.levels[currentLevel].grades[index]
                    if gradeInfo.count != 0 {
                        HStack {
                            Text(rankString)
                                .bold()
                            Text("\(gradeInfo.count)/\(levelInfo.count)")
                            Spacer()
                            Button {
                                withAnimation {
                                    currentFold[index].toggle()
                                }
                            } label: {
                                Text(currentFold[index] ? "展开" : "收起")
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 5)
                        if !currentFold[index] {
                            VStack {
                                ForEach(gradeInfo.songs, id: \.idx) { song in
                                    MaimaiBestEntryBannerView(song: song)
                                        .padding(.horizontal)
                                }
                                .id(currentLevel)
                            }
                        }
                    }
                }
                .id(currentLevel)
            }
        }
        .onAppear {
            isLoading = true
            info = CFQMaimaiLevelRecords(best: user.maimai.best)
            withAnimation {
                currentRatio = info.levels[currentLevel].ratios
                currentFold = Array(repeating: false, count: info.levels[currentLevel].grades.count)
            }
            isLoading = false
        }
        .navigationTitle("歌曲完成度")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct MaimaiBestEntryBannerView: View {
    var song: CFQMaimai.BestScoreEntry
    
    var body: some View {
        HStack {
            SongCoverView(coverURL: song.associatedSong!.coverURL, size: 50, cornerRadius: 5)
            VStack(alignment: .leading) {
                Text("\(song.associatedSong!.constant[song.levelIndex], specifier: "%.1f")/\(song.rating)")
                Spacer()
                HStack {
                    Text(song.title)
                        .lineLimit(1)
                    Spacer()
                    Text("\(song.score, specifier: "%.4f")%")
                        .bold()
                }
            }
        }
    }
}

struct MaimaiClearBarView: View {
    @Binding var datas: [Double]
    
    var body: some View {
        GeometryReader { geo in
            HStack(spacing: 0) {
                ForEach(Array(datas.enumerated()), id: \.offset) { index, dataPoint in
                    Rectangle()
                        .foregroundColor(clearListColors[index])
                        .frame(width: geo.size.width * dataPoint)
                }
            }
        }
    }
}

extension Shape {
    /// fills and strokes a shape
    public func fill<S:ShapeStyle>(
        _ fillContent: S,
        strokeContent: S,
        strokeStyle: StrokeStyle
    ) -> some View {
        ZStack {
            self.fill(fillContent)
            self.stroke(strokeContent, style: strokeStyle)
        }
    }
}
