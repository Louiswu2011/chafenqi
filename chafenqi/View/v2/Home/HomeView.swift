//
//  HomeView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/5/7.
//

import SwiftUI
import AlertToast

struct HomeView: View {
    @ObservedObject var user: CFQNUser
    @ObservedObject var alertToast = AlertToastModel.shared
    
    @State var refreshing = false
    
    var body: some View {
        VStack {
            if (refreshing) {
                VStack {
                    ProgressView("刷新中...")
                }
            } else if (user.didLogin) {
                ScrollView {
                    HomeNameplate(user: user)
                    HomeRecent(user: user)
                    HomeRating(user: user)
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
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button {
                            refresh()
                        } label: {
                            Image(systemName: "arrow.clockwise")
                        }
                    }
                }
            }
        }
        .toast(isPresenting: $alertToast.show, duration: 1, tapToDismiss: true) {
            alertToast.toast
        }
    }
    
    func refresh() {
        refreshing = true
        Task {
            do {
                try await user.refresh()
                refreshing = false
            } catch {
                let errToast = AlertToast(displayMode: .hud, type: .error(.red), title: "加载出错", subTitle: error.localizedDescription)
                alertToast.toast = errToast
                alertToast.show = true
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(user: CFQNUser())
    }
}
