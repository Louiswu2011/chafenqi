//
//  BuildURLHandler.swift
//  chafenqiMini
//
//  Created by 刘易斯 on 2023/4/18.
//

import Intents

class BuildURLHandler: NSObject, BuildProxyURLIntentHandling {
    func resolveForward(for intent: BuildProxyURLIntent, with completion: @escaping (INBooleanResolutionResult) -> Void) {
        guard let forward = intent.forward else {
            completion(INBooleanResolutionResult.needsValue())
            return
        }
        completion(INBooleanResolutionResult.success(with: forward as! Bool))
    }
    
    func handle(intent: BuildProxyURLIntent, completion: @escaping (BuildProxyURLIntentResponse) -> Void) {
        if let token = intent.token {
            var uploadQuery = ""
            let destination = intent.destination
            switch destination {
            case .unknown:
                fatalError("Cannot select unknown")
            case .chunithm:
                uploadQuery = "upload_chunithm"
            case .maimai:
                uploadQuery = "upload_maimai"
            }
            let forward = intent.forward
            let response = BuildProxyURLIntentResponse(code: .success, userActivity: nil)
            let url = "http://43.139.107.206/\(uploadQuery)?jwt=\(token)&forwading=\(forward?.intValue ?? 1)"
            response.url = url
            completion(response)
        }
    }
    
    func resolveToken(for intent: BuildProxyURLIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        guard let token = intent.token else {
            completion(INStringResolutionResult.needsValue())
            return
        }
        completion(INStringResolutionResult.success(with: token))
    }
    
    func resolveDestination(for intent: BuildProxyURLIntent, with completion: @escaping (DestinationsResolutionResult) -> Void) {
        switch intent.destination {
        case .maimai, .chunithm:
            completion(DestinationsResolutionResult.success(with: intent.destination))
        case .unknown:
            completion(DestinationsResolutionResult.needsValue())
            return
        }
    }
}
