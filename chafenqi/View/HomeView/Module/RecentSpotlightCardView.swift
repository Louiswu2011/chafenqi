//
//  RecentSpotlightCardView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/3/10.
//

import SwiftUI

struct RecentSpotlightCardView: View {
    @AppStorage("settingsChunithmCoverSource") var chuSource = 0
    
    @State var recentRecord: ChunithmRecentRecord
    @State var spotlightType: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .foregroundColor(backgroundColor)
            
            VStack() {
                HStack {
                    SongCoverView(coverURL: ChunithmDataGrabber.getSongCoverUrl(source: chuSource, musicId: recentRecord.music_id), size: 100, cornerRadius: 5, withShadow: true)
                    
                    Spacer()
                    
                    Text(recentRecord.getGrade())
                        .font(.system(size: 25))
                        .bold()
                }
                .padding()
                .background(
                    Rectangle()
                        .foregroundColor(.white)
                        .frame(height: 80)
                        .shadow(radius: 5)
                )
                
                
                Text("\(Int(recentRecord.score)!)")
                    .font(.system(size: 30))
                    .bold()
                
                Spacer()
                
            }
            
            
            
        }
        .frame(width: 220, height: 300)
        .padding()

    }
    
    var backgroundColor: Color {
        getChunithmLevelColor(index: recentRecord.getLevelIndex())
    }
}

struct RecentSpotlightCardView_Previews: PreviewProvider {
    static var previews: some View {
        RecentSpotlightCardView(recentRecord: ChunithmRecentRecord.shared, spotlightType: "推分")
    }
}
