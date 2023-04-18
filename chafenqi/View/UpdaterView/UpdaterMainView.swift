//
//  UpdaterMainView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/8.
//

import SwiftUI

struct UpdaterMainView: View {
    @ObservedObject var user: CFQUser
    @ObservedObject var service = TunnelManagerService.shared
    @ObservedObject var toastManager = AlertToastManager.shared
    
    @State var isShowingAlert = false
    @State var isShowingConfig = false
    @State var isShowingHelp = false
    
    @State var isProxyOn = false
    @State var proxyStatus = ""
    
    @State private var observers = [AnyObject]()

    @State private var startProxyActivity = "StartProxyIntent"
    @State private var stopProxyActivity = "StopProxyIntent"
    
    let shortcutPath = "http://43.139.107.206/chafenqi/shortcut".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    let shortcutName = "一键传分".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("状态")
                    Spacer()
                    Toggle(isOn: $isProxyOn) {
                        Text(proxyStatus)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .foregroundColor(.gray)
                    }
                    .onChange(of: isProxyOn) { value in
                        if value {
                            startProxyByUser()
                        } else {
                            stopProxyByUser()
                        }
                    }
                    
                }
            } header: {
                Text("连接")
            }
            
            Section {
                Button {
                    isShowingAlert.toggle()
                } label: {
                    Text("卸载描述文件...")
                        .foregroundColor(.red)
                }
                .alert(isPresented: $isShowingAlert) {
                    Alert(title: Text("警告"),
                          message: Text("仅当代理出现问题时才需要重新安装描述文件"),
                          primaryButton: .cancel(Text("取消")),
                          secondaryButton: .destructive(Text("卸载")){ removeProxyProfile() })
                }
                
                
            } header: {
                Text("设置")
            }
            
            Section {
                if (user.didLogin) {
                    TextInfoView(text: "当前账号", info: user.username)
                }
                
                Button {
                    copyUrlToClipboard(mode: 0)
                } label: {
                    Text("上传中二节奏分数...")
                }
                .disabled(!user.didLogin)
                
                Button {
                    copyUrlToClipboard(mode: 1)
                } label: {
                    Text("上传舞萌DX分数...")
                }
                .disabled(!user.didLogin)
                
            } footer: {
                if (user.didLogin) {
                    Text("请将剪贴板的内容复制到微信任意聊天窗口后发送并打开")
                        .multilineTextAlignment(.leading)
                } else {
                    Text("请在设置中登录查分器账号后再上传分数")
                        .multilineTextAlignment(.leading)
                }
            }
            
            Section {
                Link("添加到快捷指令", destination: URL(string: "shortcuts://import-shortcut?url=\(shortcutPath)&name=\(shortcutName)&silent=true")!)
                
                Button {
                    isShowingHelp.toggle()
                } label: {
                    Text("使用教程")
                }
                .sheet(isPresented: $isShowingHelp) {
                    UpdaterHelpView(isShowingHelp: $isShowingHelp)
                }
            }
        }
        .onAppear {
            refreshStatus()
            registerObserver()
        }
        
    }
    
    func registerObserver() {
        observers.append(NotificationCenter.default.addObserver(forName: .NEVPNStatusDidChange, object: service.manager?.connection, queue: .main) { _ in
            self.refreshStatus()
        })
                         
        observers.append(NotificationCenter.default.addObserver(forName: .NEVPNConfigurationChange, object: service.manager, queue: .main) { _ in
            self.refreshStatus()
        })
        
     
    }
    
    func startProxyByUser() {
        print("Starting proxy...")
        service.manager?.loadFromPreferences { _ in
            service.manager?.isEnabled = true
            service.manager?.saveToPreferences { _ in
                do {
                    try service.manager?.connection.startVPNTunnel()
                } catch {
                    print("Failed to start proxy.")
                    print(error)
                }
            }
        }
    }
    
    func stopProxyByUser() {
        print("Stopping proxy...")
        service.manager?.connection.stopVPNTunnel()
    }
    
    func refreshStatus() {
        self.proxyStatus = service.manager?.connection.status.description ?? "未知状态"
        self.isProxyOn = service.manager?.connection.status != .disconnected && service.manager?.connection.status != .invalid
    }
    
    func removeProxyProfile() {
        service.removeProfile { _ in
            
        }
    }
    
    func copyUrlToClipboard(mode: Int) {
        let destination = mode == 0 ? "chunithm" : "maimai"
        let pasteboard = UIPasteboard.general
        let requestUrl = "http://43.139.107.206/upload_\(destination)?token=\(user.token)"

        pasteboard.string = requestUrl
        
        toastManager.showingUpdaterPasted = true
    }

}

struct UpdaterMainView_Previews: PreviewProvider {
    static var previews: some View {
        UpdaterMainView(user: CFQUser())
    }
}
