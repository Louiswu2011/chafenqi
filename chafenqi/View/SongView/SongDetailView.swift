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
    
    @AppStorage("settingsCoverSource") var coverSource = 0
    @AppStorage("userInfoData") var userInfoData = Data()
    
    @Environment(\.colorScheme) var colorScheme
    
    @State private var isFavourite = false
    @State private var isLoading = true
    @State private var isCheckingDiff = true
    @State private var loadingScore = true
    @State private var showingChart = false
    @State private var showingCalc = false
    
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
        
        let coverURL = coverSource == 0 ? URL(string: "https://raw.githubusercontent.com/Louiswu2011/Chunithm-Song-Cover/main/images/\(song.id).png") : URL(string: "https://gitee.com/louiswu2011/chunithm-cover/raw/master/image/\(song.id).png")
        
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
                        SongCoverView(coverURL: coverURL!, size: 120, cornerRadius: 10)
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
                        .padding(.leading, 5)
                        
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
                        RoundedRectangle(cornerSize: CGSize(width: 5, height: 5))
                            .foregroundColor(Color.black)
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
                .padding(.bottom)
                
                if (!loadingScore) {
                    VStack(spacing: 5) {
                        ForEach(0..<4) { index in
                            ScoreCardView(index: index, scoreEntries: scoreEntries, song: song)
                                .padding(.bottom, 5)
                            
                        }
                        if (song.charts.count == 5) {
                            ScoreCardView(index: 4, scoreEntries: scoreEntries, song: song)
                                .padding(.bottom, 5)
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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            showingCalc.toggle()
                        } label: {
                            Image(systemName: "plus.forwardslash.minus")
                            Text("分数计算")
                        }
                        .sheet(isPresented: $showingCalc) {
                            BorderCalcView(song: song)
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
    }
    
    struct ScoreCardView: View {
        var index: Int
        var scoreEntries: [Int: ScoreEntry]
        var song: SongData
        
        @State private var showingDetail = false
        @State private var rotationAngle: Double = 0
        
        let levelLabel = [
            0: "Basic",
            1: "Advanced",
            2: "Expert",
            3: "Master",
            4: "Ultima"
        ]
        
        var body: some View {
            ZStack {
                let exists = !scoreEntries.filter{ $0.key == index }.isEmpty
                
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(getLevelColor(index: index).opacity(0.5))
                
                VStack() {
                    HStack {
                        Text(levelLabel[index]!)
                        Spacer()
                        if (exists && showingDetail) {
                            Text(scoreEntries[index]!.getStatus())
                            Text(scoreEntries[index]!.getGrade())
                        }
                        Text(exists ? String(scoreEntries[index]!.score) : "尚未游玩")
                            .bold()
                        if (exists && showingDetail) {
                            Text("\(scoreEntries[index]!.rating, specifier: "%.2f")")
                        }
                        Image(systemName: "chevron.backward")
                            .rotationEffect(Angle(degrees: rotationAngle))
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    rotationAngle = showingDetail ? rotationAngle + 90 : rotationAngle - 90
                                }
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    showingDetail.toggle()
                                }
                            }
                    }
                    .padding()
                    
                    if (showingDetail) {
                        VStack {
                            HStack {
                                Text("谱师：\(song.charts[index].charter)")
                                    .lineLimit(1)
                                Spacer()
                                Text("连击数：\(song.charts[index].combo)")
                            }
                            .padding([.horizontal, .bottom])
                        }
                    }
                }
            }
            .padding(.horizontal)
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

