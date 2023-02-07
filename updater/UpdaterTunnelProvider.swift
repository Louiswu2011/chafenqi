//
//  PacketTunnelProvider.swift
//  updater
//
//  Created by 刘易斯 on 2023/2/7.
//

import NetworkExtension

class UpdaterTunnelProvider: NEPacketTunnelProvider {
    var connection = NWTCPConnection()
    
    let port = 8998
    let localServer: ProxyServer
    
    override init() {
        NSLog("PTP init.")
        localServer = ProxyServer(host: "127.0.0.1", port: port)
        super .init()
    }

    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
        NSLog("Starting Tunnel...")
        
        Task {
            localServer.start()
        }
        
        let settings = initUpdaterSettings(host: "127.0.0.1", port: port)
        setTunnelNetworkSettings(settings) { error in
            if let e = error {
                NSLog("Failed to save settings.")
                completionHandler(e)
            } else {
                NSLog("Setting endpoint...")
                let endpoint = NWHostEndpoint(hostname: "127.0.0.1", port: String(self.port))
                NSLog("Connecting to local server...")
                self.connection = self.createTCPConnection(to: endpoint, enableTLS: false, tlsParameters: nil, delegate: nil)
                completionHandler(nil)
            }
        }

        NSLog("Connected to local server.")
        self.sendPackets()
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        // Add code here to start the process of stopping the tunnel.
        NSLog("Stopping Tunnel...")
        localServer.stop()
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
    
    private func readPackets() {
        packetFlow.readPacketObjects { (packets) in
            defer { self.readPackets() }
            packets.forEach { [self] (packet) in
                NSLog("Packet: \(packet.data)")
            }
        }
    }
    
    
    private func sendPackets() {
        packetFlow.readPackets { [weak self] (packets, protocols) in
            guard let strongSelf = self else { return }
            
            for packet in packets {
                strongSelf.connection.write(packet, completionHandler: { error in
                    NSLog("Sent packet.")
                })
            }
            strongSelf.sendPackets()
        }
    }
    
    private func initUpdaterSettings(host: String, port: Int) -> NEPacketTunnelNetworkSettings {
        let settings = NEPacketTunnelNetworkSettings(tunnelRemoteAddress: "127.0.0.1")
        
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
        
        settings.mtu = 1500
        
        return settings
    }
}


