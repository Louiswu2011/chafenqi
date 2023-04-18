//
//  QuickActionService.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/4/18.
//

import Foundation
import UIKit

enum QuickActionType: String {
    case oneClickUpload = "OneClickUpload"
}

enum QuickAction: Equatable {
    case oneClickUpload
    
    init?(item: UIApplicationShortcutItem) {
        guard let type = QuickActionType(rawValue: item.type) else {
            return nil
        }
        
        switch type {
        case .oneClickUpload:
            self = .oneClickUpload
        }
    }
}

class QuickActionService: ObservableObject {
    static let shared = QuickActionService()
    
    @Published var action: QuickAction?
}
