//
//  RecentDetailView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/5/7.
//

import SwiftUI

struct RecentDetail: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var user: CFQNUser
    
    var chuEntry: CFQChunithm.RecentScoreEntry?
    var maiEntry: CFQMaimai.RecentScoreEntry?
    
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
    
    var body: some View {
        ScrollView {
            if (isLoaded) {
                VStack {
                    VStack {
                        HStack(alignment: .bottom) {
                            SongCoverView(coverURL: coverUrl, size: 120, cornerRadius: 10, withShadow: false)
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
                        HStack(alignment: .bottom) {
                            Text(score)
                                .font(.system(size: 30))
                                .bold()
                            
                            Spacer()
                            
                            Text(entry.grade)
                                .font(.system(size: 20))
                            
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
                                
                                
                                HStack {
                                    Text("Justice")
                                    Spacer()
                                    Text("\(entry.judges["justice"] ?? 0)")
                                        .bold()
                                }
                                
                                
                                HStack {
                                    Text("Attack")
                                    Spacer()
                                    Text("\(entry.judges["attack"] ?? 0)")
                                        .bold()
                                }
                                
                                
                                HStack {
                                    Text("Miss")
                                    Spacer()
                                    Text("\(entry.judges["miss"] ?? 0)")
                                        .bold()
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
                        
                        NavigationLink {
                            SongDetailView(user: user, chuSong: entry.associatedSong!)
                        } label: {
                            Image(systemName: "arrowshape.turn.up.right")
                            Text("前往歌曲详情")
                        }
                        .padding()
                        
                    } else if let entry = maiEntry {
                        HStack(alignment: .bottom) {
                            Text(score)
                                .font(.system(size: 30))
                                .bold()
                            
                            Spacer()
                            
                            Text(entry.rateString)
                                .font(.system(size: 20))
                            
                            Text(entry.status)
                                .font(.system(size: 20))
                        }
                        .padding()
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 5)
                                .foregroundColor(maimaiLevelColor[entry.levelIndex]?.opacity(0.4))
                            VStack {
                                HStack(alignment: .bottom) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(" ")
                                        Text("Tap")
                                        Text("Hold")
                                        Text("Slide")
                                        Text("Touch")
                                        Text("Break")
                                    }
                                    
                                    VStack(alignment: .center, spacing: 2) {
                                        HStack(alignment: .bottom) {
                                            VStack(spacing: 2) {
                                                Text("Critical")
                                                    .font(.system(size: 15))
                                                Text(maiTapArray[0])
                                                Text(maiHoldArray[0])
                                                Text(maiSlideArray[0])
                                                Text(maiTouchArray[0])
                                                Text(maiBreakArray[0])
                                            }
                                            
                                            VStack(spacing: 2) {
                                                Text("Perfect")
                                                    .font(.system(size: 15))
                                                Text(maiTapArray[1])
                                                Text(maiHoldArray[1])
                                                Text(maiSlideArray[1])
                                                Text(maiTouchArray[1])
                                                Text(maiBreakArray[1])
                                            }
                                            
                                            VStack(spacing: 2) {
                                                Text("Great")
                                                    .font(.system(size: 15))
                                                Text(maiTapArray[2])
                                                Text(maiHoldArray[2])
                                                Text(maiSlideArray[2])
                                                Text(maiTouchArray[2])
                                                Text(maiBreakArray[2])
                                            }
                                            
                                            VStack(spacing: 2) {
                                                Text("Good")
                                                    .font(.system(size: 15))
                                                Text(maiTapArray[3])
                                                Text(maiHoldArray[3])
                                                Text(maiSlideArray[3])
                                                Text(maiTouchArray[3])
                                                Text(maiBreakArray[3])
                                            }
                                            
                                            VStack(spacing: 2) {
                                                Text("Miss")
                                                    .font(.system(size: 15))
                                                Text(maiTapArray[4])
                                                Text(maiHoldArray[4])
                                                Text(maiSlideArray[4])
                                                Text(maiTouchArray[4])
                                                Text(maiBreakArray[4])
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
                            if(entry.matching[0] != "―") {
                                HStack {
                                    VStack(spacing: 5) {
                                        Text("Player 2")
                                        Text(entry.matching[0])
                                    }
                                    Spacer()
                                    VStack(spacing: 5) {
                                        Text("Player 3")
                                        Text(entry.matching[1])
                                    }
                                    
                                    
                                    VStack(spacing: 5) {
                                        Text("Player 4")
                                        Text(entry.matching[2])
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
                        
                        NavigationLink {
                            SongDetailView(user: user, maiSong: entry.associatedSong!)
                        } label: {
                            Image(systemName: "arrowshape.turn.up.right")
                            Text("前往歌曲详情")
                        }
                        .padding()
                    }
                }
                .padding()
            }
        }
        .onAppear {
            isLoaded = false
            loadVar()
            isLoaded = true
        }
        .navigationBarTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func loadVar() {
        if let entry = chuEntry {
            self.coverUrl = ChunithmDataGrabber.getSongCoverUrl(source: 1, musicId: String(entry.associatedSong!.musicId))
            self.title = entry.title
            self.artist = entry.associatedSong!.basicInfo.artist
            self.playTime = entry.timestamp.customDateString
            self.difficulty = entry.difficulty
            self.score = "\(entry.score)"
            self.diffColor = maimaiLevelColor[entry.levelIndex]!
            self.chuniMaxCombo = entry.judges.values.reduce(0) { orig, next in orig + next}
            self.chuniWidthArray = getWidthForChuniJudge()
        } else if let entry = maiEntry {
            self.coverUrl = MaimaiDataGrabber.getSongCoverUrl(source: 1, coverId: getCoverNumber(id: entry.associatedSong!.musicId))
            self.title = entry.title
            self.artist = entry.associatedSong!.basicInfo.artist
            self.playTime = entry.timestamp.customDateString
            self.difficulty = entry.difficulty
            self.score = "\(entry.score)%"
            self.diffColor = chunithmLevelColor[entry.levelIndex]!
            self.maiTapArray = entry.notes["tap"]!.components(separatedBy: ",")
            self.maiHoldArray = entry.notes["hold"]!.components(separatedBy: ",")
            self.maiSlideArray = entry.notes["slide"]!.components(separatedBy: ",")
            self.maiTouchArray = entry.notes["touch"]!.components(separatedBy: ",")
            self.maiBreakArray = entry.notes["break"]!.components(separatedBy: ",")
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

struct RecentDetail_Previews: PreviewProvider {
    static var previews: some View {
        RecentDetail(user: CFQNUser())
    }
}
