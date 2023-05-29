//
//  PlayerInfoView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/5/9.
//

import SwiftUI

struct PlayerInfoView: View {
    @ObservedObject var user: CFQNUser
    
    var body: some View {
        Form {
            Text("完成度")
        }
        .navigationTitle("玩家信息")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct PlayerInfoView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerInfoView(user: CFQNUser())
    }
}
