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
        widgetData.maimai = try encoder.encode(data.maimaiInfo)
        widgetData.chunithm = try encoder.encode(data.chunithmInfo)
        
        print("[WidgetDataController] Saved widget data of", widgetData.username!)
        try self.container.viewContext.save()
    }
    
    func fetchBy(username: String) throws -> WidgetUser? {
        let fetchRequest: NSFetchRequest<WidgetUser>
        fetchRequest = WidgetUser.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "username = %@", username)
        let objects = try self.container.viewContext.fetch(fetchRequest)
        return objects.first
    }
}
