//
//  HomeView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/5/7.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var user: CFQNUser
    
    var body: some View {
        if (user.didLogin) {
            ScrollView {
                HomeNameplate(user: user)
                HomeRecent(user: user)
            }
            .navigationTitle("主页")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        Settings(user: user)
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(user: CFQNUser())
    }
}
