//
//  SongMiniInfoView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/18.
//

import SwiftUI
import CachedAsyncImage

let song: UserScoreData.ScoreEntry = UserScoreData.ScoreEntry(chartID: 3, constant: 14.5, status: "AllJustice", level: "14", levelIndex: 3, levelLabel: "MASTER", musicID: 3, rating: 14.75, score: 1010000, title: "Test")

struct SongMiniInfoView: View {
    let song: UserScoreData.ScoreEntry
    
    @AppStorage("settingsCoverSource") var coverSource = ""
    
    var body: some View {
        HStack {
            let requestURL = coverSource == "Github" ? URL(string: "https://raw.githubusercontent.com/Louiswu2011/Chunithm-Song-Cover/main/images/\(song.musicID).png") : URL(string: "https://gitee.com/louiswu2011/chunithm-cover/raw/master/image/\(song.musicID).png")
            
            CachedAsyncImage(url: requestURL){ phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .cornerRadius(10)
                        .shadow(radius: 2)
                    
                } else if let error = phase.error {
                    Color.red
                        .task {
                            print(error)
                        }
                } else {
                    ProgressView()
                }
            }
            
            VStack(alignment: .leading) {
                Text(String(song.score))
                Text("\(song.rating, specifier: "%.2f")/\(song.constant, specifier: "%.1f")")
                Text("\(song.getGrade())/\(song.getStatus())")
            }
        }
        
        .frame(width: 190, height: 100)
        .background(song.getLevelColor().opacity(0.8))
        .cornerRadius(10)
        // .border(.black)
    }
}

struct SongMiniInfoView_Previews: PreviewProvider {
    static var previews: some View {
        SongMiniInfoView(song: song)
    }
}
