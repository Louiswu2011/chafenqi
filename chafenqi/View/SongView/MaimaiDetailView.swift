//
//  MaimaiDetailView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/4.
//

import SwiftUI



struct MaimaiDetailView: View {
    @ObservedObject var user: CFQUser
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) var openURL
    
    @State private var isFavourite = false
    @State private var isLoading = true
    
    @State private var loadingScore = true
    @State private var loadingComments = true
    
    @State private var comments: Array<Comment> = []
    @State private var showingComposer = false
    
    @State private var showingCalc = false
    @State private var showingDiffSelection = false
    @State private var showingDiffSelectioniOS14 = false
    
    @State private var userInfo = MaimaiPlayerRecord.shared
    @State private var scoreEntries = [Int: MaimaiRecordEntry]()
    @State private var chartStats = [:]
    
    var song: MaimaiSongData
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    SongCoverView(coverURL: MaimaiDataGrabber.getSongCoverUrl(source: user.maimaiCoverSource, coverId: getCoverNumber(id: String(song.musicId))), size: 120, cornerRadius: 10, withShadow: false)
                        .overlay(RoundedRectangle(cornerRadius: 10)
                            .stroke(colorScheme == .dark ? .white.opacity(0.33) : .black.opacity(0.33), lineWidth: 1))
                        .padding(.leading)
                    
                    VStack(alignment: .leading) {
                        Spacer()
                        
                        Text(song.title)
                            .font(.title)
                            .bold()
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                        
                        Text(song.basicInfo.artist)
                            .font(.title2)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .padding(.leading, 5)
                    
                    Spacer()
                    
                    VStack {
                        Spacer()
                        
                        Button {
                            isFavourite.toggle()
                        } label: {
                            if (isFavourite) {
                                Image(systemName: "heart.fill")
                                    .scaleEffect(1.2)
                            } else {
                                Image(systemName: "heart")
                                    .scaleEffect(1.2)
                            }
                        }
                        .foregroundColor(.red)
                        .padding(.trailing)
                    }
                }
                .frame(height: 120)
                .padding(.top, 5.0)
                .navigationTitle("")
                .navigationBarTitleDisplayMode(.inline)
                
                HStack {
                    
                    Text("\(song.constant[0], specifier: "%.1f")")
                        .foregroundColor(maimaiLevelColor[0])
                        .font(.title3)
                    Text("\(song.constant[1], specifier: "%.1f")")
                        .foregroundColor(maimaiLevelColor[1])
                        .font(.title3)
                    Text("\(song.constant[2], specifier: "%.1f")")
                        .foregroundColor(maimaiLevelColor[2])
                        .font(.title3)
                    Text("\(song.constant[3], specifier: "%.1f")")
                        .foregroundColor(maimaiLevelColor[3])
                        .font(.title3)
                    if (song.level.count == 5) {
                        Text("\(song.constant[4], specifier: "%.1f")")
                            .foregroundColor(maimaiLevelColor[4])
                            .font(.title3)
                    }
                    
                    if (song.type == "DX") {
                        Text("DX")
                            .font(.title3)
                            .bold()
                    }
                    
                    
                    Spacer()
                    
                    Text("BPM: \(song.basicInfo.bpm)")
                        .font(.title3)
                }
                .padding(.horizontal)
                
                HStack {
                    Text("\(song.basicInfo.from)")
                    
                    Spacer()
                    
                    Text("\(song.basicInfo.genre)")
                }
                .padding(.horizontal)
                
                let diffArray = ["Basic", "Advanced", "Expert", "Master", "Re:Master"]
                if #available(iOS 15.0, *) {
                    Button {
                        showingDiffSelection.toggle()
                    } label: {
                        Image(systemName: "arrowshape.turn.up.right")
                        Text("在Bilibili搜索谱面确认")
                    }
                    .padding(.vertical, 5)
                    .alert("选择难度", isPresented: $showingDiffSelection) {
                        ForEach(Array(song.level.enumerated()), id: \.offset) { index, level in
                            Button {
                                openURL(URL(string: "bilibili://search?keyword=" + ("\(song.title) \(diffArray[index]) maimai".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""))!)
                            } label: {
                                Text("\(diffArray[index]) \(level)")
                            }
                        }
                        Button("取消", role: .cancel) {}
                    }
                } else {
                    // Fallback on earlier versions
                    Button {
                        showingDiffSelectioniOS14.toggle()
                    } label: {
                        Image(systemName: "arrowshape.turn.up.right")
                        Text("在Bilibili搜索谱面确认")
                    }
                    .padding(.vertical, 5)
                    .sheet(isPresented: $showingDiffSelectioniOS14) {
                        CustomAlert(message: "选择难度", titlesAndActions: getDiffSelectionArray(levels: song.level, diffs: diffArray))
                    }
                }
                
                if (!loadingScore && user.didLogin && user.maimai != nil) {
                    let stats = chartStats[song.musicId] as! Array<MaimaiChartStat>
                    
                    HStack {
                        Text("游玩记录")
                            .font(.system(size: 20))
                            .bold()
                        Spacer()
                    }
                    .padding([.horizontal, .top])
                    
                    VStack(spacing: 5) {
                        ForEach(0..<4) { index in
                            MaimaiScoreCardView(index: index, scoreEntries: scoreEntries, song: song, chartStat: stats[index])
                                .padding(.bottom, 5)
                            
                        }
                        if (song.charts.count == 5) {
                            MaimaiScoreCardView(index: 4, scoreEntries: scoreEntries, song: song, chartStat: stats[4])
                                .padding(.bottom, 5)
                        }
                    }
                    
                    if (!loadingComments) {
                        HStack {
                            Text("评论")
                                .font(.system(size: 20))
                                .bold()
                            Spacer()
                            NavigationLink {
                                CommentDetail(user: user, from: Int(song.musicId) ?? 0, comments: comments)
                            } label: {
                                Text("显示全部")
                            }
                        }
                        .padding(.top)
                        .padding(.horizontal)
                        

                        if (comments.isEmpty) {
                            HStack {
                                Button {
                                    showingComposer.toggle()
                                } label: {
                                    Image(systemName: "plus.circle")
                                        .foregroundColor(.accentColor)
                                    Text("发表第一条评论")
                                }
                            }
                            .padding()
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(comments, id: \.uid) { entry in
                                        CommentCell(comment: entry)
                                            .background(
                                                RoundedRectangle(cornerRadius: 5)
                                                    .fill(.gray.opacity(0.2))
                                            )
                                            .frame(width: 300)
                                    }
                                    
                                }
                            }
                            .padding([.horizontal, .bottom])
                        }
                    }
                }
            }
            .onAppear {
                Task {
                    if(user.didLogin && user.maimai != nil) {
                        userInfo = user.maimai!.record

                        var scores = userInfo.records.filter {
                            $0.musicId == Int(song.musicId)!
                        }
                        scores.sort {
                            $0.levelIndex < $1.levelIndex
                        }
                        scoreEntries = Dictionary(uniqueKeysWithValues: scores.map { ($0.levelIndex, $0) })
                        chartStats = user.data.maimai.chartStats
                    }
                    
                    loadingComments = true
                    comments = await CommentHelper.getComments(mode: 1, musicId: Int(song.musicId) ?? 0)
                    loadingComments = false
                    
                    loadingScore = false
                }
            }
            .sheet(isPresented: $showingComposer) {
                CommentComposerView(user: user, from: Int(song.musicId) ?? 0, showingComposer: $showingComposer)
            }
            //            .toolbar {
            //                ToolbarItem(placement: .navigationBarTrailing) {
            //                    Menu {
            //                        Button {
            //                            showingCalc.toggle()
            //                        } label: {
            //                            Image(systemName: "plus.forwardslash.minus")
            //                            Text("分数计算")
            //                        }
            //                        .sheet(isPresented: $showingCalc) {
            //                            BorderCalcView(song: song)
            //                        }
            //                    } label: {
            //                        Image(systemName: "ellipsis.circle")
            //                    }
            //                }
            //            }
        }
    }
    
    struct MaimaiScoreCardView: View {
        var index: Int
        var scoreEntries: [Int: MaimaiRecordEntry]
        var song: MaimaiSongData
        var chartStat: MaimaiChartStat?
        
        @State private var showingDetail = false
        @State private var rotationAngle: Double = 0
        
        let levelLabel = [
            0: "Basic",
            1: "Advanced",
            2: "Expert",
            3: "Master",
            4: "Re:Master"
        ]
        
        let standardNoteType = [
            0: "Tap",
            1: "Hold",
            2: "Slide",
            3: "Break"
        ]
        
        let dxNoteType = [
            0: "Tap",
            1: "Hold",
            2: "Slide",
            3: "Touch",
            4: "Break"
        ]
        
        var body: some View {
            ZStack {
                let exists = !scoreEntries.filter{ $0.key == index }.isEmpty
                let statsExists = chartStat!.playCount != nil
                
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(maimaiLevelColor[index]?.opacity(0.9))
                
                VStack() {
                    HStack {
                        Text(levelLabel[index]!)
                        Spacer()
                        if (exists && showingDetail) {
                            Text(scoreEntries[index]!.getSyncStatus())
                            Text(scoreEntries[index]!.getStatus())
                            Text(scoreEntries[index]!.getRateString())
                        }
                        Text(exists ? "\(scoreEntries[index]!.achievements, specifier: "%.4f")%" : "尚未游玩")
                            .bold()
                        Image(systemName: "chevron.backward")
                            .rotationEffect(Angle(degrees: rotationAngle))
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    rotationAngle = showingDetail ? rotationAngle + 90 : rotationAngle - 90
                                }
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    showingDetail.toggle()
                                }
                            }
                    }
                    .padding()
                    
                    if (showingDetail) {
                        VStack {
                            HStack {
                                Text("谱师：\(song.charts[index].charter)")
                                    .lineLimit(1)
                                Spacer()
                                Text("Rating：\(exists ? String(scoreEntries[index]!.rating) : "-")")
                            }
                            .padding([.horizontal])
                            
                            HStack {
                                
                                ZStack {
                                    RoundedRectangle(cornerRadius: 10)
                                        .opacity(0.1)
                                    
                                    
                                    VStack {
                                        ForEach(song.type == "DX" ? dxNoteType.sorted(by: <) : standardNoteType.sorted(by: <), id: \.key) { type in
                                            HStack {
                                                Text("\(type.value):")
                                                Spacer()
                                                Text("\(song.charts[index].notes[type.key])")
                                            }
                                        }
                                    }
                                    .padding()
                                }
                                .padding()
                                
                                Spacer()
                                
                                VStack {
                                    HStack {
                                        Text("评级:")
                                        Spacer()
                                        Text(statsExists ? String(chartStat!.tag!) : "-")
                                    }
                                    
                                    HStack {
                                        Text("SSS人数:")
                                        Spacer()
                                        Text(statsExists ? String(chartStat!.ssspCount!) : "-")
                                    }
                                    
                                    HStack {
                                        Text("平均成绩:")
                                        Spacer()
                                        Text(statsExists ? "\(chartStat!.averageScore!, specifier: "%.2f")%" : "-")
                                    }
                                }
                                .padding([.vertical, .trailing])
                                
                            }
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    func getDiffSelectionArray(levels: [String], diffs: [String]) -> [(title: String, action: (() -> Void)?)] {
        var array: [(title: String, action: (() -> Void)?)] = []
        for (index, level) in levels.enumerated() {
            array.append(("\(diffs[index]) \(level)", {
                openURL(URL(string: "bilibili://search?keyword=" + ("\(song.title) \(diffs[index]) maimai".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""))!)
            }))
        }
        array.append(("取消", {
            
        }))
        return array
    }
}

