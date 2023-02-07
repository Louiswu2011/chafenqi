//
//  main.swift
//  updater
//
//  Created by 刘易斯 on 2023/2/7.
//

import Dispatch
import NIOPosix


class ProxyServer {
    func start() {
        let group = MultiThreadedEventLoopGroup(numberOfThreads: 1)
        
        let bootstrap = ServerBootstrap(group: group)
        
    }
}
