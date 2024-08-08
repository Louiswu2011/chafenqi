//
//  PacketTunnelProvider.swift
//  updater
//
//  Created by 刘易斯 on 2023/2/7.
//

import NetworkExtension

class UpdaterTunnelProvider: NEPacketTunnelProvider {
    var connection = NWTCPConnection()
    
    override init() {
        NSLog("PTP init.")
        self.readQueue = DispatchQueue.init(label: "readQueue")
        self.writeQueue = DispatchQueue.init(label: "writeQueue")
        self.shouldStop = false
        super.init()
    }

//    override func startTunnel(options: [String : NSObject]?, completionHandler: @escaping (Error?) -> Void) {
//        NSLog("Starting Tunnel...")
//        
//        let port = 8999
//        
//        let settings = self.initUpdaterSettings(host: "43.139.107.206", port: port)
//        self.setTunnelNetworkSettings(settings) { error in
//            if let e = error {
//                NSLog("Failed to save settings.")
//                NSLog(e.localizedDescription)
//                completionHandler(e)
//            } else {
//                NSLog("Setting endpoint...")
//                // let endpoint = NWHostEndpoint(hostname: "127.0.0.1", port: String(self.port))
//                // NSLog("Connecting to local server...")
//                let endpoint = NWHostEndpoint(hostname: "43.139.107.206", port: "8999")
//                self.connection = self.createTCPConnection(to: endpoint, enableTLS: false, tlsParameters: nil, delegate: nil)
//                NSLog("Connected to NLTV server.")
//                completionHandler(nil)
//                self.sendPackets()
//            }
//        }
//    }
    
    let mtu: UInt16 = 1500
    let maxPacketSize: size_t = 65535
    var _read_write_fd: Int32 = 0
    
    var readQueue: DispatchQueue
    var writeQueue: DispatchQueue
    var shouldStop: Bool
    
    override func startTunnel(options: [String : NSObject]? = nil, completionHandler: @escaping ((any Error)?) -> Void) {
        var _self = self

        withUnsafeMutablePointer(to: &_self) { pointer in
            tun2proxy_set_traffic_status_callback(2, { status, context in
                if let status = status?.pointee {
                    NSLog("tun2proxy Traffic: ▲ %llu : ▼ %llu", status.tx, status.rx)
                }
            }, pointer)
        }
        
        var socketDescriptors = UnsafeMutablePointer<Int32>.allocate(capacity: 2)
        if socketpair(AF_UNIX, SOCK_STREAM, 0, socketDescriptors) != 0 {
            completionHandler(NSError(domain: kCFBundleIdentifierKey as String, code: 1, userInfo: [NSLocalizedDescriptionKey : "Failed at socketpair."]))
            return
        }
        _read_write_fd = socketDescriptors[0]
        let tunFd: Int32 = socketDescriptors[1]
        
        DispatchQueue.main.async {
            let proxyUrl = "http://43.139.107.206:8999"
            let dnsStrategy: Tun2proxyDns = Tun2proxyDns_OverTcp
            let res = tun2proxy_with_fd_run(proxyUrl, tunFd, true, false, self.mtu, dnsStrategy, Tun2proxyVerbosity_Debug)
            if 0 != res {
                NSLog("Failed at tun2proxy_with_fd_run, error: %d", res)
                exit(-4)
            }
        }
        
        let settings = self.initUpdaterSettings(host: "43.139.107.206", port: 8999)
        self.setTunnelNetworkSettings(settings) { error in
            if let e = error {
                NSLog("Failed to save settings.")
                NSLog(e.localizedDescription)
                completionHandler(e)
            } else {
                // Start socket read/write
                self.readQueue.async {
                    self.readingPacketFlow()
                }
                self.writeQueue.async {
                    self.writingPacketFlow()
                }
                
                NSLog("Connected to NLTV server.")
                completionHandler(nil)
            }
        }
    }
    
    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        // Add code here to start the process of stopping the tunnel.
        NSLog("Stopping Tunnel...")
        tun2proxy_with_fd_stop()
        completionHandler()
    }
    
    func readingPacketFlow() {
        if shouldStop { return }
        
        self.packetFlow.readPackets { packets, protocols in
            for packet in packets {
                packet.withUnsafeBytes { bytes in
                    let buffer = bytes.baseAddress!
                    Darwin.write(self._read_write_fd, buffer, packet.count)
                }
            }
            self.readQueue.async {
                self.readingPacketFlow()
            }
        }
    }
    
    func writingPacketFlow() {
        if shouldStop { return }
        var buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: maxPacketSize)
        var msg = ""
        while (true) {
            let len = recv(self._read_write_fd, buffer, 4, 0)
            if len != 4 {
                if len < 0 {
                    msg = "Read error: len < 0"
                } else {
                    msg = "Read 4 bytes header failed: \(len)"
                }
                break
            }
            let version = (buffer[0] >> 4) & 0x0F
            let totalLength = (UInt8(integerLiteral: buffer[2]) << 8) | UInt8(integerLiteral: buffer[3])
            if (version != 4 && version != 6) || totalLength < 20 {
                msg = "Unknown protocol version: \(version), total length: \(totalLength)"
                break
            }
            let len2 = recv(self._read_write_fd, buffer + 4, Int(totalLength) - 4, 0)
            if len2 != totalLength - 4 {
                if len2 < 0 {
                    msg = "Read total length \(totalLength) bytes failed"
                } else {
                    msg = "Packet len: \(len2 + 4), but total length \(totalLength)"
                }
                break
            }
            
            let packet = Data(bytes: buffer, count: Int(totalLength))
            if version == 4 {
                self.packetFlow.writePackets([packet], withProtocols: [NSNumber(integerLiteral: Int(AF_INET))])
            } else if version == 6 {
                self.packetFlow.writePackets([packet], withProtocols: [NSNumber(integerLiteral: Int(AF_INET6))])
            }
            self.packetFlow.writePackets([packet], withProtocols: [NSNumber(integerLiteral: Int(AF_INET))])
        }
        buffer.deallocate()
//        if !msg.isEmpty {
//            NSLog(msg)
//        }
        self.writeQueue.async {
            self.writingPacketFlow()
        }
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
        
        settings.mtu = 1500
        
        return settings
    }
}


