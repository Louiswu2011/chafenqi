//
//  SongRandomizerView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/1.
//

import SwiftUI
import CachedAsyncImage

struct SongRandomizerView: View {
    @AppStorage("loadedSongs") var loadedSongs: Data = Data()
    @AppStorage("didSongListLoaded") var didSongListLoaded = false
    @AppStorage("userInfoData") var userInfoData = Data()
    @AppStorage("didLogin") var didLogin = false
    @AppStorage("settingsCoverSource") var coverSource = 0
    @AppStorage("settingsRandomizerFilterMode") var filterMode = 0
    
    @State private var isSpinning = false
    @State private var showingConstant = false
    
    @State private var decodedLoadedSongs = Set<SongData>()
    
    @State private var randomSong = tempSongData
    @State private var coverURL = URL(string: "https://raw.githubusercontent.com/Louiswu2011/Chunithm-Song-Cover/main/images/3.png")
    
    @State private var screenBounds = UIScreen.main.bounds
    
    var body: some View {
        
        VStack(alignment: .center) {
            CachedAsyncImage(url: coverURL){ phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 200, height: 200)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                    
                } else if phase.error != nil {
                    Image(systemName: "questionmark.square")
                        .frame(width: 200, height: 200)
                } else {
                    ProgressView()
                        .frame(width: 200, height: 200)
                }
            }
            
            Text(randomSong.basicInfo.title)
                .bold()
                .font(.title)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
                .padding([.top, .horizontal])
            
            
            Text(randomSong.basicInfo.artist)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .padding([.bottom, .horizontal])
            
            HStack {
                Text(showingConstant ? String(format: "%.1f", randomSong.constant[0]) : randomSong.level[0])
                    .foregroundColor(Color.green)
                    .font(.title3)
                Text(showingConstant ? String(format: "%.1f", randomSong.constant[1]) : randomSong.level[1])
                    .foregroundColor(Color.yellow)
                    .font(.title3)
                Text(showingConstant ? String(format: "%.1f", randomSong.constant[2]) : randomSong.level[2])
                    .foregroundColor(Color.red)
                    .font(.title3)
                Text(showingConstant ? String(format: "%.1f", randomSong.constant[3]) : randomSong.level[3])
                    .foregroundColor(Color.purple)
                    .font(.title3)
                if (randomSong.level.count == 5) {
                    Text(showingConstant ? String(format: "%.1f", randomSong.constant[4]) : randomSong.level[4])
                        .font(.title3)
                }
            }
            .onTapGesture {
                showingConstant.toggle()
            }
            
            HStack {
                Button {
                    randomSong = getRandomSong()
                } label: {
                    Text("再来一首")
                    Image(systemName: "dice")
                }
                // .disabled(isSpinning)
                .padding(.horizontal)
                
                
                NavigationLink {
                    SongDetailView(song: randomSong)
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
            decodedLoadedSongs = try! JSONDecoder().decode(Set<SongData>.self, from: loadedSongs)
            filterSongList()
            randomSong = getRandomSong()
        }
        .navigationTitle("随机歌曲")
        .navigationBarTitleDisplayMode(.inline)
        
    }
    
    func filterSongList() {
        guard didLogin else { return }
        
        let playedList = try! JSONDecoder().decode(UserData.self, from: userInfoData).records.best.compactMap { $0.musicID }
        
        switch (filterMode) {
        case 0:
            return
        case 1:
            decodedLoadedSongs = decodedLoadedSongs.filter { !playedList.contains($0.id) }
        case 2:
            decodedLoadedSongs = decodedLoadedSongs.filter { playedList.contains($0.id) }
        default:
            return
        }
    }
    
    func getRandomSong() -> SongData {
        let randSong = decodedLoadedSongs.randomElement()!
        coverURL = coverSource == 0 ? URL(string: "https://raw.githubusercontent.com/Louiswu2011/Chunithm-Song-Cover/main/images/\(randSong.id).png") : URL(string: "https://gitee.com/louiswu2011/chunithm-cover/raw/master/image/\(randSong.id).png")
        return randSong
    }
}

struct SongRandomizerView_Previews: PreviewProvider {
    static var previews: some View {
        SongRandomizerView()
    }
}
