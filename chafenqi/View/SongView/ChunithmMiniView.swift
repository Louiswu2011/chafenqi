//
//  SongMiniInfoView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/18.
//

import SwiftUI
import CachedAsyncImage

let song: ScoreEntry = ScoreEntry(chartId: 3, constant: 14.5, status: "alljustice", level: "14", levelIndex: 2, levelLabel: "MASTER", musicId: 3, rating: 14.75, score: 1010000, title: "Test")

struct ChunithmMiniView: View {
    @Environment(\.colorScheme) var colorScheme
    
    let song: ScoreEntry
    
    @ObservedObject var user: CFQUser
    
    var body: some View {
        ZStack{
            let clearBadgeColor = song.getClearBadgeColor()
            
            VStack(spacing: 2) {
                if (clearBadgeColor != Color.red) {
                    HStack {
                        Spacer()
                        
                        Text(song.getStatus())
                            .font(.system(size: 22))
                            .foregroundColor(clearBadgeColor)
                            .padding(.trailing, 8)
                    }
                    
                    
                    Rectangle()
                        .frame(width: 190, height: 8)
                        .foregroundColor(clearBadgeColor.opacity(0.8))
                    
                    
                    Spacer()
                }
            }
            .padding(.top, 6)
            

            
            
            HStack {
                SongCoverView(coverURL: ChunithmDataGrabber.getSongCoverUrl(source: user.chunithmCoverSource, musicId: String(song.musicId)), size: 80, cornerRadius: 10)
                
                VStack(alignment: .leading) {
                    Spacer()
                    
                    if(colorScheme == .light && song.levelIndex == 4) {
                        Text(String(song.score))
                            .font(.title3)
                            .foregroundColor(.white)
                            .bold()
                        Text("\(song.rating, specifier: "%.2f")/\(song.constant, specifier: "%.1f")")
                            .foregroundColor(.white)
                    } else {
                        Text(String(song.score))
                            .font(.title3)
                            .bold()
                        Text("\(song.rating, specifier: "%.2f")/\(song.constant, specifier: "%.1f")")
                    }
                    // Text("\(song.getGrade())/\(song.getStatus())")
                }
                .frame(height: 80)
            }
        }
        
        .frame(width: 190, height: 100)
        .background(chunithmLevelColor[song.levelIndex])
        .cornerRadius(10)
        // .border(.black)
            
    }
}

