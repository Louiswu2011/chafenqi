//
//  MaimaiSongBasicView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/3.
//

import SwiftUI

let tempMaiJSON = """
{
      "id": "11222",
      "title": "BREaK! BREaK! BREaK!",
      "type": "DX",
      "ds": [
        6,
        8.5,
        12.8,
        14.7
      ],
      "level": [
        "6",
        "8",
        "12+",
        "14+"
      ],
      "cids": [
        5996,
        5997,
        5998,
        5999
      ],
      "charts": [
        {
          "notes": [
            172,
            10,
            8,
            0,
            17
          ],
          "charter": "-"
        },
        {
          "notes": [
            321,
            17,
            14,
            26,
            36
          ],
          "charter": "-"
        },
        {
          "notes": [
            513,
            65,
            42,
            55,
            57
          ],
          "charter": "サファ太"
        },
        {
          "notes": [
            797,
            76,
            121,
            62,
            50
          ],
          "charter": "サファ太 vs -ZONE- SaFaRi"
        }
      ],
      "basic_info": {
        "title": "BREaK! BREaK! BREaK!",
        "artist": "HiTECH NINJA vs Cranky",
        "genre": "maimai",
        "bpm": 165,
        "release_date": "",
        "from": "maimai でらっくす Splash",
        "is_new": false
      }
    }
""".data(using: .utf8)

let tempMaimaiSong = try! JSONDecoder().decode(MaimaiSongData.self, from: tempMaiJSON!)

struct MaimaiBasicView: View {
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
                    print(getCoverNumber(id: song.musicId))
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
                    .onTapGesture {
                        showingChartConstant.toggle()
                    }
                }
            }
        }
        
    }
    
    
}


struct MaimaiSongBasicView_Previews: PreviewProvider {
    static var previews: some View {
        MaimaiBasicView(song: tempMaimaiSong)
    }
}
