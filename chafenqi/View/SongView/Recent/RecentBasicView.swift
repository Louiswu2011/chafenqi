//
//  RecentMiniView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/19.
//

import SwiftUI

struct RecentBasicView: View {
    @Environment(\.colorScheme) var colorScheme
    
    
    @AppStorage("settingsMaimaiCoverSource") var maimaiCoverSource = 0
    @AppStorage("settingsChunithmCoverSoruce") var chunithmCoverSource = 0
    
    var maimaiSong: MaimaiSongData? = nil
    var chunithmSong: ChunithmSongData? = nil
    
    var maimaiRecord: MaimaiRecentRecord = MaimaiRecentRecord.shared
    var chunithmRecord: ChunithmRecentRecord = ChunithmRecentRecord.shared
    
    var mode = 0
    
    var body: some View {
        HStack() {
            let requestURL = mode == 0 ? chunithmCoverSource == 0 ? URL(string: "https://raw.githubusercontent.com/Louiswu2011/Chunithm-Song-Cover/main/images/\(chunithmSong!.musicId).png") : URL(string: "https://gitee.com/louiswu2011/chunithm-cover/raw/master/image/\(chunithmSong!.musicId).png") : URL(string: "https://www.diving-fish.com/covers/\(getCoverNumber(id: maimaiSong!.musicId )).png")
            
            
            
            SongCoverView(coverURL: requestURL!, size: 80, cornerRadius: 10, withShadow: false)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(colorScheme == .dark ? .white.opacity(0.33) : .black.opacity(0.33), lineWidth: 1)
                }
            
            VStack(alignment: .leading){
                if (mode == 0) {
                    HStack {
                        Text(chunithmRecord.getDateString())
                            .font(.system(size: 15))
                        Spacer()
                        Text(chunithmRecord.diff.uppercased())
                            .foregroundColor(chunithmLevelColor[chunithmRecord.getLevelIndex()])
                    }
                    
                    Spacer()
                    Text(chunithmSong?.title ?? "")
                        .font(.system(size: 18))
                    
                    HStack(alignment: .center) {
                        Text(chunithmRecord.score)
                            .font(.system(size: 25))
                            .bold()
                        Text(chunithmRecord.getGrade())
                            .font(.system(size: 20))
                            .bold()
                    }
                } else {
                    HStack {
                        Text(maimaiRecord.getDateString())
                            .font(.system(size: 15))
                        Spacer()
                        Text(maimaiRecord.diff.uppercased())
                            .foregroundColor(maimaiLevelColor[maimaiRecord.getLevelIndex()])
                    }
                    
                    Spacer()
                    Text(maimaiSong?.title ?? "")
                        .font(.system(size: 18))
                    
                    HStack(alignment: .center) {
                        Text(maimaiRecord.achievement)
                            .font(.system(size: 25))
                            .bold()
                        Text(maimaiRecord.getRate())
                            .font(.system(size: 20))
                            .bold()
                    }
                }
            }
        }
        .onAppear {
            if (mode == 0) {
                
            }
        }
        .frame(height: 80)
    }
}

struct RecentMiniView_Previews: PreviewProvider {
    static var previews: some View {
        RecentView()
    }
}
