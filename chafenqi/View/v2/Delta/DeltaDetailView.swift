//
//  DeltaDetailView.swift
//  chafenqi
//
//  Created by xinyue on 2023/5/29.
//

import SwiftUI

struct DeltaDetailView: View {
    @ObservedObject var user = CFQNUser()
    
    @State var deltaIndex = 0
    @State var isLoaded = false
    
    @State var dateString: String = ""
    @State var rating: String = ""
    @State var ratingDelta: String = ""
    @State var pc: String = ""
    @State var pcDelta: String = ""
    
    @State var chuLog: CFQChunithmDayRecords.CFQChunithmDayRecord?
    @State var maiLog: CFQMaimaiDayRecords.CFQMaimaiDayRecord?
    
    @State var chartType = 0
    
    var body: some View {
        ScrollView {
            if isLoaded {
                VStack {
                    HStack {
                        DeltaTextBlock(title: "Rating", currentValue: rating, deltaValue: ratingDelta)
                            .padding(.trailing, 5)
                        DeltaTextBlock(title: "总PC数", currentValue: pc, deltaValue: pcDelta)
                        Spacer()
                    }
                    .padding(.bottom)
                    
                    HStack {
                        Text("游玩记录")
                            .font(.system(size: 20))
                            .bold()
                        Spacer()
                        NavigationLink {
                            if user.currentMode == 0 {
                                if let entries = chuLog {
                                    DeltaPlayList(user: user, chuLog: entries.recentEntries)
                                }
                            } else if user.currentMode == 1 {
                                if let entries = maiLog {
                                    DeltaPlayList(user: user, maiLog: entries.recentEntries)
                                }
                            }
                        } label: {
                            Text("显示全部")
                        }
                    }
                    VStack {
                        if user.currentMode == 0 {
                            if let chuLog = chuLog {
                                ForEach(Array(chuLog.recentEntries.prefix(3)), id: \.timestamp) { entry in
                                    NavigationLink {
                                        RecentDetail(user: user, chuEntry: entry)
                                    } label: {
                                        HStack {
                                            SongCoverView(coverURL: ChunithmDataGrabber.getSongCoverUrl(source: user.chunithmCoverSource, musicId: String(entry.associatedSong!.musicID)), size: 65, cornerRadius: 5)
                                                .padding(.trailing, 5)
                                            Spacer()
                                            VStack {
                                                HStack {
                                                    Text(entry.timestamp.customDateString)
                                                    Spacer()
                                                }
                                                Spacer()
                                                HStack(alignment: .bottom) {
                                                    Text(entry.title)
                                                        .font(.system(size: 17))
                                                        .lineLimit(2)
                                                    Spacer()
                                                    Text("\(entry.score)")
                                                        .font(.system(size: 21))
                                                        .bold()
                                                }
                                            }
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        } else if user.currentMode == 1 {
                            if let maiLog = maiLog {
                                ForEach(Array(maiLog.recentEntries.prefix(3)), id: \.timestamp) { entry in
                                    NavigationLink {
                                        RecentDetail(user: user, maiEntry: entry)
                                    } label: {
                                        HStack {
                                            SongCoverView(coverURL: MaimaiDataGrabber.getSongCoverUrl(source: user.maimaiCoverSource, coverId: getCoverNumber(id: String(entry.associatedSong!.musicId))), size: 65, cornerRadius: 5)
                                                .padding(.trailing, 5)
                                            Spacer()
                                            VStack {
                                                HStack {
                                                    Text(entry.timestamp.customDateString)
                                                    Spacer()
                                                }
                                                Spacer()
                                                HStack(alignment: .bottom) {
                                                    Text(entry.title)
                                                        .font(.system(size: 17))
                                                        .lineLimit(2)
                                                    Spacer()
                                                    Text("\(entry.score, specifier: "%.4f")%")
                                                        .font(.system(size: 21))
                                                        .bold()
                                                }
                                            }
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .onAppear {
            isLoaded = false
            loadVar()
        }
        .navigationTitle(dateString)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func loadVar() {
        guard !isLoaded else { return }
        if let log = chuLog {
            if let latestDelta = log.latestDelta {
                rating = String(format: "%.2f", latestDelta.rating)
                pc = String(latestDelta.playCount)
                ratingDelta = log.hasDelta ? String(format: "%.2f", log.ratingDelta) : ""
                pcDelta = log.hasDelta ? String(log.pcDelta) : ""
                
                if log.ratingDelta == 0 {
                    ratingDelta = "\u{00b1}0"
                } else if log.ratingDelta > 0 {
                    ratingDelta = "+\(ratingDelta)"
                }
                if log.pcDelta == 0 {
                    pcDelta = "\u{00b1}0"
                } else if log.pcDelta > 0 {
                    pcDelta = "+\(pcDelta)"
                }
            } else {
                rating = "无数据"
                pc = "无数据"
            }
        } else if let log = maiLog {
            if let latestDelta = log.latestDelta {
                rating = String(format: "%.2f", latestDelta.rating)
                pc = String(describing: latestDelta.playCount)
                ratingDelta = log.hasDelta ? String(log.ratingDelta) : ""
                pcDelta = log.hasDelta ? String(log.pcDelta) : ""
                
                if log.ratingDelta == 0 {
                    ratingDelta = "\u{00b1}0"
                } else if log.ratingDelta > 0 {
                    ratingDelta = "+\(ratingDelta)"
                }
                if log.pcDelta == 0 {
                    pcDelta = "\u{00b1}0"
                } else if log.pcDelta > 0 {
                    pcDelta = "+\(pcDelta)"
                }
            } else {
                rating = "无数据"
                pc = "无数据"
            }
        }
        isLoaded = true
    }

}

struct DeltaTextBlock: View {
    var title: String
    var currentValue: String
    var deltaValue: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
            HStack(alignment: .bottom) {
                Text(currentValue)
                    .font(.system(size: 25))
                Text(deltaValue)
            }
        }
    }
}

struct DeltaDetailView_Previews: PreviewProvider {
    static var previews: some View {
        DeltaDetailView()
    }
}
