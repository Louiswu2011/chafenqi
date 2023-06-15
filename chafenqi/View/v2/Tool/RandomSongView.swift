//
//  RandomSongView.swift
//  chafenqi
//
//  Created by xinyue on 2023/6/15.
//

import SwiftUI
import CardStack

struct RandomSongView: View {
    @ObservedObject var user: CFQNUser
    
    @State private var refreshTokenM = UUID()
    @State private var refreshTokenC = UUID()
    
    @State private var maiSongs = [MaimaiSongData]()
    @State private var chuSongs = [ChunithmMusicData]()
    
    @State private var currentMaiSong: MaimaiSongData?
    @State private var currentChuSong: ChunithmMusicData?
    
    var body: some View {
        VStack {
            if user.currentMode == 0 {
                CardStack(
                    direction: LeftRight.direction,
                    data: chuSongs,
                    onSwipe: { data, direction in
                        appendChunithm(1)
                    },
                    content: { data, direction, isOnTop in
                        SongThumbnailView(user: user, chuSong: data, coverURL: data.coverURL, mode: 0, title: data.title, artist: data.artist, levels: data.charts.levels)
                            
                    })
                .scaledToFit()
                .padding()
                .id(refreshTokenC)
            } else if user.currentMode == 1 {
                CardStack(
                    direction: FourDirections.direction,
                    data: maiSongs,
                    onSwipe: { data, direction in
                        appendMaimai(1)
                    },
                    content: { data, direction, isOnTop in
                        SongThumbnailView(user: user, maiSong: data, coverURL: data.coverURL, mode: 1, title: data.title, artist: data.basicInfo.artist, levels: data.level)
                    })
                .scaledToFit()
                .padding()
                .id(refreshTokenM)
            }
            Spacer()
        }
        .navigationTitle("随机歌曲")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if user.currentMode == 0 {
                appendChunithm(5)
                currentChuSong = chuSongs.first
            } else if user.currentMode == 1 {
                appendMaimai(5)
                currentMaiSong = maiSongs.first
            }
        }
    }
    
    func appendMaimai(_ times: Int) {
        maiSongs.append(contentsOf: user.data.maimai.songlist[randomPick: times])
    }
    
    func appendChunithm(_ times: Int) {
        chuSongs.append(contentsOf: user.data.chunithm.musics[randomPick: times])
    }
}

struct SongThumbnailView: View {
    @Environment(\.managedObjectContext) var context
    
    @ObservedObject var user: CFQNUser
    @State var chuSong: ChunithmMusicData?
    @State var maiSong: MaimaiSongData?
    
    @State var coverURL: URL
    @State var mode: Int
    @State var title: String
    @State var artist: String
    @State var levels: [String]
    
    var body: some View {
        VStack {
            ZStack {
                AsyncImage(url: coverURL, context: context, placeholder: {
                    ProgressView()
                        .clipped()
                }, image: { img in
                    Image(uiImage: img)
                        .resizable()
                })
                
                VStack {
                    HStack {
                        Spacer()
                        NavigationLink {
                            if let song = chuSong {
                                SongDetailView(user: user, chuSong: song)
                            } else if let song = maiSong {
                                SongDetailView(user: user, maiSong: song)
                            }
                        } label: {
                            Image(systemName: "arrowshape.turn.up.right.circle")
                                .resizable()
                                .foregroundColor(.blue)
                                .frame(width: 30, height: 30)
                                .background(Circle().fill(.white))
                        }
                    }
                    Spacer()
                }
                .padding()
            }
            .clipped()
            .aspectRatio(contentMode: .fill)
            HStack {
                VStack(alignment: .leading) {
                    Text(title)
                        .bold()
                        .lineLimit(1)
                    Text(artist)
                        .font(.caption)
                        .lineLimit(1)
                }
                Spacer()
                LevelStripView(mode: mode, levels: levels)
            }
            .padding([.horizontal, .bottom])
        }
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 4)
    }
}


extension Array {
    /// Picks `n` random elements (partial Fisher-Yates shuffle approach)
    subscript (randomPick n: Int) -> [Element] {
        var copy = self
        for i in stride(from: count - 1, to: count - n - 1, by: -1) {
            copy.swapAt(i, Int(arc4random_uniform(UInt32(i + 1))))
        }
        return Array(copy.suffix(n))
    }
}
