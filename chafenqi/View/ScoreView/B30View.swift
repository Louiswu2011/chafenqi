//
//  B30View.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/26.
//

import SwiftUI

struct B30View: View {
    @AppStorage("loadedChunithmSongs") var loadedSongs: Data = Data()
    
    var decodedLoadedSongs: Array<ChunithmSongData>
    
    @State private var showingMaximumRating = false
    
    var b30 = ArraySlice<ScoreEntry>()
    
    let rows = [
        GridItem(),
        GridItem()
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    ZStack {
                        // TODO: get max
                        CutCircularProgressView(progress: showingMaximumRating ? 1 : userInfo.getAvgB30() / 17.30, lineWidth: 14, width: 100, color: Color.cyan)
                        
                        Text("\(userInfo.getAvgB30(), specifier: "%.2f")")
                            .foregroundColor(Color.cyan)
                            .textFieldStyle(.roundedBorder)
                            .font(.title)
                        
                        Text("B30")
                            .padding(.top, 70)
                            .font(.title2)
                    }
                    .padding()
                    
                    VStack {
                        Spacer()
                        Text("总游玩曲目：\(userInfo.records.best.count)")
                        Text("a")
                    }
                }
            }.task {
                
            }
        }
    }
}

struct B30View_Previews: PreviewProvider {
    static var previews: some View {
        MainView(currentTab: .constant(.home))
    }
}
