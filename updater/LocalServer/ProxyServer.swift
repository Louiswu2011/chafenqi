//
//  ProxyServer.swift
//  updater
//
//  Created by 刘易斯 on 2023/2/7.
//

import Foundation
import NIO
import NIOTransportServices

class ProxyServer {
    init(host: String, port: Int) {
        self.host = host
        self.port = port
    }
    
    func start() {
        do {
            // TODO: Add handler
            let bootstrap = NIOTSListenerBootstrap(group: group)
                .childChannelInitializer { channel in
                    channel.pipeline.configureHTTPServerPipeline()
                        .flatMap {
                            channel.pipeline.addHandler(ChunithmNetHandler())
                        }
                }
            
            let channel = try bootstrap
                .bind(host: host, port: port)
                .wait()
            
            NSLog("Server listening on \(host):\(port)")
            
            try channel.closeFuture.wait()
        } catch {
            print(error)
            exit(0)
        }
    }
    
    func stop() {
        do {
            print("Server shutting down...")
            try group.syncShutdownGracefully()
        } catch {
            print(error)
            exit(0)
        }
    }
    
    private let group = NIOTSEventLoopGroup(loopCount: ProcessInfo.processInfo.processorCount)
    private var host: String
    private var port: Int
}
