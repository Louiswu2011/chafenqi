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
    @State private var isShowingBind = false
    
    @State private var isProxyOn = false
    @State private var proxyStatus = ""
    
    @State private var chuniAvg = "加载中..."
    @State private var maiAvg = "加载中..."
    
    @State private var observers = [AnyObject]()
    
    @State private var startProxyActivity = "StartProxyIntent"
    @State private var stopProxyActivity = "StopProxyIntent"
    
    @State private var statusCheckTimer = Timer.publish(every: 5, tolerance: 1, on: .main, in: .common).autoconnect()
    @State private var uploadStatus = "未开始上传"
    
    @State private var quickUploadDestination = CFQServer.GameType.Maimai
    @State private var maiCookieStatus = "加载中..."
    @State private var chuCookieStatus = "加载中..."
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("开关")
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
                HStack {
                    Text("状态")
                    Spacer()
                    Text(uploadStatus)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.trailing)
                        .onReceive(statusCheckTimer) { time in
                            Task {
                                try await updateUploadStatus()
                            }
                        }
                }
            } header: {
                Text("代理")
            }
            
            Section {
                Picker("游戏", selection: $quickUploadDestination) {
                    ForEach(CFQServer.GameType.allCases) { value in
                        Text(value.rawValue)
                            .tag(value)
                    }
                }
                HStack {
                    Text("缓存状态")
                    Spacer()
                    Text(quickUploadDestination == .Maimai ? maiCookieStatus : chuCookieStatus)
                        .foregroundColor(.gray)
                }
                Button {
                    Task {
                        await triggerQuickUpload(destination: quickUploadDestination, authToken: user.jwtToken, forwarding: user.shouldForwardToFish)
                    }
                } label: {
                    Text("开始上传")
                }
            } header: {
                Text("快速上传")
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
                    copyUrlToClipboard(mode: 1)
                } label: {
                    Text("复制舞萌DX链接")
                }
                .disabled(!user.didLogin)
                
                Button {
                    copyUrlToClipboard(mode: 0)
                } label: {
                    Text("复制中二节奏链接")
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
                Button {
                    alertToast.alert = Alert(title: Text("提示"), message: Text("请前往QQ群文件下载\"oneclick.shortcut\"并导入到快捷指令中使用。"))
                } label: {
                    Text("添加到快捷指令")
                }
                
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
            
            if user.fishToken.isEmpty {
                if user.proxyShouldPromptLinking {
                    alertToast.alert = Alert(title: Text("提示"),
                                             message: Text("您当前暂未绑定水鱼账号，将无法同步数据到水鱼网。是否现在进行绑定？\n\n（稍后可以在设置 - 更新水鱼Token中绑定）"),
                                             primaryButton: .cancel(Text("不再提醒"), action: { self.user.proxyShouldPromptLinking = false }),
                                             secondaryButton: .default(Text("绑定"), action: { self.isShowingBind.toggle() }))
                }
            } else {
                user.proxyShouldPromptLinking = false
            }
            
            statusCheckTimer = Timer.publish(every: 5, tolerance: 1, on: .main, in: .common).autoconnect()
        }
        .onDisappear {
            statusCheckTimer.upstream.connect().cancel()
        }
        .sheet(isPresented: $isShowingQRCode) {
            UpdaterQRCodeView(maiStr: makeUrl(mode: 1), chuStr: makeUrl(mode: 0))
        }
        .sheet(isPresented: $isShowingBind) {
            TokenUploderView(user: user)
        }
        .toast(isPresenting: $alertToast.show) {
            alertToast.toast
        }
        
    }
    
    func loadVar() {
        Task {
            do {
                try await makeServerStatusText()
                try await updateUploadStatus()
                try await updateCookieStatus()
            } catch {
                print(error)
                chuniAvg = "暂无数据"
                maiAvg = "暂无数据"
            }
        }
    }
    
    func updateCookieStatus() async throws {
        maiCookieStatus = try await CFQUserServer.fetchCookieStatus(game: .Maimai, authToken: user.jwtToken) ? "好" : "无数据"
        chuCookieStatus = try await CFQUserServer.fetchCookieStatus(game: .Chunithm, authToken: user.jwtToken) ? "好" : "无数据"
    }
    
    func triggerQuickUpload(destination: CFQServer.GameType, authToken: String, forwarding: Bool) async {
        do {
            if !(try await CFQUserServer.fetchIsUploading(game: destination, authToken: authToken)) {
                try await CFQServer.triggerUpload(game: destination, authToken: authToken, forwarding: forwarding)
                alertToast.toast = AlertToast(displayMode: .hud, type: .complete(.green), title: "已开始上传", subTitle: "请留意App通知")
            } else {
                alertToast.toast = AlertToast(displayMode: .hud, type: .error(.yellow), title: "上传失败", subTitle: "您有正在进行的上传任务，请稍后")
            }
        } catch {
            print("[Updater] Perform quick upload failed", error)
            alertToast.toast = AlertToast(displayMode: .hud, type: .error(.red), title: "上传失败", subTitle: "无法启动快速上传服务")
        }
    }
    
    func updateUploadStatus() async throws {
        let status = try await makeUploadStatusText()
        DispatchQueue.main.async {
            self.uploadStatus = status
        }
        print("[Updater] Got update status from server: ", status)
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
    
    func makeUploadStatusText() async throws -> String {
        let status = try await CFQStatsServer.checkUploadStatus(authToken: user.jwtToken)
        var string = ""
        switch status[0] {
        case 0:
            string += "中二节奏：认证中"
        case 1:
            string += "中二节奏：更新最好成绩"
        case 2:
            string += "中二节奏：更新最近记录"
        case 3:
            string += "中二节奏：更新玩家信息"
        case 4:
            string += "中二节奏：更新出勤记录"
        case 5:
            string += "中二节奏：更新收藏品信息"
        case 6:
            string += "中二节奏：更新Rating列表"
        default:
            break
        }
        if status[1] != -1 {
            string += "\n"
        }
        switch status[1] {
        case 0:
            string += "舞萌DX：认证中"
        case 1:
            string += "舞萌DX：更新玩家信息"
        case 2:
            string += "舞萌DX：更新出勤记录"
        case 3:
            string += "舞萌DX：更新收藏品信息"
        case 4:
            string += "舞萌DX：更新最好成绩"
        case 5:
            string += "舞萌DX：更新最近记录"
        default:
            break
        }
        if string.isEmpty {
            string = "未开始上传"
        }
        return string
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
