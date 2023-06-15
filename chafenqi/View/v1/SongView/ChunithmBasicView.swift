//
//  SongBasicInfoView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/8.
//

import SwiftUI
import CachedAsyncImage

// https://gitee.com/louiswu2011/chunithm-cover/raw/master/image/99.png



struct ChunithmBasicView: View {
    
    let song: ChunithmSongData
    
    @Environment(\.colorScheme) var colorScheme

    @AppStorage("settingsChunithmCoverSource") var coverSource = 0
    
    @State private var showingChartConstant = false
    
    var body: some View {
        HStack() {
            let requestURL = coverSource == 0 ? URL(string: "https://raw.githubusercontent.com/Louiswu2011/Chunithm-Song-Cover/main/images/\(song.musicId).png") : URL(string: "https://gitee.com/louiswu2011/chunithm-cover/raw/master/image/\(song.musicId).png")
            
            SongCoverView(coverURL: requestURL!, size: 80, cornerRadius: 10, withShadow: false)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(colorScheme == .dark ? .white.opacity(0.33) : .black.opacity(0.33), lineWidth: 1)
                }
            
            HStack{
                VStack(alignment: .leading) {
                    Text(song.title)
                        .font(.system(size: 20))
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)
                        .textSelection(.enabled)
                    
                    Text(song.basicInfo.artist)
                        .font(.system(size: 15))
                        .lineLimit(1)
                        .textSelection(.enabled)
                    
                    Spacer()
                    
                    
                    LevelStripView(mode: 0, levels: song.level)
                    
                    
                }
            }
        }
    }
}



struct SongBasicInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ChunithmListView()
    }
}
