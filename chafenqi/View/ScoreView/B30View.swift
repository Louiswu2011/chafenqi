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
        VStack {
            ScrollView {
                ForEach(b30, id: \.musicId) { entry in
                    SongBarView(song: entry)
                        .padding(.vertical, 5)
                }
            }
            .navigationTitle("B30")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct B30View_Previews: PreviewProvider {
    static var previews: some View {
        MainView(currentTab: .constant(.home))
    }
}
