//
//  SongDetailView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/9.
//

import SwiftUI
import CachedAsyncImage

struct SongDetailView: View {
    
    @AppStorage("settingsCoverSource") var coverSource = ""
    
    @State private var isFavourite = false
    @State private var selectedDifficulty = "Master"
    @State private var availableDiffs: [String] = ["Master"]
    @State private var isLoading = true
    
    var song: SongData
    
    let converter = try! ChartIdConverter()
    
    var body: some View {
        let webChartId = try! converter.getWebChartId(musicId: song.id)
        
        let coverURL = coverSource == "Github" ? URL(string: "https://raw.githubusercontent.com/Louiswu2011/Chunithm-Song-Cover/main/images/\(song.id).png") : URL(string: "https://gitee.com/louiswu2011/chunithm-cover/raw/master/image/\(song.id).png")
        
        var difficultyString: String = {
            switch (selectedDifficulty) {
            case "Expert":
                return "exp"
            case "Master":
                return "mst"
            case "Ultima":
                return "ult"
            default:
                return "mst"
            }
        }()
        
        let barURL = URL(string: "https://sdvx.in/chunithm/\(webChartId.prefix(2))/bg/\(webChartId)bar.png")
        let bgURL = URL(string: "https://sdvx.in/chunithm/\(webChartId.prefix(2))/bg/\(webChartId)bg.png")
        let chartURL = URL(string: "https://sdvx.in/chunithm/\(webChartId.prefix(2))/obj/data\(webChartId)\(difficultyString).png")
        
        if (isLoading) {
            ProgressView()
                .task {
                    // availableDiffs = try! await converter.getAvailableDiffs(musicId: song.id)
                    isLoading.toggle()
                }
        } else {
            ScrollView {
                VStack {
                    HStack {
                        AsyncImage(url: coverURL) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                            } else if let error = phase.error {
                                Color.red
                            } else {
                                ProgressView()
                            }
                        }
                        .cornerRadius(15)
                        .shadow(radius: 2)
                        // .border(Color.black)
                        .frame(width: 120, height: 120)
                        .padding(.leading)
                        
                        VStack(alignment: .leading) {
                            Spacer()
                            
                            Text(song.title)
                                .font(.title)
                                .bold()
                            
                            Text(song.basicInfo.artist)
                                .font(.title2)
                        }
                        
                        Spacer()
                        
                        VStack {
                            Spacer()
                            
                            Button {
                                isFavourite.toggle()
                            } label: {
                                if (isFavourite) {
                                    Image(systemName: "heart.fill")
                                        .scaleEffect(1.2)
                                } else {
                                    Image(systemName: "heart")
                                        .scaleEffect(1.2)
                                }
                            }
                            .tint(.red)
                            .padding(.trailing)
                        }
                    }
                    .frame(height: 120)
                    .padding(.top)
                    
                    HStack {
                        if (song.constant.count == 6) {
                            Text("\(song.constant[5], specifier: "%.1f")")
                                .font(.title3)
                            
                        } else if (song.level.count == 1) {
                            Text("\(song.constant[0], specifier: "%.1f")")
                                .font(.title3)
                        } else {
                            Text("\(song.constant[0], specifier: "%.1f")")
                                .foregroundColor(Color.green)
                                .font(.title3)
                            Text("\(song.constant[1], specifier: "%.1f")")
                                .foregroundColor(Color.yellow)
                                .font(.title3)
                            Text("\(song.constant[2], specifier: "%.1f")")
                                .foregroundColor(Color.red)
                                .font(.title3)
                            Text("\(song.constant[3], specifier: "%.1f")")
                                .foregroundColor(Color.purple)
                                .font(.title3)
                            if (song.level.count == 5) {
                                Text("\(song.constant[4], specifier: "%.1f")")
                                    .font(.title3)
                            }
                        }
                        
                        Spacer()
                        
                        Text("BPM: \(song.basicInfo.bpm)")
                            .font(.title3)
                    }
                    .padding(.top, 5.0)
                    .padding(.horizontal)
                    
                    
                    
                    HStack {
                        Text("难度：")
                        
                        Picker("难度：", selection: $selectedDifficulty) {
                            ForEach(availableDiffs, id: \.self) { diff in
                                Text(diff)
                            }
                        }
                    }
                    
                    
                    
                    ZStack {
                        
                        
                        Group {
                            AsyncImage(url: bgURL) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                } else if let error = phase.error {
                                    Color.red
                                }
                            }
                            
                            AsyncImage(url: barURL) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                } else if let error = phase.error {
                                    Color.red
                                }
                            }
                            
                            AsyncImage(url: chartURL) { phase in
                                if let image = phase.image {
                                    image
                                        .resizable()
                                } else if let error = phase.error {
                                    Color.red
                                }
                            }
                        }
                        .tag("chartImage")
                        .border(Color.white.opacity(0.8))
                        .overlay {
                            RoundedRectangle(cornerSize: CGSize(width: 5, height: 5))
                        }
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 5)
                                .frame(width: 30, height: 30)
                                .foregroundColor(Color.gray.opacity(0.8))
                            
                            Button {
                                
                            } label: {
                                Image(systemName: "plus.magnifyingglass")
                                
                            }
                            
                        }
                        .position(x: 330, y: 180)
                        
                    }
                    .frame(width: 350, height: 200)
                }
                
                HStack {
                    let chartIndex: Int = {
                        switch(selectedDifficulty) {
                        case "Expert":
                            return 2
                        case "Master":
                            return 3
                        case "Ultima":
                            return 4
                        default:
                            return 3
                        }
                    }()
                    
                    Text("谱师：\(song.charts[chartIndex].charter)")
                    
                    Spacer()
                    
                    Text("连击数：\(song.charts[chartIndex].combo)")
                }
                .padding()
            }
        }
    }
}

struct SongDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SongDetailView(song: tempSongData)
    }
}

