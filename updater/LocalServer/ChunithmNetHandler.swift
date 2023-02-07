//
//  ChunithmNetHandler.swift
//  updater
//
//  Created by 刘易斯 on 2023/2/7.
//

import Foundation
import NIO
import NIOHTTP1

final class ChunithmNetHandler: ChannelInboundHandler {
    typealias InboundIn = HTTPServerRequestPart
    typealias OutboundOut = HTTPServerResponsePart
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        print(context.remoteAddress ?? "")
        
        let part = self.unwrapInboundIn(data)
        
        
    }
}
