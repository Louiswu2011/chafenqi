//
//  RecentDetailView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/5/7.
//

import SwiftUI
import CoreData
import AlertToast

struct RecentDetail: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) var context
    
    @ObservedObject var user: CFQNUser
    @ObservedObject var alertToast = AlertToastModel.shared
    
    var chuEntry: CFQChunithm.RecentScoreEntry?
    var maiEntry: UserMaimaiRecentScoreEntry?
    
    @State var hideSongInfo = false
    
    @State var coverUrl = URL(string: "http://127.0.0.1")!
    @State var title = ""
    @State var artist = ""
    @State var playTime = ""
    @State var difficulty = ""
    @State var diffColor = Color.black
    @State var score = ""
    
    @State var chuniJudgeWidth = CGFloat(160)
    @State var chuniMaxCombo = 0
    @State var chuniWidthArray: Array<CGFloat> = []
    
    @State var maiTapArray: Array<String> = []
    @State var maiHoldArray: Array<String> = []
    @State var maiSlideArray: Array<String> = []
    @State var maiTouchArray: Array<String> = []
    @State var maiBreakArray: Array<String> = []
    
    @State var isLoaded = false
    
    @State var takingScreenshot = false
    @State var screenshotMaker: ScreenshotMaker?
    @State var screenshotImage = UIImage()
    @State var isShareSheetShowing = false
    
    var body: some View {
        ScrollView {
            if (isLoaded) {
                VStack {
                    RecentBaseDetail(coverUrl: coverUrl, title: title, score: score, artist: artist, diffColor: diffColor, playTime: playTime, chuEntry: chuEntry, maiEntry: maiEntry, chuniJudgeWidth: chuniJudgeWidth, maiTapArray: maiTapArray, maiHoldArray: maiHoldArray, maiSlideArray: maiSlideArray, maiTouchArray: maiTouchArray, maiBreakArray: maiBreakArray)
                }
                .padding()
                .screenshotView { maker in
                    self.screenshotMaker = maker
                }
                
                if let entry = chuEntry {
                    if !hideSongInfo {
                        NavigationLink {
                            SongDetailView(user: user, chuSong: entry.associatedSong!)
                        } label: {
                            Image(systemName: "arrowshape.turn.up.right")
                            Text("前往歌曲详情")
                        }
                        .padding()
                        .opacity(takingScreenshot ? 0 : 1)
                    }
                } else if let entry = maiEntry {
                    if !hideSongInfo {
                        NavigationLink {
                            SongDetailView(user: user, maiSong: entry.associatedSong!)
                        } label: {
                            Image(systemName: "arrowshape.turn.up.right")
                            Text("前往歌曲详情")
                        }
                        .padding()
                        .opacity(takingScreenshot ? 0 : 1)
                    }
                }
            }
        }
        .onAppear {
            isLoaded = false
            loadVar()
            isLoaded = true
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    if let maker = screenshotMaker {
                        takingScreenshot.toggle()
                        if let image = maker.screenshot() {
                            screenshotImage = image
                            isShareSheetShowing.toggle()
                        }
                        takingScreenshot.toggle()
                    }
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .navigationBarTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isShareSheetShowing) {
            ActivityViewController(activityItems: ["\(title) \(score)", screenshotImage])
        }
        .toast(isPresenting: $alertToast.show) {
            alertToast.toast
        }
        .analyticsScreen(name: "recent_detail_screen", extraParameters: ["musicTitle": self.title, "mode": user.currentMode])
    }
    
    func loadVar() {
        if let entry = chuEntry {
            self.coverUrl = ChunithmDataGrabber.getSongCoverUrl(source: 1, musicId: String(entry.associatedSong!.musicID))
            self.title = entry.title
            self.artist = entry.associatedSong!.artist
            self.playTime = entry.timestamp.customDateString
            self.difficulty = entry.difficulty
            self.score = "\(entry.score)"
            self.diffColor = maimaiLevelColor[entry.levelIndex]!
            self.chuniMaxCombo = entry.judges.values.reduce(0) { orig, next in orig + next}
            self.chuniWidthArray = getWidthForChuniJudge()
        } else if let entry = maiEntry {
            self.coverUrl = MaimaiDataGrabber.getSongCoverUrl(source: 1, coverId: entry.associatedSong?.coverId ?? 0)
            self.title = entry.associatedSong!.title
            self.artist = entry.associatedSong!.basicInfo.artist
            self.playTime = entry.timestamp.customDateString
            self.difficulty = entry.difficulty
            self.score = "\(entry.achievements)%"
            self.diffColor = chunithmLevelColor[entry.levelIndex]!
            self.maiTapArray = entry.noteTap
            self.maiHoldArray = entry.noteHold
            self.maiSlideArray = entry.noteSlide
            self.maiTouchArray = entry.noteTouch
            self.maiBreakArray = entry.noteBreak
            for index in maiTouchArray.indices {
                let element = maiTouchArray[index].trimmingCharacters(in: .whitespacesAndNewlines)
                if (element == "") {
                    maiTouchArray[index] = "-"
                }
            }
        }
    }
    
    func getWidthForChuniJudge() -> Array<CGFloat> {
        var array: Array<CGFloat> = []
        if let entry = chuEntry {
            array.append(CGFloat(Float(entry.judges["critical"] ?? 0) / Float(chuniMaxCombo) * chuniJudgeWidth.asFloat()).cap(at: chuniJudgeWidth))
            array.append(CGFloat(Float(entry.judges["justice"] ?? 0) / Float(chuniMaxCombo) * chuniJudgeWidth.asFloat()).cap(at: chuniJudgeWidth))
            array.append(CGFloat((Float(entry.judges["attack"] ?? 0) / Float(chuniMaxCombo) * chuniJudgeWidth.asFloat()) + 1).cap(at: chuniJudgeWidth))
            array.append(CGFloat((Float(entry.judges["miss"] ?? 0) / Float(chuniMaxCombo) * chuniJudgeWidth.asFloat()) + 1).cap(at: chuniJudgeWidth))
        }
        return array
    }
}

