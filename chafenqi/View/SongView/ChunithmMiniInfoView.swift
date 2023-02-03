//
//  SongMiniInfoView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/18.
//

import SwiftUI
import CachedAsyncImage

let song: ScoreEntry = ScoreEntry(chartID: 3, constant: 14.5, status: "alljustice", level: "14", levelIndex: 3, levelLabel: "MASTER", musicID: 3, rating: 14.75, score: 1010000, title: "Test")

struct ChunithmMiniInfoView: View {
    let song: ScoreEntry
    
    @AppStorage("settingsChunithmCoverSource") var coverSource = 0
    
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
                let requestURL = coverSource == 0 ? URL(string: "https://raw.githubusercontent.com/Louiswu2011/Chunithm-Song-Cover/main/images/\(song.musicID).png") : URL(string: "https://gitee.com/louiswu2011/chunithm-cover/raw/master/image/\(song.musicID).png")
                
                SongCoverView(coverURL: requestURL!, size: 80, cornerRadius: 10)
                
                VStack(alignment: .leading) {
                    Spacer()
                    
                    
                    Text(String(song.score))
                        .font(.title3)
                        .bold()
                    
                    
                    Text("\(song.rating, specifier: "%.2f")/\(song.constant, specifier: "%.1f")")
                    // Text("\(song.getGrade())/\(song.getStatus())")
                }
                .frame(height: 80)
            }
        }
        
        .frame(width: 190, height: 100)
        .background(song.getLevelColor().opacity(0.8))
        .cornerRadius(10)
        // .border(.black)
            
    }
}

struct ChunithmMiniInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ChunithmMiniInfoView(song: song)
    }
}

