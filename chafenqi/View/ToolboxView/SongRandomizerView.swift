//
//  SongRandomizerView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/1.
//

import SwiftUI
import CachedAsyncImage

struct SongRandomizerView: View {
    @AppStorage("loadedChunithmSongs") var loadedChunithmSongs: Data = Data()
    @AppStorage("didChunithmSongListLoaded") var didSongListLoaded = false
    @AppStorage("userChunithmInfoData") var userChunithmData = Data()
    @AppStorage("didLogin") var didLogin = false
    @AppStorage("settingsChunithmCoverSource") var coverSource = 0
    @AppStorage("settingsRandomizerFilterMode") var filterMode = 0
    @AppStorage("settingsMaimaiCoverSource") var maimaiCoverSource = 0
    @AppStorage("settingsCurrentMode") var currentMode = 0
    @AppStorage("userMaimaiInfoData") var userMaimaiData = Data()
    @AppStorage("loadedMaimaiSongs") var loadedMaimaiSongs: Data = Data()
    
    @State private var isSpinning = false
    @State private var showingConstant = false
    
    @State private var decodedChunithmSongs = Set<ChunithmSongData>()
    @State private var decodedMaimaiSongs = Set<MaimaiSongData>()
    
    @State private var randomChunithmSong = tempSongData
    @State private var randomMaimaiSong = tempMaimaiSong
    @State private var coverURL = URL(string: "https://raw.githubusercontent.com/Louiswu2011/Chunithm-Song-Cover/main/images/3.png")
    
    @State private var screenBounds = UIScreen.main.bounds
    @State var randomOnAppear: Bool = false
    
    var body: some View {
        
        VStack(alignment: .center) {
            SongCoverView(coverURL: coverURL!, size: 200, cornerRadius: 5)
            
            Text(currentMode == 0 ? randomChunithmSong.basicInfo.title : randomMaimaiSong.basicInfo.title)
                .bold()
                .font(.title)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .padding([.top, .horizontal])
            
            
            Text(currentMode == 0 ? randomChunithmSong.basicInfo.artist : randomMaimaiSong.basicInfo.artist)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding([.bottom, .horizontal])
            
            HStack {
                if (currentMode == 0) {
                    Text(showingConstant ? String(format: "%.1f", randomChunithmSong.constant[0]) : randomChunithmSong.level[0])
                        .foregroundColor(Color.green)
                        .font(.title3)
                    Text(showingConstant ? String(format: "%.1f", randomChunithmSong.constant[1]) : randomChunithmSong.level[1])
                        .foregroundColor(Color.yellow)
                        .font(.title3)
                    Text(showingConstant ? String(format: "%.1f", randomChunithmSong.constant[2]) : randomChunithmSong.level[2])
                        .foregroundColor(Color.red)
                        .font(.title3)
                    Text(showingConstant ? String(format: "%.1f", randomChunithmSong.constant[3]) : randomChunithmSong.level[3])
                        .foregroundColor(Color.purple)
                        .font(.title3)
                    if (randomChunithmSong.level.count == 5) {
                        Text(showingConstant ? String(format: "%.1f", randomChunithmSong.constant[4]) : randomChunithmSong.level[4])
                            .font(.title3)
                    }
                } else {
                    Text(showingConstant ? String(format: "%.1f", randomMaimaiSong.constant[0]) : randomMaimaiSong.level[0])
                        .foregroundColor(Color.green)
                        .font(.title3)
                    Text(showingConstant ? String(format: "%.1f", randomMaimaiSong.constant[1]) : randomMaimaiSong.level[1])
                        .foregroundColor(Color.yellow)
                        .font(.title3)
                    Text(showingConstant ? String(format: "%.1f", randomMaimaiSong.constant[2]) : randomMaimaiSong.level[2])
                        .foregroundColor(Color.red)
                        .font(.title3)
                    Text(showingConstant ? String(format: "%.1f", randomMaimaiSong.constant[3]) : randomMaimaiSong.level[3])
                        .foregroundColor(Color.purple)
                        .font(.title3)
                    if (randomMaimaiSong.level.count == 5) {
                        Text(showingConstant ? String(format: "%.1f", randomMaimaiSong.constant[4]) : randomMaimaiSong.level[4])
                            .foregroundColor(Color.purple.opacity(0.33))
                            .font(.title3)
                    }
                }
            }
            .onTapGesture {
                showingConstant.toggle()
            }
            
            HStack {
                Button {
                    if (currentMode == 0) {
                        randomChunithmSong = getChunithmRandomSong()
                    } else {
                        randomMaimaiSong = getMaimaiRandomSong()
                    }
                } label: {
                    Text("再来一首")
                    Image(systemName: "dice")
                }
                // .disabled(isSpinning)
                .padding(.horizontal)
                
                NavigationLink {
                    if (currentMode == 0) {
                        ChunithmDetailView(song: randomChunithmSong)
                    } else {
                        MaimaiDetailView(song: randomMaimaiSong)
                    }
                } label: {
                    Text("转到详情")
                    Image(systemName: "arrowshape.turn.up.right")
                }
                // .disabled(isSpinning)
                .padding(.horizontal)
            }
            .padding()
        }
        .onAppear {
            if randomOnAppear {
                if (currentMode == 0) {
                    filterChunithmSongList()
                    decodedChunithmSongs = try! JSONDecoder().decode(Set<ChunithmSongData>.self, from: loadedChunithmSongs)
                    randomChunithmSong = getChunithmRandomSong()
                    
                } else {
                    filterMaimaiSongList()
                    decodedMaimaiSongs = try! JSONDecoder().decode(Set<MaimaiSongData>.self, from: loadedMaimaiSongs)
                    randomMaimaiSong = getMaimaiRandomSong()
                }
                randomOnAppear = false
            }
        }
        .navigationTitle("随机歌曲")
        .navigationBarTitleDisplayMode(.inline)
        
    }
    
