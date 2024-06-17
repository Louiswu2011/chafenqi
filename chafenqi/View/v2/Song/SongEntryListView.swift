//
//  SongEntryListView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/6/18.
//

import SwiftUI

struct SongEntryListView: View {
    @ObservedObject var user: CFQNUser
    
    @State var historyData: [(Double, String)] = []
    
    @State var maiRecords: CFQMaimaiRecentScoreEntries?
    @State var chuRecords: CFQChunithmRecentScoreEntries?
    
    @State var shouldShowPointMarkers: Bool = false
    
    var body: some View {
        if user.isPremium {
            ScrollView {
                if let maiRecords = maiRecords {
                    SongScoreTrendChart(rawDataPoints: $historyData, mode: 1, shouldShowPointMarkers: $shouldShowPointMarkers)
                        .padding()
                    ForEach(maiRecords, id: \.timestamp) { record in
                        NavigationLink {
                            RecentDetail(user: user, maiEntry: record, hideSongInfo: true)
                        } label: {
                            MaimaiRecentEntryView(user: user, entry: record)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal)
                } else if let chuRecords = chuRecords {
                    SongScoreTrendChart(rawDataPoints: $historyData, mode: 0, shouldShowPointMarkers: $shouldShowPointMarkers)
                        .padding()
                    ForEach(chuRecords, id: \.timestamp) { record in
                        NavigationLink {
                            RecentDetail(user: user, chuEntry: record, hideSongInfo: true)
                        } label: {
                            ChunithmRecentEntryView(user: user, entry: record)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal)
                }
            }
            .onAppear {
                loadVar()
            }
        } else {
            VStack {
                Spacer()
                Text("订阅会员以查询游玩记录")
                    .padding(.bottom)
                NavigationLink {
                    NotPremiumView()
                } label: {
                    HStack {
                        Image(systemName: "arrowshape.turn.up.forward")
                        Text("了解详情")
                    }
                }
                Spacer()
            }
        }
    }
    
    func loadVar() {
        guard historyData.isEmpty else { return }
        if let maiRecords = maiRecords {
            maiRecords.sorted {
                $0.timestamp < $1.timestamp
            }.forEach { record in
                historyData.append((record.score, record.timestamp.toDateString(format: "MM-dd")))
            }
        } else if let chuRecords = chuRecords {
            chuRecords.sorted {
                $0.timestamp < $1.timestamp
            }.forEach { record in
                historyData.append((Double(record.score), record.timestamp.toDateString(format: "MM-dd")))
            }
        }
    }
}

struct SongEmptyEntryView: View {
    var body: some View {
        Text("哎呀，还没有游玩过该难度！")
    }
}
