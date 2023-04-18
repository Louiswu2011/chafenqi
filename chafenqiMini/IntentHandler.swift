//
//  IntentHandler.swift
//  chafenqiMini
//
//  Created by 刘易斯 on 2023/4/18.
//

import Intents

class IntentHandler: INExtension, StartProxyIntentHandling, StopProxyIntentHandling, FetchFishTokenIntentHandling {
    
    func handle(intent: StartProxyIntent, completion: @escaping (StartProxyIntentResponse) -> Void) {
        NSLog("Start Proxy")
        
        let response = StartProxyIntentResponse(code: .continueInApp, userActivity: NSUserActivity(activityType: "StartProxyIntent"))
        completion(response)
    }
    
    func handle(intent: StopProxyIntent, completion: @escaping (StopProxyIntentResponse) -> Void) {
        NSLog("Stop Proxy")
        let response = StopProxyIntentResponse(code: .continueInApp, userActivity: NSUserActivity(activityType: "StopProxyIntent"))
        completion(response)
    }
    
    func handle(intent: FetchFishTokenIntent) async -> FetchFishTokenIntentResponse {
        let savedToken = UserDefaults(suiteName: "group.com.nltv.chafenqi.shared")!.string(forKey: "userToken")
        guard let token = savedToken else {
            NSLog("Failed to retreive from user defaults")
            return FetchFishTokenIntentResponse(code: .failure, userActivity: nil)
        }
        let response = FetchFishTokenIntentResponse(code: .success, userActivity: nil)
        response.token = token
        return response
    }
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        if intent is BuildProxyURLIntent {
            return BuildURLHandler()
        } else {
            return self
        }
    }
}
