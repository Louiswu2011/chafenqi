//
//  chafenqiApp.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/6.
//

import SwiftUI

var credits = """
特别感谢：
@SoreHait
@Diving-Fish - 舞萌DX/中二节奏查分器
@bakapiano - 查分器更新方案
sdvx.in - 谱面预览
And You
"""

@main
struct chafenqiApp: App {
    @State var currentTab: TabIdentifier = .home
    @State var shouldRefresh = false
    
    var body: some Scene {
        WindowGroup {
            MainView(currentTab: $currentTab)
                .onOpenURL { url in
                    guard let identifier = url.tabIdentifier else { return }
                    
                    currentTab = identifier
                }
        }
    }
}

enum TabIdentifier: Hashable {
    case home, recent, list, tool
}

extension URL {
    var isDeeplink: Bool {
        return scheme == "chafenqi"
    }
    
    var tabIdentifier: TabIdentifier? {
        guard isDeeplink else { return nil }
        
        switch host {
        case "home": return .home
        case "recent": return .recent
        case "list": return .list
        case "tool": return .tool
        default: return nil
        }
    }
}
