//
//  Settings.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/5/7.
//

import SwiftUI
import AlertToast

struct Settings: View {
    @AppStorage("firstTimeLaunch") var firstTime = true
    @AppStorage("shouldForceReload") var shouldForceReload = false
    @AppStorage("proxyDidInstallProfile") var installed = false
    
    @ObservedObject var toastManager = AlertToastManager.shared
    @ObservedObject var alertToast = AlertToastModel.shared
    @ObservedObject var cacheController = CacheController.shared
    
    @ObservedObject var user: CFQNUser
    
    @State private var showingLoginView = false
    @State private var showingBuildNumber = false
    @State private var showingClearAlert = false
    @State private var showingNewVersionAlert = false
    @State private var loading = false
    
    @State private var versionData = ClientVersionData.empty
    
    let iOSVersion = Int(UIDevice.current.systemVersion.split(separator: ".")[0])!
    
    var chunithmSourceOptions = [0: "Github", 1: "NLServer"]
    var chunithmChartSourceOptions = [0: "sdvx.in", 1: "NLServer"]
    var maimaiSourceOptions = [0: "Diving-Fish"]
    var modeOptions = [0: "中二节奏NEW", 1: "舞萌DX"]
    var bundleVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    var bundleBuildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
    
    @State var cacheSize = ""
    
    var body: some View {
        Form {
            Section {
                UserInfoWithAvatarView(user: user)
                NavigationLink {
                    RedeemView()
                } label: {
                    Text("订阅兑换")
                }
                Button {
                    let logoutAlert = Alert(title: Text("确定要登出吗？"), primaryButton: .cancel(Text("取消")), secondaryButton: .default(Text("登出"), action: {
                        user.logout()
                    }))
                    alertToast.alert = logoutAlert
                } label: {
                    Text("登出...")
                }
                .foregroundColor(.red)
            }
            
            Section {
                Toggle("显示距上次出勤天数", isOn: $user.showDaysSinceLastPlayed)
                NavigationLink {
                    SettingsHomeArrangement()
                } label: {
                    Text("排序")
                }
            } header: {
                Text("主页")
            }
            
            Section {
                Toggle(isOn: $user.shouldForwardToFish.animation()) {
                    Text("上传到水鱼网")
                }
                .disabled(user.fishToken.isEmpty)
                if (user.shouldForwardToFish) {
                    SettingsInfoLabelView(title: "Token", message: user.fishToken)
                        .lineLimit(1)
                }
                NavigationLink {
                    TokenUploderView(user: user)
                } label: {
                    Text("更新水鱼Token")
                }
            } header: {
                Text("传分")
            }
            
            Section {
                HStack {
                    Text("舞萌DX单曲金额")
                    Spacer()
                    TextField("默认为1元一曲", text: $user.maiPricePerTrack)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Text("中二节奏单曲金额")
                    Spacer()
                    TextField("默认为1元一曲", text: $user.chuPricePerTrack)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                }
            } header: {
                Text("出勤记录")
            }
            
            Section {
                NavigationLink {
                    SponsorView()
                } label: {
                    Text("鸣谢")
                }
                SettingsInfoLabelView(title: "版本", message: "\(bundleVersion) Build \(bundleBuildNumber)")
                Button {
                    if versionData.hasNewVersion(major: bundleVersion, minor: bundleBuildNumber) {
                        let updateAlert = Alert(
                            title: Text("发现新版本"),
                            message: Text("当前版本为：\(bundleVersion) Build \(bundleBuildNumber)\n最新版本为：\(versionData.major) Build \(versionData.minor)\n是否前往更新？"),
                            primaryButton: .default(Text("前往Testflight")) {
                                UIApplication.shared.open(URL(string: "itms-beta://testflight.apple.com/join/OBC08JvQ")!)
                            },
                            secondaryButton: .cancel(Text("取消")))
                        alertToast.alert = updateAlert
                    }
                } label: {
                    Text("检查新版本...")
                }
                Link("加入QQ讨论群", destination: URL(string: "mqqapi://card/show_pslcard?src_type=internal&version=1&uin=704639070&key=7a59abc8ca0e11d70e5d2c50b6740a59546c94d5dd082328e4790911bed67bd1&card_type=group&source=external&jump_from=webapi")!)
            } header: {
                Text("关于")
            }
            
            Section {
                SettingsInfoLabelView(title: "Token", message: user.jwtToken)
                    .lineLimit(1)
                SettingsInfoLabelView(title: "缓存大小", message: cacheSize)
                Button {
                    let purgeCacheAlert = Alert(title: Text("确定要清空吗？"), message: Text("将清空所有图片缓存，该操作不可逆。"), primaryButton: .cancel(Text("取消")), secondaryButton: .destructive(Text("清空"), action: {
                        cacheController.clearCache()
                        cacheSize = cacheController.getCacheSize()
                    }))
                    alertToast.alert = purgeCacheAlert
                } label: {
                    Text("清空缓存...")
                }
                .foregroundColor(.red)
                Button {
                    let refreshAlert = Alert(title: Text("确定要刷新吗？"), message: Text("将登出帐号，重新登录即可刷新歌曲列表。该操作耗时较长，请耐心等候。"), primaryButton: .cancel(Text("取消")), secondaryButton: .destructive(Text("刷新"), action: {
                        shouldForceReload = true
                        user.logout()
                    }))
                    alertToast.alert = refreshAlert
                } label: {
                    Text("刷新歌曲列表...")
                }
                .foregroundColor(.red)
                Button {
                    let eraseAlert = Alert(title: Text("确定要清空吗？"), message: Text("将登出并清空所有游戏数据，该操作不可逆。"), primaryButton: .cancel(Text("取消")), secondaryButton: .destructive(Text("清空"), action: {
                        user.logout()
                        // TODO: Add erase function
                    }))
                    alertToast.alert = eraseAlert
                } label: {
                    Text("清空游戏数据...")
                }
                .foregroundColor(.red)
            } header: {
                Text("高级")
            }
        }
        .toast(isPresenting: $alertToast.show, duration: 1, tapToDismiss: true) {
            alertToast.toast
        }
        .alert(isPresented: $alertToast.alertShow) {
            alertToast.alert
        }
        .onAppear {
            if (user.fishToken.isEmpty) {
                user.shouldForwardToFish = false
            }
            cacheSize = cacheController.getCacheSize()
            Task {
                do {
                    let versionRequest = URLRequest(url: URL(string: "http://43.139.107.206/chafenqi/version")!)
                    let (data, _) = try await URLSession.shared.data(for: versionRequest)
                    versionData = try JSONDecoder().decode(ClientVersionData.self, from: data)
                } catch {
                    versionData = .empty
                }
            }
        }
    }
}

