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
                RatingDetailChunithmView(mode: user.chunithmCoverSource, chunithm: user.chunithm!)
            } else {
                RatingDetailMaimaiView(mode: user.maimaiCoverSource, maimai: user.maimai!)
            }
        }
        .onAppear {
            // Debug only
            // user.currentMode = 0
        }
        .padding()
        .navigationTitle("Rating详情")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct RatingDetailMaimaiView: View {
    @State var mode: Int
    @State var maimai: CFQUser.Maimai
    
    var body: some View {
        VStack {
            HStack {
                Text(verbatim: "\(maimai.custom.rawRating)")
                    .font(.system(size: 30))
                    .bold()
                Spacer()
                Text(verbatim: "Past \(maimai.custom.pastRating) / New \(maimai.custom.currentRating)")
            }
            
            Divider()
            
            HStack {
                Text("旧曲 B25")
                    .font(.system(size: 20))
                    .bold()
                Spacer()
            }
            
            HStack {
                Text("新曲 B15")
                    .font(.system(size: 20))
                    .bold()
                Spacer()
            }
        }
    }
}

struct RatingDetailChunithmView: View {
    @State var mode: Int
    @State var chunithm: CFQUser.Chunithm
    
    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                Text("\(chunithm.profile.getRating(), specifier: "%.2f")")
                    .font(.system(size: 30))
                    .bold()
                Spacer()
                Text("Best \(chunithm.profile.getAvgB30(), specifier: "%.2f") / Recent \(chunithm.profile.getAvgR10(), specifier: "%.2f")")
                    .font(.system(size: 20))
            }
            .padding(.bottom)
            
            HStack {
                Text("最佳成绩 B30")
                    .font(.system(size: 20))
                    .bold()
                Spacer()
            }
            .padding(.bottom)
            
            Group {
                VStack {
                    ForEach(Array(chunithm.rating.records.b30.enumerated()), id: \.offset) { index, entry in
                        RatingChunithmEntryBanner(mode: mode, index: index + 1, entry: entry)
                    }
                }
            }
            
            HStack {
                Text("最近成绩 R10")
                    .font(.system(size: 20))
                    .bold()
                Spacer()
            }
            .padding(.bottom)
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
            VStack(alignment: .leading) {
                HStack {
                    Text("#\(index)")
                        .font(.system(size: 20))
                        .bold()
                        .frame(width: 25)
                    Text("\(entry.rating, specifier: "%.2f")")
                        .font(.system(size: 20))
                        .bold()
                        .frame(width: 35)
                }
                Spacer()
                Text("\(entry.title)")
                    .font(.system(size: 20))
            }
            Spacer()
            VStack(alignment: .trailing) {
                Text("\(entry.getStatus()) \(entry.getGrade())")
                    .font(.system(size: 20))
                Spacer()
                Text("\(entry.score)")
                    .font(.system(size: 20))
                
            }
        }
        .frame(height: 55)
    }
}
