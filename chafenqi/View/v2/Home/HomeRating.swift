//
//  HomeRating.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/5/9.
//

import SwiftUI

struct HomeRating: View {
    @ObservedObject var user: CFQNUser
    
    var body: some View {
        VStack {
            HStack {
                Text("Rating分析")
                    .font(.system(size: 20))
                    .bold()
                Spacer()
                
                NavigationLink {
                    RatingListView(user: user)
                } label: {
                    Text("显示全部")
                        .font(.system(size: 18))
                }
            }
            
            if user.currentMode == 0 && user.chunithm.custom.b30Slice.count > 0 {
                RatingShortLook(user: user, length: min(30, user.chunithm.custom.b30Slice.count), coverUrl: ChunithmDataGrabber.getSongCoverUrl(source: 0, musicId: user.chunithm.custom.b30Slice.first?.idx ?? "1"))
                    .frame(width: UIScreen.main.bounds.size.width - 30)
            } else if user.currentMode == 1 && user.maimai.custom.pastSlice.count > 0 {
                RatingShortLook(user: user, length: min(50, user.maimai.custom.pastSlice.count + user.maimai.custom.currentSlice.count), coverUrl: MaimaiDataGrabber.getSongCoverUrl(source: 0, coverId: user.maimai.custom.pastSlice.first?.associatedSong?.musicId ?? 0))
                    .frame(width: UIScreen.main.bounds.size.width - 30)
            }
        }
        .padding()
    }
}

struct HomeRating_Previews: PreviewProvider {
    static var previews: some View {
        HomeRating(user: CFQNUser())
    }
}
