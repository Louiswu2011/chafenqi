//
//  SettingsView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/9.
//

import SwiftUI
import AlertToast

struct SettingsView: View {
    @AppStorage("firstTimeLaunch") var firstTime = true
    
    @AppStorage("proxyDidInstallProfile") var installed = false
    
    @ObservedObject var toastManager = AlertToastManager.shared
    
    @ObservedObject var user = CFQUser()
    
    @State private var accountName = ""
    @State private var accountPassword = ""
    @State private var showingLoginView = false
    @State private var showingBuildNumber = false
    @State private var showingClearAlert = false
    @State private var showingNewVersionAlert = false
    @State private var loading = false
    
    @State private var versionData = ClientVersionData.empty
    
    let iOSVersion = Int(UIDevice.current.systemVersion.split(separator: ".")[0])!
    
    var chunithmSourceOptions = [0: "Github", 1: "NLServer"]
    var maimaiSourceOptions = [0: "Diving-Fish"]
    var modeOptions = [0: "中二节奏NEW", 1: "舞萌DX"]
    var bundleVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    var bundleBuildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
    
    var body: some View {

        Form {
            Section {
                HStack {
                    if (user.currentMode == 0) {
                        if (iOSVersion == 15) {
                            Text("封面来源")
                            Spacer()
                        }
                        Picker(selection: user.$chunithmCoverSource) {
                            ForEach(chunithmSourceOptions.sorted(by: <), id: \.key) {
                                Text($0.value)
                            }
                        } label: {
                            if (iOSVersion == 15) {
                                Text(chunithmSourceOptions[user.chunithmCoverSource]!)
                            } else {
                                Text("封面来源")
                            }
                        }
                        .pickerStyle(.menu)
                        
                    } else {
                        if (iOSVersion == 15) {
                            Text("封面来源")
                            Spacer()
                        }
                        Picker(selection: user.$maimaiCoverSource) {
                            ForEach(maimaiSourceOptions.sorted(by: <), id: \.key) {
                                Text($0.value)
                            }
                        } label: {
                            if (iOSVersion == 15) {
                                Text(maimaiSourceOptions[user.maimaiCoverSource]!)
                            } else {
                                Text("封面来源")
                            }
                        }
                        .pickerStyle(.menu)
                    }
                }
            } header: {
                Text("常规")
            } footer: {
                if (user.currentMode == 0) {
                    Text("国内访问推荐NLServer")
                }
            }
            
            Section {
                if (user.didLogin) {
                    TextInfoView(text: "用户名", info: user.username)
                    TextInfoView(text: "Token", info: user.token)
                    HStack {
                        if (iOSVersion == 15) {
                            Text("当前数据来源")
                            Spacer()
                        }
                        Picker(selection: user.$currentMode) {
                            ForEach(modeOptions.sorted(by: <), id: \.key) {
                                Text($0.value)
                            }
                        } label: {
                            if (iOSVersion == 15) {
                                Text(modeOptions[user.currentMode]!)
                            } else {
                                Text("当前数据来源")
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    Button {
                        user.didLogin = false
                        clearUserCache()
                    } label: {
                        Text("登出")
                            .foregroundColor(Color.red)
                    }
                } else {
                    if #available(iOS 15.0, *) {
                        TextField("用户名", text: $accountName)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                    } else {
                        TextField("用户名", text: $accountName)
                            .autocapitalization(.none)
                            .autocorrectionDisabled(true)
                    }
                    SecureField("密码", text: $accountPassword)
                    HStack {
                        Button {
                            Task {
                                do {
                                    loading.toggle()
                                    user.clear()
                                    (_, user.token) = try await ChunithmDataGrabber.loginAs(username: accountName, password: accountPassword)
                                    sharedContainer.set(user.token, forKey: "userToken")
                                    sharedContainer.synchronize()
                                    user.shouldReload = true
                                    user.didLogin = true
                                } catch CFQError.AuthenticationFailedError {
                                    // TODO: Show wrong credentials toast
                                } catch {
                                    
                                }
                                loading.toggle()
                            }
                        } label: {
                            Text("登录")
                        }
                        if (loading) {
                            Spacer()
                            
                            ProgressView()
                        }
                    }
                }
            } header: {
                Text("账户")
            }
            
            if(user.didLogin) {
                Section {
                    HStack {
                        Text("显示条目数")
                        Spacer()
                        TextField("默认为30", text: user.$entryCount)
                            .multilineTextAlignment(.trailing)
                            .keyboardType(.numberPad)
                    }
                    
                    Button {
                        showingClearAlert.toggle()
                    } label: {
                        Text("删除所有记录...")
                    }
                    .alert(isPresented: $showingClearAlert) {
                        Alert(
                            title: Text("警告"),
                            message: Text("这将会删除保存在服务器上的所有最近记录，且无法复原。"),
                            primaryButton: .cancel(Text("取消")),
                            secondaryButton: .destructive(Text("确定"), action: {
                                Task {
                                    do {
                                        let statusCode = try await clearRecentDatabase(username: user.username)
                                        if (statusCode == 200) {
                                            toastManager.showingRecordDeleted.toggle()
                                        }
                                    } catch {
                                        
                                    }
                                }
                            })
                        )
                    }
                    .accentColor(.red)
                    
                    
                } header: {
                    Text("最近记录")
                } footer: {
                    Text("最近记录数据保存在查分器App服务器，不会保存水鱼服务器的密码")
                        .multilineTextAlignment(.leading)
                }
            }
            
            Section {
                NavigationLink {
                    RandomizerSettingsView()
                } label: {
                    Text("随机歌曲")
                }
            } header: {
                Text("工具")
            }
            
            Button {
                firstTime = true
                toastManager.showingTutorialReseted = true
            } label: {
                if (!firstTime) {
                    Text("重置教程")
                } else {
                    Text("教程已重置")
                }
            }
            .disabled(firstTime)
            
            Section {
                HStack {
                    Text("版本")
                    Spacer()
                    Text("\(bundleVersion) \(showingBuildNumber ? "Build \(bundleBuildNumber)" : "")")
                        .foregroundColor(Color.gray)
                        .onTapGesture {
                            showingBuildNumber.toggle()
                        }
                }
                
                Button {
                    if (versionData.hasNewVersion(major: bundleVersion, minor: bundleBuildNumber)) {
                        showingNewVersionAlert.toggle()
                    }
                } label: {
                    Text("检查新版本...")
                }
                .alert(isPresented: $showingNewVersionAlert) {
                    Alert(
                        title: Text("发现新版本"),
                        message: Text("当前版本为：\(bundleVersion) Build \(bundleBuildNumber)\n最新版本为：\(versionData.major) Build \(versionData.minor)\n是否前往更新？"),
                        primaryButton: .default(Text("前往Testflight")) {
                            UIApplication.shared.open(URL(string: "itms-beta://testflight.apple.com/join/OBC08JvQ")!)
                        },
                        secondaryButton: .cancel(Text("取消")))
                }
                
                Link("加入QQ讨论群", destination: URL(string: "mqqapi://card/show_pslcard?src_type=internal&version=1&uin=704639070&key=7a59abc8ca0e11d70e5d2c50b6740a59546c94d5dd082328e4790911bed67bd1&card_type=group&source=external&jump_from=webapi")!)
                
                Link("到Github提交反馈", destination: URL(string: "https://github.com/Louiswu2011/chafenqi/issues")!)
                
                Link("请作者打一把中二", destination: URL(string: "https://afdian.net/a/chafenqi")!)
                
                NavigationLink {
                    SponsorView()
                } label: {
                    Text("鸣谢")
                }
                
            } header: {
                Text("关于")
            }
        }
        .navigationTitle("设置")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
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
    
    func clearUserCache(){
        user.clear()
    }
    
    func clearRecentDatabase(username: String) async throws -> Int {
        let url = URL(string: "http://43.139.107.206/drop_recent?username=\(username.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "")")!
        let request = URLRequest(url: url)
        
        let (_, response) = try await URLSession.shared.data(for: request)
        return response.statusCode()
    }
}

struct RandomizerSettingsView: View {
    @AppStorage("settingsRandomizerFilterMode") var filterMode = 0
    
    let filterOptions = [0: "无", 1: "仅未游玩歌曲", 2: "仅已游玩歌曲"]
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("筛选模式")
                    Spacer()
                    Picker("", selection: $filterMode) {
                        ForEach(filterOptions.sorted(by: <), id: \.key) {
                            Text($0.value)
                        }
                    }
                    .pickerStyle(.menu)
                }
            } header: {
                Text("常规")
            }
        }
        .navigationTitle("随机歌曲")
        .navigationBarTitleDisplayMode(.inline)
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
        self.major != major || self.minor != minor
    }
}
