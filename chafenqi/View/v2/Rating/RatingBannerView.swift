//
//  RatingBannerView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/5/9.
//

import SwiftUI

struct RatingBannerView: View {
    @ObservedObject var user: CFQNUser
    
    var chuEntry: CFQChunithm.RatingEntry?
    var maiEntry: CFQChunithm.BestScoreEntry?
    
    var index: Int = 0
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct MaimaiRatingBannerView: View {
    @ObservedObject var user: CFQNUser
    
    var index: Int
    var entry: CFQMaimai.BestScoreEntry
    
    var body: some View {
        HStack {
            SongCoverView(coverURL: MaimaiDataGrabber.getSongCoverUrl(source: 1, coverId: getCoverNumber(id: String(entry.associatedSong!.musicId))), size: 50, cornerRadius: 5)
                .padding(.trailing, 5)
            Group {
                VStack(alignment: .leading) {
                    HStack {
                        let constant = entry.associatedSong!.constant[entry.levelIndex]
                        Text("#\(index)")
                            .frame(width: 35, alignment: .leading)
                        Text("\(constant, specifier: "%.1f")/\(entry.rating)")
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
                        // Text("\(entry.fc)")
                        GradeBadgeView(grade: entry.rateString)
                    }
                    Spacer()
                    Text("\(entry.score, specifier: "%.4f")%")
                    
                }
            }
            .font(.system(size: 18))
        }
        .frame(height: 50)
    }
}

struct ChunithmRatingBannerView: View {
    @ObservedObject var user: CFQNUser
    
    var index: Int
    var entry: CFQChunithm.RatingEntry
    
    var body: some View {
        HStack {
            SongCoverView(coverURL: ChunithmDataGrabber.getSongCoverUrl(source: 1, musicId: String(entry.associatedBestEntry!.associatedSong!.musicID)), size: 50, cornerRadius: 5)
                .padding(.trailing, 5)
            Group {
                VStack(alignment: .leading) {
                    HStack {
                        let constant = entry.associatedBestEntry!.associatedSong!.charts.constants[entry.associatedBestEntry!.levelIndex]
                        Text("#\(index)")
                            .frame(width: 35, alignment: .leading)
                        Text("\(constant, specifier: "%.1f")/\(ceil(entry.rating * 100) / 100, specifier: "%.2f")")
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
//                        let fc = entry.associatedBestEntry!.fcombo
//                        if (!fc.isEmpty) {
//                            Text(fc)
//                        }
                        GradeBadgeView(grade: entry.grade)
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

struct RatingBannerView_Previews: PreviewProvider {
    static var previews: some View {
        RatingBannerView(user: CFQNUser())
    }
}
