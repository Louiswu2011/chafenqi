//
//  TunnelManagerService.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/8.
//

import Foundation
import NetworkExtension
import UIKit

final class TunnelManagerService: ObservableObject {
    @Published private(set) var manager: NETunnelProviderManager?
    @Published private(set) var isStarted = false
    
    static let shared = TunnelManagerService()
    
    private var observer: AnyObject?
    
    private init() {
        observer = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak self] _ in
            self?.loadProfile { _ in }
        }
    }
    
    func loadProfile(_ completion: @escaping (Result<Void, Error>) -> Void) {
        NETunnelProviderManager.loadAllFromPreferences { [weak self] managers, error in
            guard let self = self else {
                NSLog("I'm not me.")
                return
            }
            
            self.manager = managers?.first
            if let error = error {
                NSLog("Error loaading profile:", String(describing: error))
                completion(.failure(error))
            } else {
                self.isStarted = true
                self.manager?.isEnabled = true
                print("Loaded preference from settings.")
                completion(.success(()))
            }
        }
    }
    
    func installProfile(_ completion: @escaping (Result<Void, Error>) -> Void) {
        let m = self.makeManager()
        m.saveToPreferences() { [weak self] error in
            if let error = error {
                return completion(.failure(error))
            }
            
            m.loadFromPreferences { [weak self] error in
                self?.manager = m
                completion(.success(()))
            }
        }
    }
    
    func removeProfile(_ completion: @escaping (Result<Void, Error>) -> Void) {
        assert(manager != nil, "Manager missing!")
        manager?.removeFromPreferences() { error in
            if let error = error {
                return completion(.failure(error))
            }
            
            self.manager = nil
            completion(.success(()))
        }
    }
    
    private func makeManager() -> NETunnelProviderManager {
        let manager = NETunnelProviderManager()
        manager.localizedDescription = "国服更新代理"
        
        let proto = NETunnelProviderProtocol()
        proto.providerBundleIdentifier = "com.nltv.chafenqi.updater"
        proto.serverAddress = "43.139.107.206"
        
        manager.protocolConfiguration = proto
        
        manager.isEnabled = true
        
        return manager
    }
}

extension NEVPNStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .disconnected: return "未连接"
        case .disconnecting: return "断开中"
        case .invalid: return "无效"
        case .connected: return "已连接"
        case .connecting: return "连接中"
        case .reasserting: return "重连中"
        @unknown default: return "未知"
        }
    }
}
