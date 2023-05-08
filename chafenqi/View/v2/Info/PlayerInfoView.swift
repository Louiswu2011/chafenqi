//
//  PlayerInfoView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/5/9.
//

import SwiftUI

struct PlayerInfoView: View {
    var body: some View {
        ScrollView {
            Text("施工中")
        }
        .navigationTitle("玩家信息")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct PlayerInfoView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerInfoView()
    }
}
