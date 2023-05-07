//
//  CacheController.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/5/8.
//

import Foundation
import CoreData

class CacheController: ObservableObject {
    static let shared = CacheController()
    
    let container = NSPersistentContainer(name: "ImageCache")
    
    init() {
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("[CacheController] Container load failed: \(error)")
            }
        }
    }
}
