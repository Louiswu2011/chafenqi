//
//  SettingsView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/9.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("settingsCoverSource") var coverSource = ""
    
    @AppStorage("userAccountName") var accountName = "louisb"
    @AppStorage("userNickname") var accountNickname = ""
    @AppStorage("userToken") var token = ""
    @AppStorage("userTokenHeader") var tokenHeader = ""
    @AppStorage("userInfoData") var infoData = Data()
    
    @AppStorage("didLogin") var didLogin = false
    
    @State private var accountPassword = ""
    @State private var showingLoginView = false
    @State private var showingBuildNumber = false
    @State private var loading = false
    
    @Binding var showingSettings: Bool
    
    var sourceOptions = ["Github", "Gitee"]
    var accountOptions = ["QQ号", "账户名"]
    var bundleVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    var bundleBuildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker("封面来源", selection: $coverSource) {
                        ForEach(sourceOptions, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.automatic)
                } header: {
                    Text("常规")
                } footer: {
                    Text("Gitee暂不可用")
                }
                
                Section {
                    if (didLogin) {
                        HStack {
                            TextInfoView(text: "Token", info: token)
                        }
                        TextInfoView(text: "用户名", info: accountName)
                        TextInfoView(text: "Token", info: token)
                        Button {
                            clearUserCache()
                            didLogin.toggle()
                        } label: {
                            Text("登出")
                                .foregroundColor(Color.red)
                        }
                    } else {
                        TextField("用户名", text: $accountName)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                        SecureField("密码", text: $accountPassword)
                        HStack {
                            Button {
                                Task {
                                    do {
                                        loading.toggle()
                                        (tokenHeader, token) = try await ProbeDataGrabber.loginAs(username: accountName, password: accountPassword)
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
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("\(bundleVersion) \(showingBuildNumber ? "Build \(bundleBuildNumber)" : "")")
                            .foregroundColor(Color.gray)
                            .onTapGesture {
                                showingBuildNumber.toggle()
                            }
                    }
                    Button() {
                        
                    } label: {
                        Text("请作者打一把中二")
                    }.disabled(true)
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
        infoData = Data()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(showingSettings: .constant(true))
    }
}
