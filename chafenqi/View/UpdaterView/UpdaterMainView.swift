//
//  UpdaterMainView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/8.
//

import SwiftUI

struct UpdaterMainView: View {
    @ObservedObject var service = TunnelManagerService.shared
    
    @State var isProxyOn = false
    @State var proxyStatus = ""
    
    @State private var observers = [AnyObject]()
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("连接状态")
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
                Text("状态")
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
        service.manager?.saveToPreferences { _ in
            service.manager?.loadFromPreferences { _ in
                do {
                    try service.manager?.connection.startVPNTunnel(options: [:] as [String : NSObject] )
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
}

struct UpdaterMainView_Previews: PreviewProvider {
    static var previews: some View {
        UpdaterMainView()
    }
}
