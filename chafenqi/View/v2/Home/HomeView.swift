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
    
    @AppStorage("settingsHomeArrangement") var homeArrangement = "最近动态|Rating分析|出勤记录"
    
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
                    ForEach(homeArrangement.components(separatedBy: "|"), id: \.hashValue) { value in
                        switch value {
                        case "最近动态":
                            HomeRecent(user: user)
                        case "Rating分析":
                            HomeRating(user: user)
                        case "出勤记录":
                            if user.isPremium {
                                HomeDelta(user: user)
                            }
                        default:
                            Spacer()
                        }
                    }
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
