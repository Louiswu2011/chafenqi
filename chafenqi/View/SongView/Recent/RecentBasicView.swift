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
            let requestURL = mode == 0 ? ChunithmDataGrabber.getSongCoverUrl(source: chunithmCoverSource, musicId: String(chunithmSong?.musicId ?? 0)) : MaimaiDataGrabber.getSongCoverUrl(source: maimaiCoverSource, coverId: getCoverNumber(id: String(maimaiSong?.musicId ?? "0")))
            
            
            
            SongCoverView(coverURL: requestURL, size: 80, cornerRadius: 10, withShadow: false)
                .overlay(RoundedRectangle(cornerRadius: 10)
                    .stroke(colorScheme == .dark ? .white.opacity(0.33) : .black.opacity(0.33), lineWidth: 1))
            
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
                        .font(.system(size: 15))
                    
                    HStack(alignment: .center) {
                        Text(chunithmRecord.score)
                            .font(.system(size: 23))
                            .bold()
                            .frame(width: 110, alignment: .leading)
                        if (chunithmRecord.fc_status != "clear") {
                            InfoBadge(badgeColor: chunithmRecord.getFCBadgeColor(), text: chunithmRecord.getDescribingStatus())
                        }
                    }
                } else {
                    HStack {
                        let diff = maimaiRecord.diff.uppercased()
                        
                        if(diff == "REMASTER") {
                            Text(maimaiRecord.getDateString())
                                .font(.system(size: 14))
                                .lineLimit(2)
                        } else {
                            Text(maimaiRecord.getDateString())
                                .font(.system(size: 15))
                        }
                        Spacer()
                        Text(diff == "REMASTER" ? "Re:Master" : diff)
                            .foregroundColor(maimaiLevelColor[maimaiRecord.getLevelIndex()])
                    }
                    
                    Spacer()
                    Text(maimaiSong?.title ?? "")
                        .font(.system(size: 18))
                    
                    HStack(alignment: .center) {
                        Text(maimaiRecord.achievement)
                            .font(.system(size: 23))
                            .bold()
                            .frame(width: 130, alignment: .leading)
                        if (maimaiRecord.fc_status != nil) {
                            InfoBadge(badgeColor: maimaiRecord.getFCBadgeColor(), text: maimaiRecord.getDescribingStatus())
                        }
                    }
                }
            }
        }
        .onAppear {
            if (mode == 0) {
                
            }
        }
        .frame(height: 80)
        .padding(.vertical, 5)
    }
}

struct InfoBadge: View {
    var badgeColor: Color
    var text: String
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .foregroundColor(badgeColor)
            
            Text(text)
                .font(.system(size: 15))
                .bold()
                .foregroundColor(.white)
        }
        .frame(width: 40, height: 20)
    }
}
