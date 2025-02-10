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
    @State private var showingJWT = false
    @State private var loading = false
    
    @State private var versionData = 83
    
    @State private var iOSVersion = Int(UIDevice.current.systemVersion.split(separator: ".")[0])!
    
    @State private var chunithmSourceOptions = [0: "Github", 1: "NLServer"]
    @State private var chunithmChartSourceOptions = [0: "sdvx.in", 1: "NLServer"]
    @State private var maimaiSourceOptions = [0: "Diving-Fish"]
    @State private var modeOptions = [0: "中二节奏NEW", 1: "舞萌DX"]
    @State private var bundleVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    @State private var bundleBuildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
    
    @State private var shouldOpenMiniGame = false
    
    @State private var widgetData = WidgetData.Customization()
    
    var body: some View {
        Form {
            Section {
                UserInfoWithAvatarView(user: user)
                NavigationLink {
                    UserLinkOptionView(user: user)
                } label: {
                    Text("帐号关联")
                }
                NavigationLink {
                    RedeemView(user: user)
                } label: {
                    Text("兑换会员")
                }
                Button {
                    let logoutAlert = Alert(title: Text("确定要登出吗？"), primaryButton: .cancel(Text("取消")), secondaryButton: .default(Text("登出"), action: {
                        user.logout()
                    }))
                    alertToast.alert = logoutAlert
                } label: {
                    Text("登出")
                }
                .foregroundColor(.red)
            }
            
            Section {
                Toggle("显示距上次出勤天数", isOn: $user.showDaysSinceLastPlayed)
                Toggle("显示刷新按钮", isOn: $user.shouldShowRefreshButton)
                Toggle("使用版本主题色", isOn: $user.homeUseCurrentVersionTheme)
                Toggle("隐藏团队功能", isOn: $user.hideTeamEntry)
                NavigationLink {
                    SettingsHomeArrangement()
                } label: {
                    Text("排序")
                }
                NavigationLink {
                    if user.isPremium {
                        SettingsWidgetConfig(user: user, currentWidgetSettings: $widgetData)
                    } else {
                        NotPremiumView()
                    }
                } label: {
                    Text("小组件")
                }
            } header: {
                Text("主页")
            }
            
            Section {
                if (user.remoteOptions.forwardToFish) {
                    SettingsInfoLabelView(title: "Token", message: user.remoteOptions.fishToken)
                        .lineLimit(1)
                }
                NavigationLink {
                    TokenUploderView(user: user)
                } label: {
                    Text("更新水鱼Token")
                }
                Toggle("提示未绑定水鱼账号", isOn: $user.proxyShouldPromptLinking)
                Toggle("自动检查水鱼Token", isOn: $user.proxyShouldPromptExpiring)
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
                ZStack {
                    SettingsInfoLabelView(title: "版本", message: "\(bundleVersion) Build \(bundleBuildNumber)")
                        .onTapGesture(count: 5) {
                            shouldOpenMiniGame.toggle()
                        }
                    NavigationLink(
                        destination: ClickGameView(),
                        isActive: $shouldOpenMiniGame) {
                            EmptyView()
                        }
                        .hidden()
                }
                Button {
                    if versionData > Int(bundleBuildNumber) ?? 83 {
                        let updateAlert = Alert(
                            title: Text("发现新版本"),
                            message: Text("当前版本为：Build \(bundleBuildNumber)\n最新版本为：Build \(versionData)\n是否前往更新？"),
                            primaryButton: .default(Text("前往Testflight")) {
                                UIApplication.shared.open(URL(string: "itms-beta://testflight.apple.com/join/OBC08JvQ")!)
                            },
                            secondaryButton: .cancel(Text("取消")))
                        alertToast.alert = updateAlert
                    } else {
                        alertToast.toast = AlertToast(displayMode: .hud, type: .complete(.green), title: "已是最新版本")
                    }
                } label: {
                    Text("检查新版本")
                }
                Link("加入QQ讨论群", destination: URL(string: "mqqapi://card/show_pslcard?src_type=internal&version=1&uin=706609485&authSig=MyMU8skdQzrZ0b7ClNlpboBonHCMzO4H3qROrB274Sel+Y89lxrBKGUoja2y/Ri7&card_type=group&source=external&jump_from=webapi")!)
            } header: {
                Text("关于")
            }
            
            Section {
                HStack {
                    Text("Token")
                    Spacer()
                    Text(showingJWT ? user.jwtToken : "点击显示")
                        .foregroundColor(.gray)
                        .onTapGesture {
                            withAnimation {
                                showingJWT.toggle()
                            }
                        }
                }
                Toggle("自动更新歌曲列表", isOn: $user.shouldAutoUpdateSongList)
                NavigationLink {
                    LogView()
                } label: {
                    Text("调试输出")
                }
                Button {
                    let purgeCacheAlert = Alert(title: Text("确定要清空吗？"), message: Text("将清空所有图片缓存，该操作不可逆。"), primaryButton: .cancel(Text("取消")), secondaryButton: .destructive(Text("清空"), action: {
                        DispatchQueue.main.async {
                            cacheController.clearCache()
                        }
                    }))
                    alertToast.alert = purgeCacheAlert
                } label: {
                    Text("清空缓存")
                }
                .foregroundColor(.red)
                Button {
                    let refreshAlert = Alert(title: Text("确定要刷新吗？"), message: Text("将登出帐号，重新登录即可刷新歌曲列表。该操作耗时较长，请耐心等候。"), primaryButton: .cancel(Text("取消")), secondaryButton: .destructive(Text("刷新"), action: {
                        shouldForceReload = true
                        user.logout()
                    }))
                    alertToast.alert = refreshAlert
                } label: {
                    Text("刷新歌曲列表")
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
            if (user.remoteOptions.fishToken.isEmpty) {
                user.remoteOptions.forwardToFish = false
            }
            Task {
                do {
                    let versionRequest = URLRequest(url: URL(string: "\(CFQServer.serverAddress)api/stat/version/app/ios")!)
                    let (data, _) = try await URLSession.shared.data(for: versionRequest)
                    versionData = Int(String(data: data, encoding: .utf8) ?? "83") ?? 83
                } catch {
                    versionData = 83
                }
            }
            do {
                widgetData = try JSONDecoder().decode(WidgetData.Customization.self, from: user.widgetCustom)
            } catch {
                
            }
        }
        .navigationTitle("设置")
        .navigationBarTitleDisplayMode(.inline)
        .analyticsScreen(name: "settings_screen")
    }
}

struct SettingsInfoLabelView: View {
    @State var title: String
    @State var message: String
    
    let lineLimit: Int = 1
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(message)
                .foregroundColor(.gray)
        }
        .lineLimit(lineLimit)
    }
}

