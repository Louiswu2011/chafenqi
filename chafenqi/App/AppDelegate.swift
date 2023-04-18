//
//  AppDelegate.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/4/18.
//

import UIKit

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
