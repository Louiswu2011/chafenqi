//
//  SongDetailView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/9.
//

import SwiftUI
import UIKit
import CachedAsyncImage
import AlertToast

struct SongDetailView: View {
    
    @AppStorage("settingsCoverSource") var coverSource = ""
    @AppStorage("userInfoData") var userInfoData = Data()
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isFavourite = false
    @State private var isLoading = true
    @State private var isCheckingDiff = true
    @State private var loadingScore = true
    @State private var showingChart = false
    
    @State private var selectedDifficulty = "Master"
    @State private var availableDiffs: [String] = ["Master"]
    
    @State private var chartImage: UIImage = UIImage()
    @State private var chartImageView = Image(systemName: "magnifyingglass")
    
    @State private var userInfo = UserData()
    @State private var scoreEntries = [Int: ScoreEntry]()
    
    var song: SongData
    
    let converter = try! ChartIdConverter()
    
    func reloadChartImage(id: String, diff: String) async throws {
        chartImage = try await ChartImageGrabber.downloadChartImage(webChartId: id, diff: difficulty[diff]!)
        chartImageView = Image(uiImage: chartImage)
    }
    
    var body: some View {
        let webChartId = try! converter.getWebChartId(musicId: song.id)
        
        let coverURL = coverSource == "Github" ? URL(string: "https://raw.githubusercontent.com/Louiswu2011/Chunithm-Song-Cover/main/images/\(song.id).png") : URL(string: "https://gitee.com/louiswu2011/chunithm-cover/raw/master/image/\(song.id).png")
        
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
                        CachedAsyncImage(url: coverURL) { phase in
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
                        .shadow(color: colorScheme == .dark ? Color.white : Color.gray.opacity(0.7), radius: 1)
                        .frame(width: 120, height: 120)
                        .padding(.leading)
                        
                        VStack(alignment: .leading) {
                            Spacer()
                            
                            Text(song.title)
                                .font(.title)
                                .bold()
                                .lineLimit(2)
                                .minimumScaleFactor(0.8)
                            
                            Text(song.basicInfo.artist)
                                .font(.title2)
                                .lineLimit(1)
                                .minimumScaleFactor(0.8)
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
                    .padding(.top, 5.0)
                    .navigationTitle("")
                    .navigationBarTitleDisplayMode(.inline)
                    
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
                        Text("\(song.basicInfo.from)")
                        
                        Spacer()
                        
                        Text("\(song.basicInfo.genre)")
                    }
                    .padding(.horizontal)
                    
                    HStack {
                        Text("难度：")
                        
                        Picker("难度：", selection: $selectedDifficulty) {
                            ForEach(availableDiffs, id: \.self) { diff in
                                Text(diff)
                            }
                        }
                        .onChange(of: selectedDifficulty) { tag in
                            Task {
                                do {
                                    chartImage = UIImage()
                                    try await reloadChartImage(id: webChartId, diff: selectedDifficulty)
                                } catch {
                                    AlertToast(displayMode: .hud, type: .error(Color.red), title: "加载谱面图片失败")
                                }
                            }
                        }
                        
                        if(isCheckingDiff) {
                            ProgressView()
                                .padding(.leading, 5)
                        }
                    }

                    ZStack {
                        // TODO: fix background
                        RoundedRectangle(cornerSize: CGSize(width: 5, height: 5))
                            .background(Color.black)
                            .shadow(color: colorScheme == .dark ? Color.white : Color.gray.opacity(0.7), radius: 1)
                        
                        // Chart Image
                        if (chartImage == UIImage()) {
                            ProgressView()
                        } else {
                            Image(uiImage: chartImage)
                                .resizable()
                        }
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 5)
                                .frame(width: 30, height: 30)
                                .foregroundColor(Color.gray.opacity(0.8))
                            
                            Button {
                                if (chartImage != UIImage()) {
                                    showingChart.toggle()
                                }
                            } label: {
                                Image(systemName: "plus.magnifyingglass")
                            }
                            .sheet(isPresented: $showingChart) {
                                SongChartView(chartImage: chartImage)
                            }
                        }
                        .position(x: 330, y: 180)
                    }
                    .frame(width: 350, height: 200)
                    .task {
                        do {
                            chartImage = try await ChartImageGrabber.downloadChartImage(webChartId: webChartId, diff: difficulty[selectedDifficulty]!)
                            chartImageView = Image(uiImage: chartImage)
                            availableDiffs = try await converter.getAvailableDiffs(musicId: song.id)
                            isCheckingDiff.toggle()
                        } catch CFQError.requestTimeoutError {
                            AlertToast(displayMode: .hud, type: .error(Color.red), title: "加载谱面图片失败")
                        } catch CFQError.unsupportedError(let reason) {
                            AlertToast(displayMode: .hud, type: .error(Color.red), title: reason)
                        } catch {
                            
                        }
                    }
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
                    
