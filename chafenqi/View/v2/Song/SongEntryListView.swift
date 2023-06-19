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
    
    var body: some View {
        ScrollView {
            if let maiRecords = maiRecords {
                SongScoreTrendChart(rawDataPoints: $historyData, mode: 1)
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
                SongScoreTrendChart(rawDataPoints: $historyData, mode: 0)
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
        .navigationTitle("游玩记录")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadVar()
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
