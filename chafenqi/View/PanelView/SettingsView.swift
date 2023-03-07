//
//  SettingsView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/9.
//

import SwiftUI
import AlertToast

struct SettingsView: View {
    @AppStorage("settingsChunithmCoverSource") var chunithmCoverSource = 1
    @AppStorage("settingsMaimaiCoverSource") var maimaiCoverSource = 0
    @AppStorage("settingsCurrentMode") var currentMode = 0
    
    @AppStorage("firstTimeLaunch") var firstTime = true
    
    @AppStorage("proxyDidInstallProfile") var installed = false
    
    @AppStorage("userAccountName") var accountName = ""
    @AppStorage("userNickname") var accountNickname = ""
    @AppStorage("userToken") var token = ""
    @AppStorage("userTokenHeader") var tokenHeader = ""
    @AppStorage("userChunithmInfoData") var chunithmInfoData = Data()
    @AppStorage("userMaimaiInfoData") var maimaiInfoData = Data()
    @AppStorage("userMaimaiProfileData") var maimaiProfileData = Data()
    
    @AppStorage("didLogin") var didLogin = false

    @ObservedObject var toastManager = AlertToastManager.shared
    
    @State private var accountPassword = ""
    @State private var showingLoginView = false
    @State private var showingBuildNumber = false
    @State private var loading = false
    
    @Binding var showingSettings: Bool
    
    var chunithmSourceOptions = [0: "Github", 1: "NLServer"]
    var maimaiSourceOptions = [0: "Diving-Fish"]
    var modeOptions = [0: "中二节奏NEW", 1: "舞萌DX"]
    var bundleVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    var bundleBuildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Text("封面来源")
                        Spacer()
                        if (currentMode == 0) {
                            Picker(chunithmSourceOptions[chunithmCoverSource]!, selection: $chunithmCoverSource) {
                                ForEach(chunithmSourceOptions.sorted(by: <), id: \.key) {
                                    Text($0.value)
                                }
                            }
                            .pickerStyle(.menu)
                        } else {
                            Picker(maimaiSourceOptions[maimaiCoverSource]!, selection: $maimaiCoverSource) {
                                ForEach(maimaiSourceOptions.sorted(by: <), id: \.key) {
                                    Text($0.value)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    }
                } header: {
                    Text("常规")
                } footer: {
                    if (currentMode == 0) {
                        Text("国内访问推荐NLServer")
                    }
                }
                
                Section {
                    if (didLogin) {
                        TextInfoView(text: "用户名", info: accountName)
                        TextInfoView(text: "Token", info: token)
                        HStack {
                            Text("当前数据来源")
                            Spacer()
                            Picker(modeOptions[currentMode]!, selection: $currentMode) {
                                ForEach(modeOptions.sorted(by: <), id: \.key) {
                                    Text($0.value)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                        Button {
                            clearUserCache()
                            didLogin.toggle()
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
                                        (tokenHeader, token) = try await ChunithmDataGrabber.loginAs(username: accountName, password: accountPassword)
                                        didLogin.toggle()
                                        showingSettings.toggle()
                                    } catch CFQError.AuthenticationFailedError {
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
                        
                    Link("加入QQ讨论群", destination: URL(string: "mqqapi://card/show_pslcard?src_type=internal&version=1&uin=704639070&key=7a59abc8ca0e11d70e5d2c50b6740a59546c94d5dd082328e4790911bed67bd1&card_type=group&source=external&jump_from=webapi")!)
                    
                    Link("到Github提交反馈", destination: URL(string: "https://github.com/Louiswu2011/chafenqi/issues")!)
                    
                    Link("请作者打一把中二", destination: URL(string: "https://afdian.net/a/chafenqi")!)

                } header: {
                    Text("关于")
                } footer: {
                    Text(credits)
                }
            }
            .navigationTitle("设置")
        }
    }
    
    func clearUserCache(){
        accountName = ""
        accountPassword = ""
        accountNickname = ""
        tokenHeader = ""
        token = ""
        chunithmInfoData = Data()
        maimaiInfoData = Data()
        maimaiProfileData = Data()
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

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(showingSettings: .constant(true))
    }
}
