//
//  RecentDetailView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/19.
//

import SwiftUI

struct RecentDetailView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("settingsMaimaiCoverSource") var maimaiCoverSource = 0
    @AppStorage("settingsChunithmCoverSoruce") var chunithmCoverSource = 0
    
    var chuSong: ChunithmSongData? = nil
    var maiSong: MaimaiSongData? = nil
    
    var chuRecord = ChunithmRecentRecord.shared
    var maiRecord = MaimaiRecentRecord.shared
    
    var mode = 0
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    let requestURL = mode == 0 ? chunithmCoverSource == 0 ? URL(string: "https://raw.githubusercontent.com/Louiswu2011/Chunithm-Song-Cover/main/images/\(chuSong!.musicId).png") : URL(string: "https://gitee.com/louiswu2011/chunithm-cover/raw/master/image/\(chuSong!.musicId).png") : URL(string: "https://www.diving-fish.com/covers/\(getCoverNumber(id: maiSong!.musicId )).png")
                    
                    let title = mode == 0 ? chuRecord.title : maiRecord.title
                    let artist = mode == 0 ? chuSong!.basicInfo.artist : maiSong!.basicInfo.artist
                    let playTime = mode == 0 ? chuRecord.getDateString() : maiRecord.getDateString()
                    let difficulty = mode == 0 ? chuRecord.diff.uppercased() : maiRecord.diff.uppercased()
                    let diffColor = mode == 0 ? chunithmLevelColor[chuRecord.getLevelIndex()]! : maimaiLevelColor[maiRecord.getLevelIndex()]!
                    let score = mode == 0 ? chuRecord.score : maiRecord.achievement
                    
                    SongCoverView(coverURL: requestURL!, size: 120, cornerRadius: 10, withShadow: false)

                    VStack(alignment: .leading) {
                        Text(difficulty)
                            .foregroundColor(diffColor)
                            .font(.system(size: 18))
                            .frame(alignment: .trailing)
                        Spacer()
                        Text(title)
                            .font(.title)
                            .bold()
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                        Text(artist)
                            .font(.title2)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    
                    Spacer()
                }
                
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct RecentDetailView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(currentTab: .constant(.recent))
    }
}
