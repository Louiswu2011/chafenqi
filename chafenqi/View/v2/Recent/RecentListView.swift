//
//  RecentListView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/5/7.
//

import SwiftUI

struct RecentListView: View {
    @ObservedObject var user: CFQNUser
    
    var body: some View {
        ScrollView {
            VStack {
                if (user.currentMode == 0) {
                    ForEach(user.chunithm.recent, id: \.timestamp) { entry in
                        NavigationLink {
                            
                        } label: {
                            HStack {
                                SongCoverView(coverURL: ChunithmDataGrabber.getSongCoverUrl(source: user.chunithmCoverSource, musicId: String(entry.associatedSong!.musicId)), size: 65, cornerRadius: 5)
                                    .padding(.trailing, 5)
                                Spacer()
                                VStack {
                                    HStack {
                                        Text(entry.timestamp.customDateString)
                                        Spacer()
                                        // TODO: Add badges here
                                    }
                                    Spacer()
                                    HStack(alignment: .bottom) {
                                        Text(entry.title)
                                            .font(.system(size: 17))
                                            .lineLimit(2)
                                        Spacer()
                                        Text("\(entry.score)")
                                            .font(.system(size: 21))
                                            .bold()
                                    }
                                }
                            }
                        }
                        .buttonStyle(.plain)
                    }
                } else {
                    
                }
            }
            .padding()
        }
        .navigationTitle("最近动态")
    }
    
    
}

struct RecentListView_Previews: PreviewProvider {
    static var previews: some View {
        RecentListView(user: CFQNUser())
    }
}
