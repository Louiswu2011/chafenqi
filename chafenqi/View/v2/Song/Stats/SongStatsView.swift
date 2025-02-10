//
//  SongStatsView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2024/06/17.
//

import Foundation
import SwiftUI
import SwiftUICharts
import Inject

struct SongStatView: View {
    @Binding var doneLoading: Bool
    
    var maiStat: CFQMusicStat?
    var chuStat: CFQMusicStat?
    
    var maiEntry: UserMaimaiBestScoreEntry?
    var chuEntry: UserChunithmRecentScoreEntry?
    
    var chuSong: ChunithmMusicData?
    var maiSong: MaimaiSongData?
    var diff: Int
    
    var body: some View {
        if doneLoading {
            if let entry = chuStat, let song = chuSong {
                ChunithmSongStatView(song: song, stat: entry, scoreEntry: chuEntry, diff: diff)
            } else if let entry = maiStat, let song = maiSong {
                MaimaiSongStatView(song: song, stat: entry, diff: diff)
            } else {
                Text("哎呀，还没有人游玩过该难度！")
            }
        } else {
            ProgressView()
        }
    }
}



struct ChunithmSongStatView: View {
    @ObserveInjection var inject
    var song: ChunithmMusicData
    var stat: CFQMusicStat
    var scoreEntry: UserChunithmRecentScoreEntry?
    var diff: Int
    