struct RecentBaseDetail: View {
    @Environment(\.managedObjectContext) var context
    
    @ObservedObject var alertToast = AlertToastModel.shared
    
    var coverUrl: URL
    var title: String
    var score: String
    var artist: String
    var diffColor: Color
    var playTime: String
    
    var chuEntry: CFQChunithm.RecentScoreEntry?
    var maiEntry: UserMaimaiRecentScoreEntry?
    
    var chuniJudgeWidth: CGFloat
    
    var maiTapArray: Array<String>
    var maiHoldArray: Array<String>
    var maiSlideArray: Array<String>
    var maiTouchArray: Array<String>
    var maiBreakArray: Array<String>
    
    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                SongCoverView(coverURL: coverUrl, size: 120, cornerRadius: 10, withShadow: false)
                    .contextMenu {
                        Button {
                            Task {
                                let fetchRequest = CoverCache.fetchRequest()
                                fetchRequest.predicate = NSPredicate(format: "imageUrl == %@", coverUrl.absoluteString)
                                let matches = try? context.fetch(fetchRequest)
                                if let match = matches?.first?.image, let image = UIImage(data: match) {
                                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                                    alertToast.toast = AlertToast(displayMode: .hud, type: .complete(.green), title: "保存成功")
                                }
                            }
                        } label: {
                            Label("保存到相册", systemImage: "square.and.arrow.down")
                        }
                    }
                VStack(alignment: .leading) {
                    Spacer()
                    Text(title)
                        .font(.title)
                        .bold()
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .contextMenu {
                            Button {
                                UIPasteboard.general.string = title
                                alertToast.toast = AlertToast(displayMode: .hud, type: .complete(.green), title: "已复制到剪贴板")
                            } label: {
                                Text("复制")
                            }
                        }
                    Text(artist)
                        .font(.title2)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                Spacer()
            }
        }
        
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .foregroundColor(diffColor.opacity(0.7))
            
            Text(playTime)
                .padding(3)
        }
        .padding(.bottom,5)
        
        if let entry = chuEntry {
            RecentChuniDetail(chuniJudgeWidth: chuniJudgeWidth, entry: entry, score: score)
            
        } else if let entry = maiEntry {
            RecentMaimaiDetail(entry: entry, maiTapArray: maiTapArray, maiHoldArray: maiHoldArray, maiSlideArray: maiSlideArray, maiTouchArray: maiTouchArray, maiBreakArray: maiBreakArray)
        }
    }
}