struct SettingsInfoLabelView: View {
    @State var title: String
    @State var message: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(message)
                .foregroundColor(.gray)
        }
    }
}

struct UserInfoWithAvatarView: View {
    @ObservedObject var user: CFQNUser
    
    var body: some View {
        HStack {
            Image("Icon")
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(width: 55)
                .mask(Circle())
                .overlay(Circle().stroke(AngularGradient(gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]), center: .center), lineWidth: 2))
                .padding(5)
            VStack(alignment: .leading) {
                Text(user.username)
                    .bold()
                    .font(.system(size: 20))
                Text("📮")
            }
            Spacer()
            if (user.isPremium) {
                VStack {
                    HStack {
                        Image(systemName: "heart.fill")
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .foregroundColor(.red)
                            .padding(.vertical, 1)
                        Text("Sponsor")
                            .font(.system(size: 14))
                            .bold()
                    }
                    .frame(width: 100, height: 20)
                    Text("至\(parsePremiumExpireDate())")
                        .font(.system(size: 12))
                }
            }
        }
    }
    
    func parsePremiumExpireDate() -> String {
        let date = Date(timeIntervalSince1970: user.premiumUntil)
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd"
        formatter.locale = .autoupdatingCurrent
        return formatter.string(from: date)
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings(user: CFQNUser())
    }
}