    let ranks = ["SSS+", "SSS", "SS+", "SS", "S+", "S", "其他"]
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Text("定数：\(song.charts.getChartFromIndex(diff).constant, specifier: "%.1f")")
                    Spacer()
                    Text("谱师:\(song.charts.getChartFromIndex(diff).charter ?? "-")")
                        .lineLimit(1)
                }
                .padding(.bottom)
                
                HStack {
                    let data = makeData()
                    
                    VStack {
                        Text("游玩人数：\(stat.totalPlayed)")
                            .font(.caption)
                        
                        DoughnutChart(chartData: data)
                            .touchOverlay(chartData: data, specifier: "%.0f")
                            .headerBox(chartData: data)
                            .id(data.id)
                            .padding(.bottom)
                    }
                    
                    HStack {
                        VStack(alignment: .leading) {
                            let splits = [stat.ssspSplit, stat.sssSplit, stat.sspSplit, stat.ssSplit, stat.spSplit, stat.sSplit, stat.otherSplit]
                            ForEach(ranks, id: \.self) { rank in
                                let index = ranks.firstIndex(of: rank) ?? 0
                                Text("\(rank)")
                                    .foregroundColor(chunithmRankColor[index] ?? Color.primary) +
                                Text("：") +
                                Text("\(splits[index])")
                            }
                        }
                        VStack(alignment: .trailing) {
                            Text("平均分数")
                            Text("\(stat.totalScore / Double(stat.totalPlayed), specifier: "%.0f")")
                                .fontWeight(.bold)
                                .padding(.bottom)
                            
                            Text("最高分")
                            Text("\(stat.highestScore, specifier: "%.0f")")
                                .fontWeight(.bold)
                        }
                    }
                }
                .padding(.bottom)
                
                if let entry = scoreEntry {
                    HStack {
                        let judges = ["justice", "attack", "miss"]
                        VStack(alignment: .leading) {
                            
                            ForEach(Array(judges.enumerated()), id: \.offset) { index, type in
                                HStack {
                                    Text(type.firstUppercased)
                                        .bold()
                                    Text("-\(entry.losses[index], specifier: "%.0f")")
                                }
                            }
                            
                            
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            HStack {
                                Text("SSS/+容错")
                                    .bold()
                                Text("\(2500 / entry.losses[1], specifier: "%.1f") / \(1000 / entry.losses[1], specifier: "%.0f")")
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .analyticsScreen(name: "chunithm_music_stat_screen")
        .enableInjection()
    }
    
    func makeData() -> DoughnutChartData {
        let data = PieDataSet(dataPoints: [
            PieChartDataPoint(value: Double(stat.ssspSplit), description: "SSS+", colour: chunithmRankColor[0] ?? Color.accentColor),
            PieChartDataPoint(value: Double(stat.sssSplit), description: "SSS", colour: chunithmRankColor[1] ?? Color.accentColor),
            PieChartDataPoint(value: Double(stat.sspSplit), description: "SS+", colour: chunithmRankColor[2] ?? Color.accentColor),
            PieChartDataPoint(value: Double(stat.ssSplit), description: "SS", colour: chunithmRankColor[3] ?? Color.accentColor),
            PieChartDataPoint(value: Double(stat.spSplit), description: "S+", colour: chunithmRankColor[4] ?? Color.accentColor),
            PieChartDataPoint(value: Double(stat.sSplit), description: "S", colour: chunithmRankColor[5] ?? Color.accentColor),
            PieChartDataPoint(value: Double(stat.otherSplit), description: "其他", colour: chunithmRankColor[6] ?? Color.accentColor)
        ], legendTitle: "")
        
        return DoughnutChartData(
            dataSets: data,
            metadata: ChartMetadata(),
            noDataText: Text("暂无数据"))
    }
}

struct MaimaiSongStatView: View {
    @ObserveInjection var inject
    var song: MaimaiSongData
    var stat: CFQMusicStat
    var diff: Int
    
    let ranks = ["SSS+", "SSS", "SS+", "SS", "S+", "S", "其他"]
    let standardNoteTypes = ["Tap", "Hold", "Slide"]
    let deluxeNoteTypes = ["Tap", "Hold", "Slide", "Touch"]
    let judgeTypes = ["Great", "Good", "Miss"]
    
    var body: some View {
        ScrollView {
            LazyVStack {
                HStack {
                    Text("定数：\(song.constants[diff], specifier: "%.1f")")
                    Spacer()
                    Text("谱师:\(song.charts[diff].charter)")
                        .lineLimit(1)
                }
                .padding(.bottom)
                
                HStack {
                    let data = makeData()
                    VStack {
                        Text("总游玩人数：\(stat.totalPlayed)")
                            .font(.caption)
                        
                        DoughnutChart(chartData: data)
                            .touchOverlay(chartData: data, specifier: "%.4f")
                            .headerBox(chartData: data)
                            .id(data.id)
                    }
                    .padding(.bottom)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            let splits = [stat.ssspSplit, stat.sssSplit, stat.sspSplit, stat.ssSplit, stat.spSplit, stat.sSplit, stat.otherSplit]
                            ForEach(ranks, id: \.self) { rank in
                                let index = ranks.firstIndex(of: rank) ?? 0
                                Text("\(rank)")
                                    .foregroundColor(chunithmRankColor[index] ?? Color.primary) +
                                Text("：") +
                                Text("\(splits[index])")
                            }
                        }
                        VStack(alignment: .trailing) {
                            Text("平均分数")
                            Text("\(stat.totalScore / Double(stat.totalPlayed), specifier: "%.4f")%")
                                .fontWeight(.bold)
                                .padding(.bottom)
                            
                            Text("最高分")
                            Text("\(stat.highestScore, specifier: "%.4f")%")
                                .fontWeight(.bold)
                        }
                    }
                    .font(.callout)
                }
                .padding(.bottom)
                
                let data = song.charts[diff]
                let noteTypes = song.type == "DX" ? deluxeNoteTypes : standardNoteTypes
                VStack {
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(" ")
                            ForEach(Array(noteTypes.enumerated()), id: \.offset) { index, noteType in
                                if index == 3 && !data.possibleNormalLosses[3].isEmpty {
                                    Text(noteType)
                                        .bold()
                                } else if index != 3 {
                                    Text(noteType)
                                        .bold()
                                }
                            }
                        }
                        Spacer()
                        
                        ForEach(Array(judgeTypes.enumerated()), id: \.offset) { index, judgeType in
                            VStack(alignment: .trailing, spacing: 5) {
                                Text(judgeType)
                                    .bold()
                                ForEach(data.possibleNormalLosses.indices, id: \.self) { innerIndex in
                                    if song.type == "DX" || (song.type == "SD" && innerIndex < data.possibleNormalLosses.count - 1) {
                                        Text(data.possibleNormalLosses[innerIndex][index])
                                    }
                                }
                            }
                        }
                    }
                    
                    HStack {
                        Text("Break")
                            .bold()
                        Spacer()
                        VStack {
                            Text("\(data.possibleBreakLosses[2]) ~")
                                .font(.system(size: 15))
                            Text("\(data.possibleBreakLosses[4])")
                                .font(.system(size: 15))
                        }
                        VStack {
                            Text("\(data.possibleBreakLosses[5])")
                        }
                        VStack {
                            Text("\(data.possibleBreakLosses[6])")
                        }
                    }
                    .padding(.bottom ,5)
                    
                    HStack {
                        VStack {
                            Text("50/100落")
                                .bold()
                            Text("\(data.possibleBreakLosses[0]) /")
                                .font(.system(size: 15))
                            Text("\(data.possibleBreakLosses[1])")
                                .font(.system(size: 15))
                        }
                        Spacer()
                        VStack {
                            Text("SSS/+容错")
                                .bold()
                            Text("-\(data.lossUntilSSS, specifier: "%.1f") / -\(data.lossUntilSSSPlus, specifier: "%.1f")")
                        }
                        Spacer()
                        VStack {
                            Text("50落/Great比")
                                .bold()
                            Text("\(data.breakToGreatRatio, specifier: "%.1f")")
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .analyticsScreen(name: "maimai_music_stat_screen")
        .enableInjection()
    }
    
    func makeData() -> DoughnutChartData {
        let data = PieDataSet(dataPoints: [
            PieChartDataPoint(value: Double(stat.ssspSplit), description: "SSS+", colour: chunithmRankColor[0] ?? Color.accentColor),
            PieChartDataPoint(value: Double(stat.sssSplit), description: "SSS", colour: chunithmRankColor[1] ?? Color.accentColor),
            PieChartDataPoint(value: Double(stat.sspSplit), description: "SS+", colour: chunithmRankColor[2] ?? Color.accentColor),
            PieChartDataPoint(value: Double(stat.ssSplit), description: "SS", colour: chunithmRankColor[3] ?? Color.accentColor),
            PieChartDataPoint(value: Double(stat.spSplit), description: "S+", colour: chunithmRankColor[4] ?? Color.accentColor),
            PieChartDataPoint(value: Double(stat.sSplit), description: "S", colour: chunithmRankColor[5] ?? Color.accentColor),
            PieChartDataPoint(value: Double(stat.otherSplit), description: "其他", colour: chunithmRankColor[6] ?? Color.accentColor)
        ], legendTitle: "")
        
        return DoughnutChartData(
            dataSets: data,
            metadata: ChartMetadata(),
            noDataText: Text("暂无数据"))
    }
}
