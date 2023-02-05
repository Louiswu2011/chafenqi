//
//  MaimaiMiniView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/4.
//

import SwiftUI

struct MaimaiMiniView: View {
    let song: MaimaiRecordEntry
    
    @AppStorage("settingsMaimaiCoverSource") var coverSource = 0
    
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
                let requestURL = URL(string: "https://www.diving-fish.com/covers/\(getCoverNumber(id: String(song.musicId))).png")
                
                SongCoverView(coverURL: requestURL!, size: 80, cornerRadius: 10)
                
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

struct MaimaiMiniView_Previews: PreviewProvider {
    static var previews: some View {
        MaimaiMiniView(song: MaimaiRecordEntry(achievements: 101.00, constant: 15.00, dxScore: 1323, status: "app", syncStatus: "fsdp", level: "15", levelIndex: 3, levelLabel: "Master", rating: 211, rate: "sssp", musicId: 11253, title: "panduola", type: "DX"))
    }
}
