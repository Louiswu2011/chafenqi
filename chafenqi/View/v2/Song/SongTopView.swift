//
//  SongTopView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/5/8.
//

import SwiftUI

struct SongTopView: View {
    @ObservedObject var user: CFQNUser
    
    var body: some View {
        List {
            if (user.currentMode == 0) {
                ForEach(user.data.chunithm.songs, id: \.musicId) { entry in
                    SongItemView(user: user, chuSong: entry)
                }
            } else {
                ForEach(user.data.maimai.songlist, id: \.musicId) { entry in
                    SongItemView(user: user, maiSong: entry)
                }
            }
        }
    }
}

struct SongTopView_Previews: PreviewProvider {
    static var previews: some View {
        SongTopView(user: CFQNUser())
    }
}