struct RecentMaimaiDetail: View {
    var entry: UserMaimaiRecentScoreEntry
    
    var maiTapArray: [String]
    var maiHoldArray: [String]
    var maiSlideArray: [String]
    var maiTouchArray: [String]
    var maiBreakArray: [String]
    
    var body: some View {
        HStack(alignment: .bottom) {
            Text("\(entry.achievements, specifier: "%.4f")%")
                .font(.system(size: 30))
                .bold()
            
            Spacer()
            
            GradeBadgeView(grade: entry.rateString)
            
            Text(entry.status)
                .font(.system(size: 20))
        }
        .padding()
        
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .foregroundColor(maimaiLevelColor[entry.levelIndex]?.opacity(0.4))
            VStack {
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading) {
                        Text(" ")
                        Text("Tap")
                            .bold()
                        //                                        Text(" ")
                        //                                            .font(.system(size: 10))
                        Text("Hold")
                            .bold()
                        //                                        Text(" ")
                        //                                            .font(.system(size: 10))
                        Text("Slide")
                            .bold()
                        //                                        Text(" ")
                        //                                            .font(.system(size: 10))
                        if entry.type == "DX" {
                            Text("Touch")
                                .bold()
                            //                                            Text(" ")
                            //                                                .font(.system(size: 10))
                        }
                        Text("Break")
                            .bold()
                    }
                    Spacer()
                    VStack {
                        HStack {
                            let judgeTypes = ["Critical", "Perfect", "Great", "Good", "Miss"]
                            ForEach(maiTapArray.indices) { index in
                                let normalLoss = entry.associatedSong!.charts[entry.levelIndex].errors[0]
                                let breakLoss = entry.associatedSong!.charts[entry.levelIndex].errors[1]
                                let losses = [2: 0.2, 3: 0.5, 4: 1]
                                VStack(alignment: .trailing) {
                                    Text(judgeTypes[index])
                                        .bold()
                                        .font(.system(size: 13))
                                    
                                    if let tap = Int(maiTapArray[index]) {
                                        Text("\(tap)")
                                        //                                                        if index >= 2 && tap != 0 {
                                        //                                                            Text("(-\(Double(tap) * normalLoss * losses[index]!, specifier: "%.2f")%)")
                                        //                                                                .font(.system(size: 10))
                                        //                                                        } else {
                                        //                                                            Text(" ")
                                        //                                                                .font(.system(size: 10))
                                        //                                                        }
                                    } else {
                                        Text("-")
                                    }
                                    
                                    
                                    if let hold = Int(maiHoldArray[index]) {
                                        Text("\(hold)")
                                        //                                                        if index >= 2 && hold != 0 {
                                        //                                                            Text("(-\(Double(hold) * normalLoss * 2 * losses[index]!, specifier: "%.2f")%)")
                                        //                                                                .font(.system(size: 10))
                                        //                                                        } else {
                                        //                                                            Text(" ")
                                        //                                                                .font(.system(size: 10))
                                        //                                                        }
                                        
                                    } else {
                                        Text("-")
                                    }
                                    
                                    if let slide = Int(maiSlideArray[index]) {
                                        Text("\(slide)")
                                        //                                                        if index >= 2 && slide != 0 {
                                        //                                                            Text("(-\(Double(slide) * normalLoss * 3 * losses[index]!, specifier: "%.2f")%)")
                                        //                                                                .font(.system(size: 10))
                                        //                                                        } else {
                                        //                                                            Text(" ")
                                        //                                                                .font(.system(size: 10))
                                        //                                                        }
                                    } else {
                                        Text("-")
                                    }
                                    
                                    if entry.type == "DX" {
                                        if let touch = Int(maiTouchArray[index]) {
                                            Text("\(touch)")
                                            //                                                            if index >= 2 && touch != 0 {
                                            //                                                                Text("(-\(Double(touch) * normalLoss * losses[index]!, specifier: "%.2f")%)")
                                            //                                                                    .font(.system(size: 10))
                                            //                                                            } else {
                                            //                                                                Text(" ")
                                            //                                                                    .font(.system(size: 10))
                                            //                                                            }
                                        } else {
                                            Text("-")
                                        }
                                    }
                                    
                                    if let b = Int(maiBreakArray[index]) {
                                        Text("\(b)")
                                    } else {
                                        Text("-")
                                    }
                                }
                            }
                        }
                    }
                }
                
