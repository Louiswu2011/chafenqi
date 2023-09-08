//
//  RecentListView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/5/7.
//

import SwiftUI

struct RecentListView: View {
    @ObservedObject var user: CFQNUser
    
    @State private var pageAvailable: Int = 1
    @State private var currentPage: Int = 1
    
    @State private var maiSlice = CFQMaimaiRecentScoreEntries()
    @State private var chuSlice = CFQChunithmRecentScoreEntries()
    
    @State private var loaded = false
    
    var body: some View {
        Form {
            if (user.currentMode == 0) {
                ForEach(chuSlice, id: \.timestamp) { entry in
                    NavigationLink {
                        RecentDetail(user: user, chuEntry: entry)
                    } label: {
                        ChunithmRecentEntryView(user: user, entry: entry)
                    }
                    .buttonStyle(.plain)
                }
            } else {
                ForEach(maiSlice, id: \.timestamp) { entry in
                    NavigationLink {
                        RecentDetail(user: user, maiEntry: entry)
                    } label: {
                        MaimaiRecentEntryView(user: user, entry: entry)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .onAppear {
            if !loaded {
                let entryCount = user.currentMode == 0 ? user.chunithm.recent.count : user.maimai.recent.count
                pageAvailable = entryCount / 30
                currentPage = 0
                
                if maiSlice.isEmpty && user.currentMode == 1 {
                    maiSlice = Array(user.maimai.recent.prefix(30))
                } else if chuSlice.isEmpty && user.currentMode == 0 {
                    chuSlice = Array(user.chunithm.recent.prefix(30))
                }
                loaded = true
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    offsetPage(by: -1)
                } label: {
                    Image(systemName: "arrow.left")
                }
                .disabled(currentPage == 0)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Text("\(currentPage + 1) / \(pageAvailable + 1)")
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    offsetPage(by: 1)
                } label: {
                    Image(systemName: "arrow.right")
                }
                .disabled(currentPage == pageAvailable)
            }
        }
        .navigationTitle("最近动态")
        .navigationBarTitleDisplayMode(.large)
        .id(currentPage)
    }
    
    func offsetPage(by value: Int) {
        currentPage += value
        if user.currentMode == 0 {
            chuSlice = Array(user.chunithm.recent[(currentPage * 30)...].prefix(30))
        } else if user.currentMode == 1 {
            maiSlice = Array(user.maimai.recent[(currentPage * 30)...].prefix(30))
        }
    }
    
}

struct MaimaiRecentEntryView: View {
    @ObservedObject var user: CFQNUser
    var entry: CFQMaimai.RecentScoreEntry
    
    var body: some View {
        HStack {
            SongCoverView(coverURL: MaimaiDataGrabber.getSongCoverUrl(source: user.chunithmCoverSource, coverId: getCoverNumber(id: entry.associatedSong!.musicId)), size: 65, cornerRadius: 5, diffColor: maimaiLevelColor[entry.levelIndex])
                .padding(.trailing, 5)
            Spacer()
            VStack {
                HStack {
                    Text(entry.timestamp.customDateString)
                    Spacer()
                    // TODO: Add badges here
                }
                Spacer()
                HStack(alignment: .bottom) {
                    Text(entry.title)
                        .font(.system(size: 17))
                        .lineLimit(1)
                    Spacer()
                    Text("\(entry.score, specifier: "%.4f")%")
                        .font(.system(size: 17))
                        .bold()
                }
            }
        }
        .frame(height: 65)
    }
}

struct ChunithmRecentEntryView: View {
    @ObservedObject var user: CFQNUser
    var entry: CFQChunithm.RecentScoreEntry
    
    var body: some View {
        HStack {
            SongCoverView(coverURL: ChunithmDataGrabber.getSongCoverUrl(source: user.chunithmCoverSource, musicId: String(entry.associatedSong!.musicID)), size: 65, cornerRadius: 5, diffColor: chunithmLevelColor[entry.levelIndex])
                .padding(.trailing, 5)
            Spacer()
            VStack {
                HStack {
                    Text(entry.timestamp.customDateString)
                    Spacer()
                    // TODO: Add badges here
                }
                Spacer()
                HStack(alignment: .bottom) {
                    Text(entry.title)
                        .font(.system(size: 17))
                        .lineLimit(1)
                    Spacer()
                    Text("\(entry.score)")
                        .font(.system(size: 17))
                        .bold()
                }
            }
        }
        .frame(height: 65)
    }
}

struct RecentListView_Previews: PreviewProvider {
    static var previews: some View {
        RecentListView(user: CFQNUser())
    }
}
