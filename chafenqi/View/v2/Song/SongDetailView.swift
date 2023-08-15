//
//  SongDetailView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/5/8.
//

import SwiftUI

struct SongDetailView: View {
    @ObservedObject var user: CFQNUser
    
    @Environment(\.managedObjectContext) var context
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) var openURL
    
    var maiSong: MaimaiSongData?
    var chuSong: ChunithmMusicData?
    
    @State var finishedLoading = false
    
    @State var title = ""
    @State var artist = ""
    @State var coverUrl = URL(string: "http://127.0.0.1")!
    @State var constant: [Double] = []
    @State var level: [String] = []
    @State var bpm = 0
    @State var from = ""
    @State var genre = ""
    
    @State var chuScores: CFQChunithmBestScoreEntries = []
    @State var maiScores: CFQMaimaiBestScoreEntries = []
    
    @State var showingChart = false
    @State var diffArray: [String] = []
    @State var availableDiff = ["Master"]
    @State var selectedDiff = "Master"
    @State var chartImage: UIImage = UIImage()
    @State var chartImageView = Image(systemName: "magnifyingglass")
    
    @State var showingDiffSelection = false
    @State var showingDiffSelectioniOS14 = false
    
    var body: some View {
        ScrollView {
            if finishedLoading {
                VStack {
                    HStack {
                        SongCoverView(coverURL: coverUrl, size: 120, cornerRadius: 10, withShadow: false)
                            .overlay(RoundedRectangle(cornerRadius: 10)
                                .stroke(colorScheme == .dark ? .white.opacity(0.33) : .black.opacity(0.33), lineWidth: 1))
                            .padding(.leading)
                        VStack(alignment: .leading) {
                            Spacer()
                            Text(title)
                                .font(.title)
                                .bold()
                                .lineLimit(2)
                                .minimumScaleFactor(0.8)
                            
                            Text(artist)
                                .font(.title2)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
                        }
                        .padding(.leading, 5)
                        Spacer()
                    }
                    .frame(height: 120)
                    .padding(.top, 5.0)
                    
                    HStack {
                        if chuSong != nil && chuSong!.charts.worldsend.enabled {
                            Text(chuSong!.charts.levels.last ?? "")
                                .font(.title3)
                        } else {
                            ForEach(Array(constant.enumerated()), id: \.offset) { index, value in
                                if value > 0.0 {
                                    Text("\(value, specifier: "%.1f")")
                                        .foregroundColor(chunithmLevelColor[index])
                                        .font(.title3)
                                }
                            }
                        }
                        Spacer()
                        Text("BPM: \(bpm)")
                            .font(.title3)
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Text(from)
                        Spacer()
                        Text(genre)
                    }
                    .padding(.horizontal)
                    
                    if (user.currentMode == 0) {
                        HStack {
                            Text("谱面预览")
                                .font(.system(size: 20))
                                .bold()
                            Spacer()
                            
                            Picker(selectedDiff, selection: $selectedDiff) {
                                ForEach(availableDiff, id: \.self) { diff in
                                    Text(diff)
                                }
                            }
                            .onChange(of: selectedDiff) { tag in
                                Task {
                                    do {
                                        chartImage = UIImage()
                                        let identifier = title
                                        try await reloadChartImage(identifier: identifier, diff: selectedDiff)
                                    } catch {}
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        .padding(.top)
                        .padding(.horizontal)
                        
                        ZStack {
                            RoundedRectangle(cornerSize: CGSize(width: 5, height: 5))
                                .foregroundColor(Color.black)
                                .shadow(color: colorScheme == .dark ? Color.white : Color.gray.opacity(0.7), radius: 1)
                            
                            // Chart Image
                            if (chartImage == UIImage()) {
                                ProgressView()
                            } else {
                                Image(uiImage: chartImage)
                                    .resizable()
                            }
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 5)
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(Color.gray.opacity(0.8))
                                
                                Button {
                                    if (chartImage != UIImage()) {
                                        showingChart.toggle()
                                    }
                                } label: {
                                    Image(systemName: "plus.magnifyingglass")
                                }
                                .sheet(isPresented: $showingChart) {
                                    SongChartView(chartImage: chartImage)
                                }
                            }
                            .position(x: 330, y: 180)
                        }
                        .frame(width: 350, height: 200)
                        .onAppear {
                            
                        }
                        .padding(.bottom)
                    }
                    
                    let maiDiffArray = ["Basic", "Advanced", "Expert", "Master", "Re:Master"]
                    let chuDiffArray = ["Basic", "Advanced", "Expert", "Master", "Ultima", "World's End"]
                    if #available(iOS 15.0, *) {
                        Button {
                            showingDiffSelection.toggle()
                        } label: {
                            Image(systemName: "arrowshape.turn.up.right")
                            Text("在Bilibili搜索谱面确认")
                        }
                        .padding(5)
                        .alert("选择难度", isPresented: $showingDiffSelection) {
                            ForEach(Array(level.enumerated()), id: \.offset) { index, level in
                                if level != "" && level != "0" {
                                    Button {
                                        openURL(URL(string: "bilibili://search?keyword=" + ("\(title) \(user.currentMode == 0 ? chuDiffArray[index] : maiDiffArray[index]) \(user.currentMode == 0 ? "chunithm" : "maimai")".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""))!)
                                    } label: {
                                        Text("\(user.currentMode == 0 ? chuDiffArray[index] : maiDiffArray[index]) \(level)")
                                    }
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
                        .padding(5)
                        .sheet(isPresented: $showingDiffSelectioniOS14) {
                            CustomAlert(message: "选择难度", titlesAndActions: getDiffSelectionArray(levels: level, diffs: user.currentMode == 0 ? chuDiffArray : maiDiffArray, game: user.currentMode == 0 ? "chunithm" : "maimai"))
                        }
                    }
                    
                    HStack {
                        Text("游玩记录")
                            .font(.system(size: 20))
                            .bold()
                        Spacer()
                    }
                    .padding([.horizontal, .top])
                    
                    VStack(spacing: 5) {
                        if let song = maiSong {
                            ForEach(Array(song.level.enumerated()), id: \.offset) { index, _ in
                                let entry = maiScores.filter { $0.levelIndex == index }.first
                                ScoreCardView(user: user, levelIndex: index, maiSong: song, maiEntry: entry)
                            }
                        } else if let song = chuSong {
                            ForEach(Array(song.charts.levels.enumerated()), id: \.offset) { index, _ in
                                if song.charts.enables[index] {
                                    let entry = chuScores.filter { $0.levelIndex == index }.first
                                    ScoreCardView(user: user, levelIndex: index, chuSong: song, chuEntry: entry)
                                }
                            }
                        }
                    }
                    
                    if let song = maiSong {
                        SongCommentScrollView(user: user, musicId: Int(song.musicId) ?? 0, musicFrom: 1)
                    } else if let song = chuSong {
                        SongCommentScrollView(user: user, musicId: song.musicID, musicFrom: 0)
                    }
                }
            }
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            finishedLoading = false
            Task {
                loadVar()
                finishedLoading = true
                do {
                    try await reloadChartImage(identifier: title, diff: selectedDiff)
                } catch CFQError.requestTimeoutError {

                } catch CFQError.unsupportedError {

                } catch {
                    
                }
            }
        }
    }
    
    func loadVar() {
        if let song = maiSong {
            self.diffArray = ["Basic", "Advanced", "Expert", "Master", "Re:Master"]
            self.title = song.title
            self.artist = song.basicInfo.artist
            self.coverUrl = MaimaiDataGrabber.getSongCoverUrl(source: 1, coverId: getCoverNumber(id: song.musicId))
            self.constant = song.constant
            self.level = song.level
            self.bpm = song.basicInfo.bpm
            self.from = song.basicInfo.from
            self.maiScores = user.maimai.best.filter {
                $0.associatedSong!.musicId == song.musicId
            }.sorted {
                $0.levelIndex < $1.levelIndex
            }
        } else if let song = chuSong {
            self.diffArray = ["Basic", "Advanced", "Expert", "Master", "Ultima", "World's End"]
            self.title = song.title
            self.artist = song.artist
            self.coverUrl = ChunithmDataGrabber.getSongCoverUrl(source: 1, musicId: String(song.musicID))
            self.level = song.charts.levels
            self.constant = song.charts.constants
            self.bpm = song.bpm
            self.from = song.from
            self.chuScores = user.chunithm.best.filter {
                $0.associatedSong!.musicID == song.musicID
            }.sorted {
                $0.levelIndex < $1.levelIndex
            }
        }
    }
    
    func reloadChartImage(identifier: String, diff: String) async throws {
        chartImage = try await ChartImageGrabber.downloadChartImage(identifier: title, diff: difficulty[diff]!, mode: 1, context: context)
        chartImageView = Image(uiImage: chartImage)
    }
    
    func getDiffSelectionArray(levels: [String], diffs: [String], game: String) -> [(title: String, action: (() -> Void)?)] {
        var array: [(title: String, action: (() -> Void)?)] = []
        for (index, level) in levels.enumerated() {
            if level != "" && level != "0" {
                array.append(("\(diffs[index]) \(level)", {
                    openURL(URL(string: "bilibili://search?keyword=" + ("\(title) \(diffs[index]) \(game)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""))!)
                }))
            }
        }
        array.append(("取消", {
            
        }))
        return array
    }
}

struct ScoreCardView: View {
    @ObservedObject var user: CFQNUser
    @State var levelIndex: Int
    
    @State var maiSong: MaimaiSongData?
    @State var chuSong: ChunithmMusicData?
    
    @State var maiEntry: CFQMaimai.BestScoreEntry?
    @State var chuEntry: CFQChunithm.BestScoreEntry?
    
    @State var maiRecords: [CFQMaimai.RecentScoreEntry]?
    @State var chuRecords: [CFQChunithm.RecentScoreEntry]?
    
    @State var expanded = false
    
    let maimaiLevelLabel = [
        0: "Basic",
        1: "Advanced",
        2: "Expert",
        3: "Master",
        4: "Re:Master"
    ]
    
    let chunithmLevelLabel = [
        0: "Basic",
        1: "Advanced",
        2: "Expert",
        3: "Master",
        4: "Ultima",
        5: "World's End"
    ]
    
    var body: some View {
        if let song = maiSong {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(maimaiLevelColor[levelIndex]?.opacity(0.9))
                
                VStack(spacing: 10) {
                    HStack {
                        Text(maimaiLevelLabel[levelIndex]!)
                        Spacer()
                        if let entry = maiEntry {
                            Text("\(entry.score, specifier: "%.4f")%")
                                .bold()
                            if let maiRecords = maiRecords {
                                NavigationLink {
                                    if user.isPremium {
                                        SongEntryListView(user: user, maiRecords: maiRecords)
                                    } else {
                                        NotPremiumView()
                                    }
                                } label: {
                                    Image(systemName: "info.circle")
                                }
                                .disabled(maiRecords.isEmpty)
                            }
                        } else {
                            Text("尚未游玩")
                                .bold()
                        }
                    }
                    
                    if expanded {
                        SongCardExpandedView(
                            constant: song.constant[levelIndex],
                            charter: song.charts[levelIndex].charter,
                            data: song.charts[levelIndex]
                        )
                    }
                }
                .padding()
            }
            .padding(.horizontal)
            .onTapGesture {
                withAnimation {
                    expanded.toggle()
                }
            }
            .onAppear {
                loadVar()
            }
        } else if let song = chuSong {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(chunithmLevelColor[levelIndex]?.opacity(0.9))
                VStack {
                    HStack {
                        Text(chunithmLevelLabel[levelIndex]!)
                        Spacer()
                        if let entry = chuEntry {
                            Text("\(entry.score)")
                                .bold()
                            if let chuRecords = chuRecords {
                                NavigationLink {
                                    if user.isPremium {
                                        SongEntryListView(user: user, chuRecords: chuRecords)
                                    } else {
                                        NotPremiumView()
                                    }
                                } label: {
                                    Image(systemName: "info.circle")
                                }
                                .disabled(chuRecords.isEmpty)
                            }
                        } else {
                            Text("尚未游玩")
                                .bold()
                        }
                    }
                    
                    if expanded {
                        if let entry = chuRecords?.first(where: { $0.levelIndex == levelIndex }) {
                            SongCardExpandedView(
                                constant: song.charts.constants[levelIndex],
                                charter: song.charts.charters[levelIndex],
                                chuEntry: entry
                            )
                        } else {
                            SongCardExpandedView(
                                constant: song.charts.constants[levelIndex],
                                charter: song.charts.charters[levelIndex]
                            )
                        }
                    }
                }
                .padding()
            }
            .padding(.horizontal)
            .onTapGesture {
                withAnimation {
                    expanded.toggle()
                }
            }
            .onAppear {
                loadVar()
            }
        }
    }
    
    func loadVar() {
        if let song = maiSong {
            maiRecords = user.maimai.recent.filter {
                $0.associatedSong!.musicId == song.musicId && $0.levelIndex == self.levelIndex
            }
        } else if let song = chuSong {
            chuRecords = user.chunithm.recent.filter {
                $0.associatedSong!.musicID == song.musicID && $0.levelIndex == self.levelIndex
            }
        }
    }
}

struct SongCardExpandedView: View {
    var constant: Double
    var charter: String
    
    var data: MaimaiSongData.MaimaiSongChartData?
    var chuEntry: CFQChunithm.RecentScoreEntry?
    
    var body: some View {
        VStack {
            HStack {
                Text("定数：\(constant, specifier: "%.1f")")
                Spacer()
                Text("谱师:\(charter)")
                    .lineLimit(1)
            }
            .padding(.top, 5)
            if let data = data {
                SongCardMaimaiLossesView(data: data)
            } else if let entry = chuEntry {
                SongCardChunithmLossesView(entry: entry)
            }
        }
    }
}

struct SongCardChunithmLossesView: View {
    var entry: CFQChunithm.RecentScoreEntry
    
    var body: some View {
        HStack {
            let judges = ["justice", "attack", "miss"]
            VStack(alignment: .leading) {
                
                ForEach(Array(judges.enumerated()), id: \.offset) { index, type in
                    HStack {
                        Text(type.firstUppercased)
                            .bold()
                        Text("-\(entry.losses[index], specifier: "%.0f")")
                    }
                }
                
                
            }
            Spacer()
            VStack(alignment: .leading) {
                HStack {
                    Text("SSS/+容错")
                        .bold()
                    Text("\(2500 / entry.losses[1], specifier: "%.1f") / \(1000 / entry.losses[1], specifier: "%.0f")")
                }
            }
        }
        .padding(.top, 5)
    }
}

struct SongCardMaimaiLossesView: View {
    var data: MaimaiSongData.MaimaiSongChartData
    
    let noteTypes = ["Tap", "Hold", "Slide", "Touch"]
    let judgeTypes = ["Great", "Good", "Miss"]
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    Spacer()
                    ForEach(Array(noteTypes.enumerated()), id: \.offset) { index, noteType in
                        if index == 3 && !data.possibleNormalLosses[3].isEmpty {
                            Text(noteType)
                                .bold()
                        } else if index != 3 {
                            Text(noteType)
                                .bold()
                        }
                    }
                }
                Spacer()
                
                ForEach(Array(judgeTypes.enumerated()), id: \.offset) { index, judgeType in
                    VStack(alignment: .trailing, spacing: 5) {
                        Text(judgeType)
                            .bold()
                        ForEach(data.possibleNormalLosses.indices, id: \.self) { innerIndex in
                            if !data.possibleNormalLosses[innerIndex].isEmpty && index < data.possibleNormalLosses.count - 1 {
                                Text(data.possibleNormalLosses[innerIndex][index])
                            }
                        }
                    }
                }
            }
            
            HStack {
                Text("Break")
                    .bold()
                Spacer()
                VStack {
                    Text("\(data.possibleBreakLosses[2]) ~")
                        .font(.system(size: 15))
                    Text("\(data.possibleBreakLosses[4])")
                        .font(.system(size: 15))
                }
                VStack {
                    Text("\(data.possibleBreakLosses[5])")
                }
                VStack {
                    Text("\(data.possibleBreakLosses[6])")
                }
            }
            .padding(.bottom ,5)
            
            HStack {
                VStack {
                    Text("50/100落")
                        .bold()
                    Text("\(data.possibleBreakLosses[0]) /")
                        .font(.system(size: 15))
                    Text("\(data.possibleBreakLosses[1])")
                        .font(.system(size: 15))
                }
                Spacer()
                VStack {
                    Text("SSS/+容错")
                        .bold()
                    Text("-\(data.lossUntilSSS, specifier: "%.1f") / -\(data.lossUntilSSSPlus, specifier: "%.1f")")
                }
                Spacer()
                VStack {
                    Text("50落/Great比")
                        .bold()
                    Text("\(data.breakToGreatRatio, specifier: "%.1f")")
                }
            }
        }
    }
}

struct SongCommentScrollView: View {
    var user: CFQNUser
    var musicId: Int
    var musicFrom: Int
    
    @State var comments: Array<UserComment> = []
    
    var body: some View {
        VStack {
            HStack {
                Text("评论")
                    .font(.system(size: 20))
                    .bold()
                Spacer()
                NavigationLink {
                    CommentDetail(user: user, musicId: musicId, musicFrom: musicFrom, comments: comments)
                } label: {
                    Text("显示全部")
                }
                // .disabled(comments.isEmpty)
            }
            .padding(.bottom, 5)
            ScrollView(.horizontal) {
                HStack {
                    ForEach(comments.sorted {
                        $0.timestamp > $1.timestamp
                    }.prefix(3), id: \.id) { comment in
                        CommentCell(comment: comment)
                            .background(RoundedRectangle(cornerRadius: 10).fill(.gray.opacity(0.1)))
                    }
                }
            }
        }
        .padding()
        .onAppear {
            Task {
                comments = try await CFQCommentServer.loadComments(mode: musicFrom, musicId: musicId)
            }
        }
    }
}

struct SongDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SongDetailView(user: CFQNUser())
    }
}
