//
//  ChunithmNetHandler.swift
//  updater
//
//  Created by 刘易斯 on 2023/2/7.
//

import Foundation
import NIO
import NIOHTTP1

final class ChunithmNetHandler {

    
}

extension ChunithmNetHandler: ChannelOutboundHandler {
    typealias OutboundIn = HTTPClientRequestPart
    typealias OutboundOut = HTTPClientRequestPart
    
    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        guard case .head(var head) = self.unwrapOutboundIn(data) else {
            context.write(data, promise: promise)
            return
        }
        
        NSLog(head.uri)
        context.write(data, promise: promise)
    }
}


