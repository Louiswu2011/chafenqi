//
//  PacketTunnelProvider.swift
//  updater
//
//  Created by 刘易斯 on 2023/2/7.
//

import NetworkExtension

extension NWTCPConnectionState: CustomStringConvertible {
    public var description: String {
        switch self {
        case .cancelled: return "Cancelled"
        case .connected: return "Connected"
        case .connecting: return "Connecting"
        case .disconnected: return "Disconnected"
        case .invalid: return "Invalid"
        case .waiting: return "Waiting"
        @unknown default:
            return "Unknown State"
        }
    }
}

class UpdaterTunnelProvider: NEPacketTunnelProvider {
    var connection = NWTCPConnection()
    
    override init() {
        NSLog("PTP init.")
        super.init()
    }

    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        NSLog("Starting Tunnel...")
        
        let port = 8999
        
        let settings = self.initUpdaterSettings(host: "43.139.107.206", port: port)
        self.setTunnelNetworkSettings(settings) { error in
            if let e = error {
                NSLog("Failed to save settings.")
                NSLog(e.localizedDescription)
                completionHandler(e)
            } else {
                NSLog("Setting endpoint...")
                let endpoint = NWHostEndpoint(hostname: "43.139.107.206", port: "8999")
                self.connection = self.createTCPConnection(to: endpoint, enableTLS: false, tlsParameters: nil, delegate: nil)
                
                while self.connection.state != .connected {}
                NSLog("Connected to NLTV server. Status: \(self.connection.state.description)")
                completionHandler(nil)
                
                self.sendPackets()
            }
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        // Add code here to start the process of stopping the tunnel.
        NSLog("Stopping Tunnel...")
        completionHandler()
    }
    
    
    
    override func handleAppMessage(_ messageData: Data, completionHandler: ((Data?) -> Void)?) {
        // Add code here to handle the message.
        if let handler = completionHandler {
            handler(messageData)
        }
    }
    
    override func sleep(completionHandler: @escaping () -> Void) {
        // Add code here to get ready to sleep.
        completionHandler()
    }
    
    override func wake() {
        // Add code here to wake up.
    }
    
    private func sendPackets() {
        packetFlow.readPacketObjects { [weak self] (packetObjects) in
            guard let strongSelf = self else { return }
            defer { strongSelf.sendPackets() }
            
            for packetObject in packetObjects {
                NSLog("[Updater] Packet: \(packetObject.data.map { String(format: "%02hhx", $0) }.joined())")
                strongSelf.sendSingleTCPPacket(provider: strongSelf, packet: packetObject)
            }
        }
    }
    
    private func sendSingleTCPPacket(provider: UpdaterTunnelProvider, packet: NEPacket) {
        NSLog("connection: \(connection.state.description), target: \(connection.endpoint), isViable: \(connection.isViable), hasBetterPath: \(connection.hasBetterPath)")
        self.connection.write(packet.data, completionHandler: { error in
            if error != nil {
                NSLog("[Updater] Packet failed to send. Size: \(packet.data.count), sa_family: \(packet.protocolFamily)")
                // provider.connection = NWTCPConnection(upgradeFor: provider.connection)
                // self.sendSinglePacket(provider: provider, packet: packet)
            } else {
                NSLog("Sent packet.")
            }
        })
    }
    
    private func initUpdaterSettings(host: String, port: Int) -> NEPacketTunnelNetworkSettings {
        let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "43.139.107.206")
        
        let proxySettings = NEProxySettings()
        proxySettings.httpServer = NEProxyServer(address: host, port: port)
        proxySettings.httpsServer = NEProxyServer(address: host, port: port)
        proxySettings.autoProxyConfigurationEnabled = false
        proxySettings.httpEnabled = true
        proxySettings.httpsEnabled = true
        proxySettings.excludeSimpleHostnames = true
        proxySettings.exceptionList = [
            "192.168.0.0/16",
            "10.0.0.1/8",
            "172.16.0.0./12",
            "127.0.0.1",
            "localhost",
            "*.local"
        ]
        settings.proxySettings = proxySettings
        
        let ipv4Settings = NEIPv4Settings(addresses: [settings.tunnelRemoteAddress], subnetMasks: ["255.255.255.255"])
        ipv4Settings.includedRoutes = [NEIPv4Route.default()]
        ipv4Settings.excludedRoutes = [
            NEIPv4Route(destinationAddress: "192.168.0.0", subnetMask: "255.255.0.0"),
            NEIPv4Route(destinationAddress: "10.0.0.0", subnetMask: "255.0.0.0"),
            NEIPv4Route(destinationAddress: "172.16.0.0", subnetMask: "255.240.0.0")
        ]
        settings.ipv4Settings = ipv4Settings
        settings.ipv6Settings = nil
        
        settings.mtu = 1500
        
        return settings
    }
}


