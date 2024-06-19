//
//  AppDelegate.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/4/18.
//

import UIKit
import OneSignal
import FirebaseCore
import FirebaseCrashlytics
import FirebaseAnalytics
import FirebasePerformance

class AppDelegate: NSObject, UIApplicationDelegate {
    private let actionService = QuickActionService.shared
    
    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        if let shortcutItem = options.shortcutItem {
            actionService.action = QuickAction(item: shortcutItem)
        }
        
        let configuration = UISceneConfiguration(
            name: connectingSceneSession.configuration.name,
            sessionRole: connectingSceneSession.role
        )
        configuration.delegateClass = SceneDelegate.self
        return configuration
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Remove this method to stop OneSignal Debugging
        // OneSignal.setLogLevel(.LL_VERBOSE, visualLevel: .LL_NONE)
            
        OneSignal.initWithLaunchOptions(launchOptions)
        OneSignal.setAppId("61d8cb1c-6de2-4b50-af87-f419b2d24ece")
            
        OneSignal.promptForPushNotifications(userResponse: { accepted in
            print("User accepted notification: \(accepted)")
        })
        
        FirebaseApp.configure()
          
        // Set your customer userId
        // OneSignal.setExternalUserId("userId")
          
        return true
    }
}

class SceneDelegate: NSObject, UIWindowSceneDelegate {
    private let actionService = QuickActionService.shared
    
    func windowScene(
        _ windowScene: UIWindowScene,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        actionService.action = QuickAction(item: shortcutItem)
        completionHandler(true)
    }
}
