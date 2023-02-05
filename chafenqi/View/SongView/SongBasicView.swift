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

let data = """
{"id": 749, "title": "Fracture Ray", "ds": [3.0, 5.0, 10.0, 12.4, 13.7], "level": ["3", "5", "10", "12"], "cids": [1, 2, 3, 4, 5], "charts": [{"combo": 333, "charter": "\\u30ed\\u30b7\\u30a7\\uff20\\u30da\\u30f3\\u30ae\\u30f3"}, {"combo": 541, "charter": "Jack"}, {"combo": 1051, "charter": "Techno Kitchen"}, {"combo": 960, "charter": "\\u30ed\\u30b7\\u30a7\\uff20\\u30da\\u30f3\\u30ae\\u30f3"}, {"combo": 1626, "charter": "Redarrow"}], "basic_info": {"title": "B.B.K.K.B.K.K.", "artist": "paraoke", "genre": "VARIETY", "bpm": 170, "from": "CHUNITHM"}}
""".data(using: .utf8)
let tempSongData = try! JSONDecoder().decode(ChunithmSongData.self, from: data!)

struct SongBasicView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("settingsChunithmCoverSource") var chunithmCoverSource = 0
    @AppStorage("settingsMaimaiCoverSource") var maimaiCoverSource = 0
    @AppStorage("settingsCurrentMode") var mode = 0
    
    var maimaiSong: MaimaiSongData = tempMaimaiSong
    var chunithmSong: ChunithmSongData = tempSongData
    
    
    var body: some View {
        HStack() {
            let requestURL = mode == 0 ? chunithmCoverSource == 0 ? URL(string: "https://raw.githubusercontent.com/Louiswu2011/Chunithm-Song-Cover/main/images/\(chunithmSong.musicId).png") : URL(string: "https://gitee.com/louiswu2011/chunithm-cover/raw/master/image/\(chunithmSong.musicId).png") : URL(string: "https://www.diving-fish.com/covers/\(getCoverNumber(id: maimaiSong.musicId)).png")
            
            
            
            SongCoverView(coverURL: requestURL!, size: 80, cornerRadius: 10, withShadow: false)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(colorScheme == .dark ? .white.opacity(0.33) : .black.opacity(0.33), lineWidth: 1)
                }
            
            
            VStack(alignment: .leading) {
                Text(mode == 0 ? chunithmSong.basicInfo.title : maimaiSong.basicInfo.title)
                    .font(.system(size: 20))
                    .bold()
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .textSelection(.enabled)
                
                
                Text(mode == 0 ? chunithmSong.basicInfo.artist : maimaiSong.basicInfo.artist)
                    .font(.system(size: 15))
                    .lineLimit(1)
                    .textSelection(.enabled)
                
                Spacer()
                
                LevelStripView(mode: mode, levels: mode == 0 ? chunithmSong.level : maimaiSong.level)
                // .border(Color.blue)
                
                
                //                        if(song.type == "DX") {
                //                            Text("DX")
                //                        }
                
                
            }
        }
    }
}


struct MaimaiSongBasicView_Previews: PreviewProvider {
    static var previews: some View {
        MaimaiListView()
    }
}