                    if (song.charts.indices.contains(chartIndex)) {
                        Text("谱师：\(song.charts[chartIndex].charter)")
                        
                        Spacer()
                        
                        Text("连击数：\(song.charts[chartIndex].combo)")
                    }
                }
                .padding()
                
                if (!loadingScore) {
                    VStack(spacing: 10) {
                        let levelLabel = [
                            0: "Basic",
                            1: "Advanced",
                            2: "Expert",
                            3: "Master",
                            4: "Ultima"
                        ]
                        
                        ForEach(0..<4) { index in
                            ZStack {
                                let exists = !scoreEntries.filter{ $0.key == index }.isEmpty
                                
                                RoundedRectangle(cornerRadius: 5)
                                    .foregroundColor(getLevelColor(index: index).opacity(0.5))
                                
                                HStack {
                                    Text(levelLabel[index]!)
                                    Spacer()
                                    if (exists) {
                                        Text(scoreEntries[index]!.getStatus())
                                    }
                                    Text(exists ? String(scoreEntries[index]!.score) : "尚未游玩")
                                        .bold()
                                    if (exists) {
                                        Text("\(scoreEntries[index]!.rating, specifier: "%.2f")/\(String(scoreEntries[index]!.constant))")
                                    }
                                }
                                .padding()
                            }
                            .padding(.horizontal)
                            
                        }
                        
                        if (song.charts.count == 5) {
                            ZStack {
                                let exists = !scoreEntries.filter{ $0.key == 4 }.isEmpty
                                
                                RoundedRectangle(cornerRadius: 5)
                                    .foregroundColor(getLevelColor(index: 4).opacity(0.5))
                                
                                HStack {
                                    Text(levelLabel[4]!)
                                    Spacer()
                                    if (exists) {
                                        Text(scoreEntries[4]!.getStatus())
                                    }
                                    Text(exists ? String(scoreEntries[4]!.score) : "尚未游玩")
                                        .bold()
                                    if (exists) {
                                        Text("\(scoreEntries[4]!.rating, specifier: "%.2f")/\(String(scoreEntries[4]!.constant))")
                                    }
                                }
                                .padding()
                            }
                            .padding(.horizontal)
                        }
                        
                    }
                }
            }
            .task {
                userInfo = try! JSONDecoder().decode(UserData.self, from: userInfoData)
                var scores = userInfo.records.best.filter {
                    $0.musicID == song.id
                }
                scores.sort {
                    $0.levelIndex < $1.levelIndex
                }
                scoreEntries = Dictionary(uniqueKeysWithValues: scores.map { ($0.levelIndex, $0) })
                loadingScore.toggle()
            }
        }
    }
}

func getLevelColor(index: Int) -> Color {
    switch (index) {
    case 0:
        return Color.green
    case 1:
        return Color.yellow
    case 2:
        return Color.red
    case 3:
        return Color.purple
    case 4:
        return Color.gray
    default:
        return Color.purple
    }
}

struct SongDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SongDetailView(song: tempSongData)
            // .environment(\.colorScheme, .dark)
    }
}

