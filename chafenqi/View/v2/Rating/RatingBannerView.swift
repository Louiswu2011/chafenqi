//
//  RatingBannerView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/5/9.
//

import SwiftUI

struct MaimaiRatingBannerView: View {
    @ObservedObject var user: CFQNUser
    
    var index: Int
    var entry: UserMaimaiBestScoreEntry
    
    var body: some View {
        HStack {
            SongCoverView(coverURL: MaimaiDataGrabber.getSongCoverUrl(source: 1, coverId: entry.associatedSong?.coverId ?? 0), size: 50, cornerRadius: 5, diffColor: maimaiLevelColor[entry.levelIndex])
                .padding(.trailing, 5)
            Group {
                VStack(alignment: .leading) {
                    HStack {
                        let constant = entry.associatedSong?.constants[entry.levelIndex] ?? 0.0
                        Text("#\(index)")
                            .frame(width: 35, alignment: .leading)
                        Text("\(constant, specifier: "%.1f")/\(entry.rating)")
                            .bold()
                            .frame(width: 90, alignment: .leading)
                    }
                    Spacer()
                    Text("\(entry.associatedSong?.title ?? "")")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Spacer()
                VStack(alignment: .trailing) {
                    HStack {
                        // Text("\(entry.fc)")
                        GradeBadgeView(grade: entry.rateString)
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

struct ChunithmRatingBannerView: View {
    @ObservedObject var user: CFQNUser
    
    var index: Int
    var entry: UserChunithmRatingListEntry
    
    var body: some View {
        HStack {
            SongCoverView(coverURL: ChunithmDataGrabber.getSongCoverUrl(source: 1, musicId: String(entry.associatedBestEntry!.associatedSong!.musicID)), size: 50, cornerRadius: 5, diffColor: chunithmLevelColor[entry.levelIndex])
                .padding(.trailing, 5)
            Group {
                VStack(alignment: .leading) {
                    HStack {
                        let constant = entry.associatedBestEntry!.associatedSong!.charts.constants[entry.associatedBestEntry!.levelIndex]
                        Text("#\(index)")
                            .frame(width: 35, alignment: .leading)
                        Text("\(constant, specifier: "%.1f")/\(DataTool.shared.numberFormatter.string(from: entry.rating as NSNumber) ?? "0.00")")
                            .bold()
                            .frame(width: 90, alignment: .leading)
                    }
                    Spacer()
                    Text("\(entry.associatedBestEntry?.associatedSong?.title ?? "")")
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
