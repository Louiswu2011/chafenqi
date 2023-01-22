//
//  SongBasicInfoView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/8.
//

import SwiftUI
import CachedAsyncImage

// https://gitee.com/louiswu2011/chunithm-cover/raw/master/image/99.png

let data = """
{"id": 45, "title": "L9", "ds": [3.0, 5.0, 10.0, 12.4, 13.7], "level": ["3", "5", "10", "12"], "cids": [1, 2, 3, 4, 5], "charts": [{"combo": 333, "charter": "\\u30ed\\u30b7\\u30a7\\uff20\\u30da\\u30f3\\u30ae\\u30f3"}, {"combo": 541, "charter": "Jack"}, {"combo": 1051, "charter": "Techno Kitchen"}, {"combo": 960, "charter": "\\u30ed\\u30b7\\u30a7\\uff20\\u30da\\u30f3\\u30ae\\u30f3"}, {"combo": 1626, "charter": "Redarrow"}], "basic_info": {"title": "B.B.K.K.B.K.K.", "artist": "paraoke", "genre": "VARIETY", "bpm": 170, "from": "CHUNITHM"}}
""".data(using: .utf8)
let tempSongData = try! JSONDecoder().decode(SongData.self, from: data!)

struct SongBasicInfoView: View {
    
    let song: SongData

    @AppStorage("settingsCoverSource") var coverSource = ""
    @State private var showingChartConstant = false
    
    var body: some View {
        HStack() {
            let requestURL = coverSource == "Github" ? URL(string: "https://raw.githubusercontent.com/Louiswu2011/Chunithm-Song-Cover/main/images/\(song.id).png") : URL(string: "https://gitee.com/louiswu2011/chunithm-cover/raw/master/image/\(song.id).png")
            
            CachedAsyncImage(url: requestURL){ phase in
                if let image = phase.image {
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                    
                } else if let error = phase.error {
                    Color.red
                        .task {
                            print(error)
                        }
                } else {
                    ProgressView()
                }
            }
                // .resizable()
                // .scaledToFit()
                .cornerRadius(10.0)
                // .padding([.top, .bottom, .trailing], 8.0)
                // .frame(width: 130, height: 130)
                // .foregroundColor(.accentColor)
                .shadow(color: .black,radius: 1)
                // .border(Color.accentColor.opacity(0.5))
            
//            RemoteImageView(
//                url: URL(string: "https://gitee.com/louiswu2011/chunithm-cover/raw/master/image/\(song.id).png")!,
//                placeholder: {
//                    ProgressView()
//                }, image: {
//                    Image(uiImage: $0).resizable()
//                })

            
            HStack{
                VStack(alignment: .leading) {
                    Text(song.title)
                        .font(.title2)
                        .bold()
                    // .scaledToFit()
                        // .border(Color.black)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .textSelection(.enabled)
                    
                    Text(song.basicInfo.artist)
                        .font(.title3)
                    // .scaledToFit()
                        // .border(Color.black)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                        .textSelection(.enabled)
                    
                    Spacer()
                    
                    HStack {
                        if (showingChartConstant) {
                            if (song.constant.count == 6) {
                                Text("\(song.constant[5], specifier: "%.1f")")
                            } else if (song.level.count == 1) {
                                Text("\(song.constant[0], specifier: "%.1f")")
                            } else {
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
                                }
                            }
                        } else { 
                            if (song.level.count == 6) {
                                Text(song.level[5])
                            } else if (song.level.count == 1) {
                                Text(song.level[0])
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
                                }
                            }
                        }
                    }
                    .onTapGesture {
                        showingChartConstant.toggle()
                    }
                    
                }
                // .frame(maxWidth: 200)
                // .border(Color.blue)
                
                // Spacer()
            }

            // Spacer()
        }
        // .frame(width: 300, height: 90)
        // .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
        // .padding()
        // .border(Color.black)
        // .background(Color(dominantColor[1]).opacity(0.7))
        // .cornerRadius(10.0)
        
        
    }
}



struct SongBasicInfoView_Previews: PreviewProvider {
    static var previews: some View {
        SongBasicInfoView(song: tempSongData)
    }
}
