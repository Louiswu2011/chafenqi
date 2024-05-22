//
//  DeltaShortLook.swift
//  chafenqi
//
//  Created by xinyue on 2023/6/16.
//

import SwiftUI

struct DeltaShortLook: View {
    @ObservedObject var user: CFQNUser
    
    @State var playDate = ""
    @State var playCount = 100
    @State var playLength = 10000 // in second
    @State var avgScore = ""
    @State var chuLast: CFQChunithmDayRecords.CFQChunithmDayRecord = .init()
    @State var maiLast: CFQMaimaiDayRecords.CFQMaimaiDayRecord = .init()
    
    var body: some View {
        NavigationLink {
            if user.currentMode == 0 {
                DeltaDetailView(user: user, chuLog: chuLast)
            } else if user.currentMode == 1 {
                DeltaDetailView(user: user, maiLog: maiLast)
            }
        } label: {
            HStack(alignment: .center) {
                VStack(alignment: .leading) {
                    Text(playDate)
                        .bold()
                    Text("上次出勤时间")
                        .font(.caption)
                }
                
                VStack(alignment: .leading) {
                    Text("\(playCount)")
                        .bold()
                    Text("游玩曲目")
                        .font(.caption)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(getPlayLengthString())
                        .bold()
                    Text("出勤时长")
                        .font(.caption)
                }
                
                VStack(alignment: .trailing) {
                    Text(avgScore)
                        .bold()
                    Text("平均成绩")
                        .font(.caption)
                }
            }
            .onAppear {
                loadVar()
            }
        }
        .buttonStyle(.plain)
    }
    
    // MARK: Variable Loading
    func loadVar() {
        if user.currentMode == 0 {
            if !user.chunithm.custom.dayRecords.records.isEmpty {
                if let chuLast = user.chunithm.custom.dayRecords.records.last {
                    self.chuLast = chuLast
                    playCount = chuLast.recentEntries.count
                    playDate = DateTool.shared.yyyymmddTransformer.string(from: chuLast.date)
                    avgScore = String(format: "%.0f", (chuLast.recentEntries.reduce(0) { $0 + Double($1.score) }) / Double(playCount))
                    if let first = chuLast.recentEntries.first {
                        if let last = chuLast.recentEntries.last {
                            playLength = abs(first.timestamp - last.timestamp)
                        }
                    }
                }
            
            }
        } else if user.currentMode == 1 {
            if !user.maimai.custom.dayRecords.records.isEmpty {
                if let maiLast = user.maimai.custom.dayRecords.records.last {
                    self.maiLast = maiLast
                    playCount = maiLast.recentEntries.count
                    playDate = DateTool.shared.yyyymmddTransformer.string(from: maiLast.date)
                    avgScore = String(format: "%.4f", (maiLast.recentEntries.reduce(0) { $0 + $1.score }) / Double(playCount)) + "%"
                    if let first = maiLast.recentEntries.first {
                        if let last = maiLast.recentEntries.last {
                            playLength = abs(first.timestamp - last.timestamp)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: playLength Conversion
    func getPlayLengthString() -> String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.allowedUnits = [.hour, .minute]
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: TimeInterval(playLength)) ?? "00:00"
    }
}