struct SettingsInfoLabelButton: View {
    let title: String
    let message: String
    
    let action: () -> Void
    let lineLimit: Int = 1
    
    var body: some View {
        HStack {
            Button {
                action()
            } label: {
                HStack {
                    Text(title)
                    Spacer()
                    Text(message)
                        .foregroundStyle(Color.gray)
                    Image(systemName: "chevron.right")
                        .foregroundStyle(Color.secondary)
                }
                .lineLimit(lineLimit)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
            }
        }
        .buttonStyle(.plain)
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
                    .scaledToFit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.1)
                    .font(.system(size: 20))
                if user.isPremium {
                    Text("订阅有效至\(parsePremiumExpireDate())")
                        .lineLimit(1)
                        .scaledToFit()
                        .minimumScaleFactor(0.1)
                        .font(.system(size: 12))
                }
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
                }
            }
        }
    }
    
    func parsePremiumExpireDate() -> String {
        let date = Date(timeIntervalSince1970: user.premiumUntil)
        let formatter = DateTool.shared.yyyymmddTransformer
        return formatter.string(from: date)
    }
}

struct Settings_Previews: PreviewProvider {
    static var previews: some View {
        Settings(user: CFQNUser())
    }
}

struct ClientVersionData: Codable {
    var major: String = ""
    var minor: String = ""
    
    var majorBeta: String = ""
    var minorBeta: String = ""
    
    var currentLeadingBranch: String = ""
    
    static let empty = ClientVersionData()
    init() { self.major = "empty" }
    
    func hasNewVersion(major: String, minor: String) -> Bool {
        let localMinor = Int(minor) ?? 0
        let remoteMinor = Int(self.minor) ?? 0
        return localMinor < remoteMinor
    }
}
