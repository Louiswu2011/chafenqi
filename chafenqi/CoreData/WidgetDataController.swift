//
//  WidgetDataController.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/6/30.
//

import Foundation
import CoreData

class WidgetDataController {
    static let shared = WidgetDataController()
    
    let encoder = JSONEncoder()
    
    var container = NSPersistentContainer(name: "WidgetData")
    
    init() {
        print("[WidgetDataController] Initializing persistent stores...")
        let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.nltv.chafenqi.shared")
        let storeURL = containerURL?.appendingPathComponent("WidgetData.sqlite")
        let description = NSPersistentStoreDescription(url: storeURL!)
        
        container.persistentStoreDescriptions = [description]
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("[CacheController] Container load failed: \(error)")
            }
            print("[WidgetDataController] Loaded store: \(storeDescription.description)")
        }
    }
    
    func save(data: WidgetData, context: NSManagedObjectContext) throws {
        let widgetData = WidgetUser(context: self.container.viewContext)
        widgetData.username = data.username
        widgetData.isPremium = data.isPremium
        widgetData.maimai = nil
        widgetData.chunithm = nil
        widgetData.chuRecentOne = nil
        widgetData.maiRecentOne = nil
        if let data = data.maimaiInfo {
            widgetData.maimai = try encoder.encode(data)
        }
        if let data = data.chunithmInfo {
            widgetData.chunithm = try encoder.encode(data)
        }
        if let data = data.maiRecentOne {
            widgetData.maiRecentOne = try encoder.encode(data)
        }
        if let data = data.chuRecentOne {
            widgetData.chuRecentOne = try encoder.encode(data)
        }
        widgetData.maiCover = data.maiCover
        widgetData.chuCover = data.chuCover
        
        if self.container.viewContext.hasChanges {
            print("[WidgetDataController] Saving widget data of", widgetData.username!)
            try self.container.viewContext.save()
        }
    }
}
