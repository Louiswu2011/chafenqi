//
//  HomeView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/5/7.
//

import SwiftUI
import AlertToast
import OneSignal
import WidgetKit
import SwiftUIBackports

struct HomeView: View {
    @Environment(\.managedObjectContext) var context
    @ObservedObject var user: CFQNUser
    @ObservedObject var alertToast = AlertToastModel.shared
    
    @State private var versionData = ClientVersionData.empty
    
    @AppStorage("settingsHomeArrangement") var homeArrangement = "最近动态|Rating分析|出勤记录"
    @AppStorage("CFQUsername") var username = ""
    
    @State var refreshing = false
    @State var dismissed = false
    @State var daysSinceLastPlayed = 0
    
    @State var firstLaunch = true
    
    @State var bundleVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    @State var bundleBuildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
    
    var body: some View {
        VStack {
            if refreshing {
                ProgressView(user.loadPrompt)
            } else if (user.didLogin) {
                if #available(iOS 15.0, *) {
                    HomeScrollView(user: user, daysSinceLastPlayed: daysSinceLastPlayed, homeArrangement: homeArrangement)
                        .refreshable {
                            DispatchQueue.main.async {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    refreshing = true
                                }
                            }
                            refresh()
                        }
                } else {
                    HomeScrollView(user: user, daysSinceLastPlayed: daysSinceLastPlayed, homeArrangement: homeArrangement)
                        .backport.refreshable {
                            DispatchQueue.main.async {
                                withAnimation(.easeInOut(duration: 0.15)) {
                                    refreshing = true
                                }
                            }
                            await refresh()
                        }
                }
            }
        }
        // .id(UUID())
        .onAppear {
            if firstLaunch {
                Task { 
                    await checkVersion()
                    syncToWidget()
                    
                    OneSignal.setExternalUserId(user.username)
                    firstLaunch = false
                }
            }
            
            loadDays()
        }
        .toast(isPresenting: $alertToast.show, duration: 1, tapToDismiss: true) {
            alertToast.toast
        }
        .alert(isPresented: $alertToast.alertShow) {
            alertToast.alert
        }
    }
    
    func refresh() {
        Task {
            do {
                try await user.refresh()
                syncToWidget()
            } catch {
                print("[HomeView] Error refreshing record for", user.username, error)
                let errToast = AlertToast(displayMode: .hud, type: .error(.red), title: "加载出错", subTitle: error.localizedDescription)
                alertToast.toast = errToast
            }
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.15)) {
                    refreshing = false
                }
            }
        }
    }
    
    func syncToWidget() {
        Task {
            do {
                try await WidgetDataController.shared.save(data: user.makeWidgetData(), context: WidgetDataController.shared.container.viewContext)
            } catch {
                alertToast.toast = AlertToast(displayMode: .hud, type: .error(.red), title: "同步小组件失败", subTitle: error.localizedDescription)
                print(error)
            }
            WidgetCenter.shared.reloadAllTimelines()
        }
    }
    
    func checkVersion() async {
        guard bundleBuildNumber != "83" else { return }
        do {
            let versionRequest = URLRequest(url: URL(string: "http://43.139.107.206:8083/api/stats/version")!)
            let (data, _) = try await URLSession.shared.data(for: versionRequest)
            versionData = try JSONDecoder().decode(ClientVersionData.self, from: data)
            if versionData.hasNewVersion(major: bundleVersion, minor: bundleBuildNumber) && !dismissed {
                let updateAlert = Alert(
                    title: Text("发现新版本"),
                    message: Text("当前版本为：\(bundleVersion) Build \(bundleBuildNumber)\n最新版本为：\(versionData.major) Build \(versionData.minor)\n是否前往更新？"),
                    primaryButton: .default(Text("前往Testflight")) {
                        UIApplication.shared.open(URL(string: "itms-beta://testflight.apple.com/join/OBC08JvQ")!)
                    },
                    secondaryButton: .cancel(Text("取消")))
                dismissed = true
                alertToast.alert = updateAlert
            }
        } catch {
            versionData = .empty
        }
    }
    
    func loadDays() {
        var maiDay = 0
        var chuDay = 0
        if let recentOne = user.maimai.recent.sorted(by: { $0.timestamp > $1.timestamp }).first {
            maiDay = (Int(Date().timeIntervalSince1970) - recentOne.timestamp) / 86400
        }
        if let recentOne = user.chunithm.recent.sorted(by: { $0.timestamp > $1.timestamp }).first {
            chuDay = (Int(Date().timeIntervalSince1970) - recentOne.timestamp) / 86400
        }
        daysSinceLastPlayed = min(maiDay, chuDay)
    }
}

struct HomeScrollView: View {
    var user: CFQNUser
    var daysSinceLastPlayed: Int
    var homeArrangement: String
    
    var body: some View {
        ScrollView {
            HomeNameplate(user: user)
            if daysSinceLastPlayed > 0 && user.showDaysSinceLastPlayed {
                Text("你已经有\(daysSinceLastPlayed)天没出勤了！")
                    .bold()
            }
            ForEach(homeArrangement.components(separatedBy: "|"), id: \.hashValue) { value in
                switch value {
                case "最近动态":
                    HomeRecent(user: user)
                case "Rating分析":
                    HomeRating(user: user)
                case "出勤记录":
                    HomeDelta(user: user)
                default:
                    Spacer()
                }
            }
        }
        .coordinateSpace(name: "pull")
        .navigationTitle("主页")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    withAnimation(.easeInOut(duration: 0.15)) {
                        user.currentMode.toggle()
                    }
                } label: {
                    Image(systemName: "arrow.left.arrow.right")
                }
            }
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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(user: CFQNUser())
    }
}
