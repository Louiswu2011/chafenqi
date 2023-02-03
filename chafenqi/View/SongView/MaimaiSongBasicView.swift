//
//  MaimaiSongBasicView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/3.
//

import SwiftUI

let tempMaiJSON = """
{
      "id": "8",
      "title": "True Love Song",
      "type": "DX",
      "ds": [
        4,
        6.4,
        9.2,
        11.7
      ],
      "level": [
        "4",
        "6",
        "9",
        "11+"
      ],
      "cids": [
        1,
        2,
        3,
        4
      ],
      "charts": [
        {
          "notes": [
            63,
            23,
            8,
            2
          ],
          "charter": "-"
        },
        {
          "notes": [
            85,
            27,
            6,
            4
          ],
          "charter": "-"
        },
        {
          "notes": [
            110,
            56,
            9,
            2
          ],
          "charter": "譜面-100号"
        },
        {
          "notes": [
            263,
            14,
            19,
            6
          ],
          "charter": "ニャイン"
        }
      ],
      "basic_info": {
        "title": "True Love Song",
        "artist": "Kai/クラシック「G線上のアリア」",
        "genre": "maimai",
        "bpm": 150,
        "release_date": "",
        "from": "maimai",
        "is_new": false
      }
    }
""".data(using: .utf8)

let tempMaimaiSong = try! JSONDecoder().decode(MaimaiSongData.self, from: tempMaiJSON!)

struct MaimaiSongBasicView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showingChartConstant = false
    
    var song: MaimaiSongData
    
    var body: some View {
        HStack() {
            let requestURL = URL(string: "https://www.diving-fish.com/covers/\(getCoverNumber(id: song.musicId)).png")
            
            SongCoverView(coverURL: requestURL!, size: 80, cornerRadius: 10, withShadow: false)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(colorScheme == .dark ? .white.opacity(0.33) : .black.opacity(0.33), lineWidth: 1)
                }
                .onTapGesture {
                    print(song.musicId)
                }
            
            HStack{
                VStack(alignment: .leading) {
                    Text(song.title)
                        .font(.title2)
                        .bold()
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .textSelection(.enabled)
                    
                    Text(song.basicInfo.artist)
                        .font(.title3)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .textSelection(.enabled)
                    
                    Spacer()
                    
                    HStack {
                        if (showingChartConstant) {
                            Text("\(song.constant[0], specifier: "%.1f")")
                                .foregroundColor(Color.green)
                            Text("\(song.constant[1], specifier: "%.1f")")
                                .foregroundColor(Color.yellow)
                            Text("\(song.constant[2], specifier: "%.1f")")
                                .foregroundColor(Color.red)
                            Text("\(song.constant[3], specifier: "%.1f")")
                                .foregroundColor(Color.purple)
                            if (song.level.count == 5) {
                                Text("\(song.constant[4], specifier: "%.1f")")
                                    .foregroundColor(Color.purple.opacity(0.5))
                            }
                            
                        } else {
                            Text(song.level[0])
                                .foregroundColor(Color.green)
                            Text(song.level[1])
                                .foregroundColor(Color.yellow)
                            Text(song.level[2])
                                .foregroundColor(Color.red)
                            Text(song.level[3])
                                .foregroundColor(Color.purple)
                            if (song.level.count == 5) {
                                Text(song.level[4])
                                    .foregroundColor(Color.purple.opacity(0.5))
                            }
                        }
                        
                        if(song.type == "DX") {
                            Text("DX")
                        }
                    }
                }
                .onTapGesture {
                    showingChartConstant.toggle()
                }
            }
        }
        
    }
    
    func getCoverNumber(id: String) -> String {
        if (id.count == 5) {
            return String(id[id.index(after: id.startIndex)..<id.endIndex])
        } else {
            return String(format: "%04d", Int(id)!)
        }
    }
}

struct MaimaiSongBasicView_Previews: PreviewProvider {
    static var previews: some View {
        MaimaiSongBasicView(song: tempMaimaiSong)
    }
}
