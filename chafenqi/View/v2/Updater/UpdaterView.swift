//
//  UpdaterView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/5/8.
//

import SwiftUI
import AlertToast
import CoreImage.CIFilterBuiltins

struct UpdaterView: View {
    @ObservedObject var user: CFQNUser
    @ObservedObject var service = TunnelManagerService.shared
    @ObservedObject var alertToast = AlertToastModel.shared
    
    @Environment(\.openURL) var openURL
    
    @State private var isShowingAlert = false
    @State private var isShowingConfig = false
    @State private var isShowingHelp = false
    @State private var isShowingQRCode = false
    
    @State private var isProxyOn = false
    @State private var proxyStatus = ""
    
    @State private var chuniAvg = "加载中..."
    @State private var maiAvg = "加载中..."
    
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
                // TextInfoView(text: "免登录传分", info: "无效")
                
            } header: {
                Text("连接")
            }
            
            Section {
                HStack {
                    Text("舞萌DX")
                    Spacer()
                    if maiAvg == "加载中..." {
                        ProgressView()
                    } else {
                        Text(maiAvg)
                            .foregroundColor(.gray)
                    }
                }
                HStack {
                    Text("中二节奏")
                    Spacer()
                    if chuniAvg == "加载中..." {
                        ProgressView()
                    } else {
                        Text(chuniAvg)
                            .foregroundColor(.gray)
                    }
                }
            } header: {
                Text("服务器状态")
            }

            Section {
                Button {
                    copyUrlToClipboard(mode: 0)
                } label: {
                    Text("复制中二节奏链接")
                }
                .disabled(!user.didLogin)
                
                Button {
                    copyUrlToClipboard(mode: 1)
                } label: {
                    Text("复制舞萌DX链接")
                }
                .disabled(!user.didLogin)
                
                Button {
                    isShowingQRCode.toggle()
                } label: {
                    Text("生成二维码")
                }
                
            } footer: {
                Text("为了保证您的数据安全，请勿将上传链接或二维码分享给任何人")
                    .multilineTextAlignment(.leading)
            }
            
            Section {
                Toggle(isOn: $user.shouldForwardToFish.animation()) {
                    Text("上传到水鱼网")
                }
                .disabled(user.fishToken.isEmpty)
                
                Toggle(isOn: $user.proxyAutoJump) {
                    Text("自动跳转到微信")
                }
                
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
            loadVar()
        }
        .sheet(isPresented: $isShowingQRCode) {
            UpdaterQRCodeView(maiStr: makeUrl(mode: 1), chuStr: makeUrl(mode: 0))
        }
        .toast(isPresenting: $alertToast.show) {
            alertToast.toast
        }
        
    }
    
    func loadVar() {
        Task {
            do {
                try await makeServerStatusText()
            } catch {
                print(error)
                chuniAvg = "暂无数据"
                maiAvg = "暂无数据"
            }
        }
    }
    
    func makeServerStatusText() async throws {
        let chuni = try await Double(CFQStatsServer.getAvgUploadTime(for: 0))!
        let mai = try await Double(CFQStatsServer.getAvgUploadTime(for: 1))!
        
        func makeStatusString(with time: Double) -> String {
            switch time {
            case ...0:
                return "暂无数据"
            case 0...45:
                return "畅通 (\(String(format: "%.2f", time))s)"
            case 45...120:
                return "缓慢 (\(String(format: "%.2f", time))s)"
            case 120...300:
                return "拥堵 (\(String(format: "%.2f", time))s)"
            case 300...:
                return "严重拥堵 (\(String(format: "%.2f", time))s)"
            default:
                return "暂无数据"
            }
        }
        
        chuniAvg = makeStatusString(with: chuni)
        maiAvg = makeStatusString(with: mai)
        // print("[Updater] Fetched average update time:", chuni, mai)
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
        print("[Updater] Starting proxy...")
        service.manager?.loadFromPreferences { _ in
            service.manager?.isEnabled = true
            service.manager?.saveToPreferences { _ in
                do {
                    try service.manager?.connection.startVPNTunnel()
                } catch {
                    print("[Updater] Failed to start proxy.")
                    print(error)
                }
            }
        }
    }
    
    func stopProxyByUser() {
        print("[Updater] Stopping proxy...")
        service.manager?.connection.stopVPNTunnel()
    }
    
    func refreshStatus() {
        self.proxyStatus = service.manager?.connection.status.description ?? "未知状态"
        self.isProxyOn = service.manager?.connection.status != .disconnected && service.manager?.connection.status != .invalid
        if self.service.manager?.connection.status == .connected && user.proxyAutoJump {
            openURL.callAsFunction(URL(string: "weixin://scanqrcode")!)
        }
    }
    
    func removeProxyProfile() {
        service.removeProfile { _ in
            
        }
    }
    
    func copyUrlToClipboard(mode: Int) {
        let pasteboard = UIPasteboard.general
        pasteboard.string = makeUrl(mode: mode)
        
        print("[Updater] Url copied.")
        alertToast.toast = AlertToast(displayMode: .hud, type: .complete(.green), title: "已复制到剪贴板")
    }
    
    func makeUrl(mode: Int) -> String {
        let destination = mode == 0 ? "chunithm" : "maimai"
        let forwarding = user.shouldForwardToFish ? 1 : 0
        return "http://43.139.107.206:8083/upload_\(destination)?jwt=\(user.jwtToken)&forwarding=\(forwarding)"
    }
}

struct UpdaterView_Previews: PreviewProvider {
    static var previews: some View {
        UpdaterView(user: CFQNUser())
    }
}

extension String {
    func makeQRCode(correctionLevel: String = "M") -> UIImage {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        
        filter.message = Data(self.utf8)
        filter.correctionLevel = correctionLevel
        
        if let outputImage = filter.outputImage?.transformed(by: CGAffineTransform(scaleX: 6, y: 6)) {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return UIImage(cgImage: cgimg)
            }
        }

        return UIImage(systemName: "xmark.circle") ?? UIImage()
    }
}
