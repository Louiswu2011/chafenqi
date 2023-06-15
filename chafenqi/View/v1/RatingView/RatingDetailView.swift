//
//  RatingDetailView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/3/19.
//

import SwiftUI

struct RatingDetailView: View {
    @ObservedObject var user: CFQUser
    
    var body: some View {
        ScrollView {
            if (user.currentMode == 0) {
                if (user.chunithm != nil) {
                    RatingDetailChunithmView(mode: user.chunithmCoverSource, user: user)
                        .padding()
                }
            } else {
                if (user.maimai != nil) {
                    RatingDetailMaimaiView(mode: user.maimaiCoverSource, user: user)
                        .padding()
                }
            }
        }
        .onAppear {
            // Debug only
            // user.currentMode = 0
        }
        .navigationTitle("Rating详情")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct RatingDetailMaimaiView: View {
    @State var mode: Int
    @State var user: CFQUser
    
    @State var pastFold = false
    @State var newFold = false
    
    var body: some View {
        VStack {
            HStack {
                Text(verbatim: "\(user.maimai!.custom.rawRating)")
                    .font(.system(size: 30))
                    .bold()
                Spacer()
                Text(verbatim: "Past \(user.maimai!.custom.pastRating) / New \(user.maimai!.custom.currentRating)")
            }
            .padding(.bottom)
            
            HStack {
                Text("旧曲 B25")
                    .font(.system(size: 20))
                    .bold()
                Spacer()
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        pastFold.toggle()
                    }
                } label: {
                    Text(pastFold ? "展开" : "收起")
                }
            }
            .padding(.bottom)
            
            if (!pastFold) {
                VStack(spacing: 15) {
                    ForEach(Array(user.maimai!.custom.pastSlice.enumerated()), id: \.offset) { index, entry in
                        let song = user.data.maimai.songlist.filter {
                            $0.musicId == String(entry.musicId)
                        }.first
                        NavigationLink {
                            MaimaiDetailView(user: user, song: song!)
                        } label: {
                            RatingMaimaiEntryBanner(mode: mode, index: index + 1, entry: entry)
                        }
                        .disabled(song == nil)
                        .buttonStyle(.plain)
                    }
                }
            }
            
            HStack {
                Text("新曲 B15")
                    .font(.system(size: 20))
                    .bold()
                Spacer()
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        newFold.toggle()
                    }
                } label: {
                    Text(newFold ? "展开" : "收起")
                }
            }
            .padding(.bottom)
            
            if (!newFold) {
                VStack(spacing: 15) {
                    ForEach(Array(user.maimai!.custom.currentSlice.enumerated()), id: \.offset) { index, entry in
                        let song = user.data.maimai.songlist.filter {
                            $0.musicId == String(entry.musicId)
                        }.first
                        NavigationLink {
                            MaimaiDetailView(user: user, song: song!)
                        } label: {
                            RatingMaimaiEntryBanner(mode: mode, index: index + 1, entry: entry)
                        }
                        .disabled(song == nil)
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

struct RatingDetailChunithmView: View {
    @State var mode: Int
    @State var user: CFQUser
    
    @State var bestFold = false
    @State var recentFold = false
    
    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                Text("\(user.chunithm!.profile.getRating(), specifier: "%.2f")")
                    .font(.system(size: 30))
                    .bold()
                Spacer()
                Text("Best \(user.chunithm!.profile.getAvgB30(), specifier: "%.2f") / Recent \(user.chunithm!.profile.getAvgR10(), specifier: "%.2f")")
                    .font(.system(size: 20))
            }
            .padding(.bottom)
            
            HStack {
                Text("最佳成绩 B30")
                    .font(.system(size: 20))
                    .bold()
                Spacer()
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        bestFold.toggle()
                    }
                } label: {
                    Text(bestFold ? "展开" : "收起")
                }
            }
            .padding(.bottom)
            
            if(!bestFold) {
                VStack(spacing: 15) {
                    ForEach(Array(user.chunithm!.rating.records.b30.enumerated()), id: \.offset) { index, entry in
                        let song = user.data.chunithm.songs.filter {
                            $0.musicId == entry.musicId
                        }.first
                        NavigationLink {
                            ChunithmDetailView(user: user, song: song!)
                        } label: {
                            RatingChunithmEntryBanner(mode: mode, index: index + 1, entry: entry)
                        }
                        .disabled(song == nil)
                        .buttonStyle(.plain)
                    }
                }
            }
            
            HStack {
                Text("最近成绩 R10")
                    .font(.system(size: 20))
                    .bold()
                Spacer()
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        recentFold.toggle()
                    }
                } label: {
                    Text(recentFold ? "展开" : "收起")
                }
            }
            .padding(.bottom)
            
            if(!recentFold) {
                VStack(spacing: 15) {
                    ForEach(Array(user.chunithm!.rating.records.r10.enumerated()), id: \.offset) { index, entry in
                        let song = user.data.chunithm.songs.filter {
                            $0.musicId == entry.musicId
                        }.first
                        NavigationLink {
                            ChunithmDetailView(user: user, song: song!)
                        } label: {
                            RatingChunithmEntryBanner(mode: mode, index: index + 1, entry: entry)
                        }
                        .disabled(song == nil)
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

struct RatingDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RatingDetailView(user: CFQUser())
    }
}

struct RatingChunithmEntryBanner: View {
    @State var mode: Int
    @State var index: Int
    @State var entry: ScoreEntry
    
    var body: some View {
        HStack {
            SongCoverView(coverURL: ChunithmDataGrabber.getSongCoverUrl(source: mode, musicId: String(entry.musicId)), size: 50, cornerRadius: 5)
                .padding(.trailing, 5)
            Group {
                VStack(alignment: .leading) {
                    HStack {
                        Text("#\(index)")
                            .frame(width: 35, alignment: .leading)
                        Text("\(entry.constant, specifier: "%.1f")/\(entry.rating, specifier: "%.2f")")
                            .bold()
                            .frame(width: 90, alignment: .leading)
                    }
                    Spacer()
                    Text("\(entry.title)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    HStack {
                        let status = entry.getStatus()
                        if (status != "Clear") {
                            Text("\(entry.getStatus())")
                        }
                        GradeBadgeView(grade: entry.getGrade())
                    }
                    Spacer()
                    Text("\(entry.score)")
                    
                }
            }
            .font(.system(size: 18))
        }
        .frame(height: 50)
    }
}

struct RatingMaimaiEntryBanner: View {
    @State var mode: Int
    @State var index: Int
    @State var entry: MaimaiRecordEntry
    
    var body: some View {
        HStack {
            SongCoverView(coverURL: MaimaiDataGrabber.getSongCoverUrl(source: mode, coverId: getCoverNumber(id: String(entry.musicId))), size: 50, cornerRadius: 5)
                .padding(.trailing, 5)
            Group {
                VStack(alignment: .leading) {
                    HStack {
                        Text("#\(index)")
                            .frame(width: 35, alignment: .leading)
                        Text("\(entry.constant, specifier: "%.1f")/\(entry.rating)")
                            .bold()
                            .frame(width: 90, alignment: .leading)
                    }
                    Spacer()
                    Text("\(entry.title)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    HStack {
                        Text("\(entry.getStatus())")
                        GradeBadgeView(grade: entry.getRateString())
                    }
                    Spacer()
                    Text("\(entry.achievements, specifier: "%.4f")%")
                    
                }
            }
            .font(.system(size: 18))
        }
        .frame(height: 50)
    }
}