    func filterChunithmSongList() {
        guard didLogin else { return }
        
        let playedList = try! JSONDecoder().decode(ChunithmUserData.self, from: userChunithmData).records.best.compactMap { $0.musicID }
        
        switch (filterMode) {
        case 0:
            return
        case 1:
            decodedChunithmSongs = decodedChunithmSongs.filter { !playedList.contains($0.musicId) }
        default:
            decodedChunithmSongs = decodedChunithmSongs.filter { playedList.contains($0.musicId) }
        }
    }
    
    func filterMaimaiSongList() {
        guard didLogin else { return }
        
        let playedList = try! JSONDecoder().decode(MaimaiPlayerRecord.self, from: userMaimaiData).records.compactMap{ $0.musicId }
        
        switch (filterMode) {
        case 0:
            return
        case 1:
            decodedMaimaiSongs = decodedMaimaiSongs.filter { !playedList.contains( Int($0.musicId)!) }
        default:
            decodedMaimaiSongs = decodedMaimaiSongs.filter { !playedList.contains( Int($0.musicId)!) }
        }
    }
    
    func getChunithmRandomSong() -> ChunithmSongData {
        let randSong = decodedChunithmSongs.randomElement()!
        coverURL = coverSource == 0 ? URL(string: "https://raw.githubusercontent.com/Louiswu2011/Chunithm-Song-Cover/main/images/\(randSong.musicId).png") : URL(string: "https://gitee.com/louiswu2011/chunithm-cover/raw/master/image/\(randSong.musicId).png")
        return randSong
    }
    
    func getMaimaiRandomSong() -> MaimaiSongData {
        let randSong = decodedMaimaiSongs.randomElement()!
        coverURL = URL(string: "https://www.diving-fish.com/covers/\(getCoverNumber(id: randSong.musicId)).png")
        
        return randSong
    }
}

struct SongRandomizerView_Previews: PreviewProvider {
    static var previews: some View {
        SongRandomizerView()
    }
}
