//
//  ProxyServer.swift
//  updater
//
//  Created by 刘易斯 on 2023/2/7.
//

import Foundation
import NIO
import NIOTransportServices
import NIOHTTP1

class ProxyServer {
    let group = MultiThreadedEventLoopGroup(numberOfThreads: System.coreCount)
    
    init(host: String, port: Int) {
        self.host = host
        self.port = port
    }
    
    func start(_ completion: @escaping (Result<Void, Error>) -> Void) {
        
        let bootstrap = ServerBootstrap(group: group)
            .serverChannelOption(ChannelOptions.socket(SOL_SOCKET, SO_REUSEADDR), value: 1)
            .childChannelOption(ChannelOptions.socket(SOL_SOCKET, SO_REUSEADDR), value: 1)
            .childChannelInitializer { channel in
                channel.pipeline.addHandler(ByteToMessageHandler(HTTPRequestDecoder(leftOverBytesStrategy: .forwardBytes)))
                    .flatMap { channel.pipeline.addHandler(HTTPResponseEncoder()) }
                    .flatMap { channel.pipeline.addHandler(ConnectHandler()) }
            }
        
        bootstrap.bind(to: try! SocketAddress(ipAddress: host, port: port)).whenComplete { result in
            // Need to create this here for thread-safety purposes
            switch result {
            case .success(let channel):
                NSLog("Listening on \(String(describing: channel.localAddress))")
                completion(.success(()))
            case .failure(let error):
                NSLog("Failed to bind 127.0.0.1:8080, \(error)")
                completion(.failure(error))
            }
        }
    }
    
    func stop() {
        do {
            try group.syncShutdownGracefully()
            NSLog("Local server shutdown.")
        } catch {
            
        }
        
    }
    
    private var host: String
    private var port: Int
}
