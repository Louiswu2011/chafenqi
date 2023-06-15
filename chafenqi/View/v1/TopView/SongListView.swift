//
//  MaimaiListView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/3.
//

import SwiftUI

struct SongListView: View {
    @ObservedObject var user: CFQUser
    
    @State private var searchText = ""
    
    @State private var showingDetail = false
    @State private var showingFilterPanel = false
    @State private var showingPlayed = false
    
    @State private var advancedFiltering = false
    
    let basicPrompt = "输入歌曲名/作者..."
    let advancedPrompt = "输入高级筛选条件..."
    
    var body: some View {
        if #available(iOS 15.0, *) {
            VStack{
                if (user.currentMode == 0) {
                    if searchChunithmResults != nil {
                        List {
                            ForEach(searchChunithmResults!.sorted(by: <), id: \.musicId) { song in
                                NavigationLink {
                                    ChunithmDetailView(user: user, song: song)
                                } label: {
                                    SongBasicView(user: user, chunithmSong: song)
                                }
                                
                            }
                        }
                    } else {
                        VStack(spacing: 15) {
                            ProgressView()
                            Text("加载歌曲列表中...")
                        }
                    }
                } else {
                    if searchMaimaiResults != nil {
                        List {
                            ForEach(searchMaimaiResults!.sorted(by: <), id: \.musicId) { song in
                                NavigationLink {
                                    MaimaiDetailView(user: user, song: song)
                                } label: {
                                    SongBasicView(user: user, maimaiSong: song)
                                }
                                
                            }
                        }
                    } else {
                        VStack(spacing: 15) {
                            ProgressView()
                            Text("加载歌曲列表中...")
                        }
                    }
                }
            }
            .navigationTitle("曲目列表")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Toggle(isOn: $showingPlayed) {
                            Image(systemName: "rectangle.on.rectangle")
                            Text("仅显示已游玩曲目")
                        }
                        .disabled(!user.didLogin)
                        
                        Toggle(isOn: $advancedFiltering) {
                            Image(systemName: "ellipsis.rectangle")
                            Text("高级搜索模式")
                        }
                        
                        Button {
                            // TODO: Add tutorial for advanced filtering
                            
                        } label: {
                            Image(systemName: "questionmark.circle")
                            Text("高级搜索帮助")
                        }
                        .disabled(true) // For now
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .searchable(text: $searchText, prompt: advancedFiltering ? advancedPrompt : basicPrompt)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
        } else {
            VStack{
                if (user.currentMode == 0) {
                    if searchChunithmResults != nil {
                        List {
                            ForEach(searchChunithmResults!.sorted(by: <), id: \.musicId) { song in
                                NavigationLink {
                                    ChunithmDetailView(user: user, song: song)
                                } label: {
                                    SongBasicView(user: user, chunithmSong: song)
                                }
                                
                            }
                        }
                    } else {
                        VStack(spacing: 15) {
                            ProgressView()
                            Text("加载歌曲列表中...")
                        }
                    }
                } else {
                    if searchMaimaiResults != nil {
                        List {
                            ForEach(searchMaimaiResults!.sorted(by: <), id: \.musicId) { song in
                                NavigationLink {
                                    MaimaiDetailView(user: user, song: song)
                                } label: {
                                    SongBasicView(user: user, maimaiSong: song)
                                }
                                
                            }
                        }
                    } else {
                        VStack(spacing: 15) {
                            ProgressView()
                            Text("加载歌曲列表中...")
                        }
                    }
                }
                
            }
            .navigationTitle("曲目列表")
            .toolbar {
                ToolbarItem() {
                    Menu {
                        Toggle(isOn: $showingPlayed) {
                            Image(systemName: "rectangle.on.rectangle")
                            Text("仅显示已游玩曲目")
                        }
                        .disabled(!user.didLogin)
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .autocapitalization(.none)
            .autocorrectionDisabled(true)
        }
    }
    
    var searchMaimaiResults: Array<MaimaiSongData>? {
        guard user.currentMode == 1 else { return nil }
        
        
        var songs = user.data.maimai.songlist
        
        if (showingPlayed && user.maimai != nil) {
            let userInfo = user.maimai!.record
            let idList = userInfo.records.compactMap { $0.musicId }
            songs = songs.filter { idList.contains( Int($0.musicId)! ) }
        }
        
        if searchText.isEmpty {
            return songs
        } else {
            if (advancedFiltering) {
                let regex = RegexManager.shared
                
                let range = NSRange(searchText.startIndex..<searchText.endIndex, in: searchText)
                let constantMatches = regex.constantRegex.matches(in: searchText, range: range)
                if let constantHit = constantMatches.first {
                    var constantParams: [String: String] = [:]
                    
                    for groupName in ["lowerDigit", "lowerDecimal", "upperDigit", "upperDecimal"] {
                        let hitRange = constantHit.range(withName: groupName)
                        if let substringRange = Range(hitRange, in: searchText) {
                            let substring = String(searchText[substringRange])
                            constantParams[groupName] = substring
                        }
                    }
                    
                    let lower = Double(constantParams["lowerDigit"]! + (constantParams["lowerDecimal"] ?? "")) ?? 0.0
                    let upper = Double(constantParams["upperDigit"]! + (constantParams["upperDecimal"] ?? "")) ?? 15.0
                    
                    if (lower <= upper) {
                        songs = songs.filterConstant(lower: lower, upper: upper)
                    }
                    
                }
                
                let levelMatches = regex.levelRegex.matches(in: searchText, range: range)
                if let levelHit = levelMatches.first {
                    var levelParams: [String: String] = [:]
                    
                    for groupName in ["lower", "upper"] {
                        let hitRange = levelHit.range(withName: groupName)
                        if let substringRange = Range(hitRange, in: searchText) {
                            let substring = String(searchText[substringRange])
                            levelParams[groupName] = substring
                        }
                    }
                    
                    let lower = levelParams["lower"]!
                    let upper = levelParams["upper"]!
                    
                    if (levelToDigit(level: lower) <= levelToDigit(level: upper)) {
                        songs = songs.filterLevel(lower: lower, upper: upper)
                    }
                }
                
                return songs
            } else {
                return songs.filterTitleAndArtist(keyword: searchText)
            }
        }
        
    }
    
    var searchChunithmResults: Array<ChunithmSongData>? {
        guard user.currentMode == 0 else { return nil }
        
        var songs = user.data.chunithm.songs
        
        if (showingPlayed && user.chunithm != nil) {
            
            let userInfo = user.chunithm!.profile
            let idList = userInfo.records.best.compactMap { $0.musicId }
            songs = songs.filter { idList.contains( $0.musicId ) }
            
        }
        
        if searchText.isEmpty {
            return songs
        } else {
            if (advancedFiltering) {
                let regex = RegexManager.shared
                
                let range = NSRange(searchText.startIndex..<searchText.endIndex, in: searchText)
                let constantMatches = regex.constantRegex.matches(in: searchText, range: range)
                if let constantHit = constantMatches.first {
                    var constantParams: [String: String] = [:]
                    
                    for groupName in ["lowerDigit", "lowerDecimal", "upperDigit", "upperDecimal"] {
                        let hitRange = constantHit.range(withName: groupName)
                        if let substringRange = Range(hitRange, in: searchText) {
                            let substring = String(searchText[substringRange])
                            constantParams[groupName] = substring
                        }
                    }
                    
                    let lower = Double(constantParams["lowerDigit"]! + (constantParams["lowerDecimal"] ?? "")) ?? 0.0
                    let upper = Double(constantParams["upperDigit"]! + (constantParams["upperDecimal"] ?? "")) ?? 15.4
                    
                    if (lower <= upper) {
                        songs = songs.filterConstant(lower: lower, upper: upper)
                    }
                    
                }
                
                let levelMatches = regex.levelRegex.matches(in: searchText, range: range)
                if let levelHit = levelMatches.first {
                    var levelParams: [String: String] = [:]
                    
                    for groupName in ["lower", "upper"] {
                        let hitRange = levelHit.range(withName: groupName)
                        if let substringRange = Range(hitRange, in: searchText) {
                            let substring = String(searchText[substringRange])
                            levelParams[groupName] = substring
                        }
                    }
                    
                    let lower = levelParams["lower"]!
                    let upper = levelParams["upper"]!
                    
                    if (levelToDigit(level: lower) <= levelToDigit(level: upper)) {
                        songs = songs.filterLevel(lower: lower, upper: upper)
                    }
                }
                
                return songs
            } else {
                return songs.filterTitleAndArtist(keyword: searchText)
            }
        }
    }
}

