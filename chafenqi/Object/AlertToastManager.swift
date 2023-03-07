//
//  AlertToastManager.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/13.
//

import Foundation

final class AlertToastManager: ObservableObject {
    @Published var showingUpdaterPasted = false
    @Published var showingTutorialReseted = false
    @Published var showingRecordDeleted = false
    
    static let shared = AlertToastManager()
}
