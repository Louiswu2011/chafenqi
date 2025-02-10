//
//  SongItemView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/5/8.
//

import SwiftUI

struct SongItemView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @ObservedObject var user: CFQNUser
    
    @State var finishedLoading = false
    
    @State var maiSong: MaimaiSongData?
    @State var chuSong: ChunithmMusicData?
    
    @State var requestURL = URL(string: "http://127.0.0.1")
    @State var title = ""
    @State var artist = ""
    @State var strip = LevelStripView(mode: 0, levels: ["1", "2", "3", "4"])
    @State var dx = false

    
    var body: some View {
        HStack {
            if (finishedLoading) {
                NavigationLink {
                    if let song = chuSong {
                        SongDetailView(user: user, chuSong: song)
                    } else if let song = maiSong {
                        SongDetailView(user: user, maiSong: song)
                    }
                } label: {
                    HStack {
                        SongCoverView(coverURL: requestURL!, size: 80, cornerRadius: 10, withShadow: false, rainbowStroke: dx)
                            .overlay(RoundedRectangle(cornerRadius: 10)
                                .stroke(colorScheme == .dark ? .white.opacity(0.33) : .black.opacity(0.33), lineWidth: 1))
                        VStack(alignment: .leading) {
                            Text(title)
                                .font(.system(size: 20))
                                .bold()
                                .lineLimit(1)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(artist)
                                .font(.system(size: 15))
                                .lineLimit(1)
                            Spacer()
                            if chuSong != nil && chuSong!.charts.worldsend.enabled {
                                Text(chuSong!.charts.levels.last ?? "")
                                    .padding(.bottom, 5)
                            } else {
                                strip
                                    .padding(.bottom, 5)
                            }
                        }
                    }
                }
            }
        }
        .onAppear {
            finishedLoading = false
            loadVar()
            finishedLoading = true
        }
        .navigationTitle("歌曲列表")
    }
    
    func loadVar() {
        if let song = maiSong {
            requestURL = MaimaiDataGrabber.getSongCoverUrl(source: user.chunithmCoverSource, coverId: song.coverId)
            title = song.title
            artist = song.basicInfo.artist
            strip = LevelStripView(mode: 1, levels: song.level)
            dx = song.type == "DX" && user.data.maimai.songlist.filter { $0.title == song.title }.count > 1
        } else if let song = chuSong {
            requestURL = ChunithmDataGrabber.getSongCoverUrl(source: user.chunithmCoverSource, musicId: String(song.musicID))
            title = song.title
            artist = song.artist
            strip = LevelStripView(mode: 0, levels: song.charts.levels)
        }
    }
}

struct SongItemView_Previews: PreviewProvider {
    static var previews: some View {
        SongItemView(user: CFQNUser())
    }
}
