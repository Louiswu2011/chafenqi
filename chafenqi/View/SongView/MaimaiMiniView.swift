//
//  MaimaiMiniView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/4.
//

import SwiftUI

struct MaimaiMiniView: View {
    let song: MaimaiRecordEntry
    
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
                SongCoverView(coverURL: MaimaiDataGrabber.getSongCoverUrl(source: user.maimaiCoverSource, coverId: getCoverNumber(id: String(song.musicId))), size: 80, cornerRadius: 10)
                
                VStack(alignment: .leading) {
                    Spacer()
                    
                    
                    Text("\(song.achievements, specifier: "%.4f")%")
                        .font(.system(size: 16))
                        .bold()
                    
                    
                    Text("\(song.rating)/\(song.constant, specifier: "%.1f")")
                    // Text("\(song.getGrade())/\(song.getStatus())")
                }
                .frame(height: 80)
            }
        }
        
        .frame(width: 190, height: 100)
        .background(maimaiLevelColor[song.levelIndex])
        .cornerRadius(10)
        // .border(.black)
            
    }
}