                HStack {
                    Text("Combo")
                    Text(entry.maxCombo)
                }
                .padding(.top, 3)
            }
            .padding()
        }
        VStack {
            if(entry.players[0] != "―") {
                HStack {
                    VStack(spacing: 5) {
                        Text("Player 2")
                        Text(entry.players[0])
                    }
                    Spacer()
                    VStack(spacing: 5) {
                        Text("Player 3")
                        Text(entry.players[1])
                    }
                    
                    
                    VStack(spacing: 5) {
                        Text("Player 4")
                        Text(entry.players[2])
                    }
                }
            }
            
            HStack {
                Text("Sync")
                Text(entry.maxSync)
            }
            .padding(.top, 3)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 5)
            .foregroundColor(maimaiLevelColor[entry.levelIndex]?.opacity(0.4)))
    }
}

struct RecentChuniDetail: View {
    var chuniJudgeWidth: CGFloat
    
    var entry: CFQChunithm.RecentScoreEntry
    var score: String
    
    var body: some View {
        HStack(alignment: .bottom) {
            Text(score)
                .font(.system(size: 30))
                .bold()
            
            Spacer()
            
            GradeBadgeView(grade: entry.grade)
            
            Text(entry.status)
                .font(.system(size: 20))
        }
        .padding(.vertical, 5)
        .padding(.horizontal)
        
        HStack {
            VStack {
                HStack {
                    VStack{
                        Text("Justice")
                        Text("Critical")
                            .font(.system(size: 10))
                    }
                    Spacer()
                    Text("\(entry.judges["critical"] ?? 0)")
                        .bold()
                }
                
                let judges = ["justice", "attack", "miss"]
                ForEach(Array(judges.enumerated()), id: \.offset) { index, type in
                    HStack {
                        if let judge = entry.judges[type] {
                            Text(type.firstUppercased)
                            Spacer()
                            VStack(alignment: .trailing) {
                                Text("\(judge)")
                                    .bold()
                                if judge > 0 {
                                    Text("(-\(entry.losses[index] * Double(judge), specifier: "%.0f"))")
                                        .font(.system(size: 12))
                                }
                            }
                        }
                    }
                }
            }
            .frame(width: chuniJudgeWidth)
            .padding(.trailing)
            
            Spacer()
            
            VStack {
                HStack {
                    Text("Tap")
                    Spacer()
                    Text("\(entry.notes["tap"] ?? "0")")
                }
                HStack {
                    Text("Hold")
                    Spacer()
                    Text("\(entry.notes["hold"] ?? "0")")
                }
                HStack {
                    Text("Slide")
                    Spacer()
                    Text("\(entry.notes["slide"] ?? "0")")
                }
                HStack {
                    Text("Air")
                    Spacer()
                    Text("\(entry.notes["air"] ?? "0")")
                }
                HStack {
                    Text("Flick")
                    Spacer()
                    Text("\(entry.notes["flick"] ?? "0")")
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 5)
            .foregroundColor(chunithmLevelColor[3]!.opacity(0.4)))
    }
}

struct RecentDetail_Previews: PreviewProvider {
    static var previews: some View {
        RecentDetail(user: CFQNUser())
    }
}

extension CGFloat {
    func cap(at: CGFloat) -> CGFloat {
        return self > at ? at : self
    }
    
    func asFloat() -> Float {
        return Float(self)
    }
}
