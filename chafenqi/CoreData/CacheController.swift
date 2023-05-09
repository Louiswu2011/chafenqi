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
    
    var container = NSPersistentContainer(name: "ImageCache")
    
    init() {
        print("[CacheController] Initializing persistent stores...")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("[CacheController] Container load failed: \(error)")
            }
            print("[CacheController] Loaded store: \(storeDescription.description)")
        }
        print(container.viewContext.name ?? "no name")
    }
    
    func getCacheSize() -> String {
        var byteSize = 0
        let storeUrls = container.persistentStoreCoordinator.persistentStores.compactMap { $0.url }
        for url in storeUrls {
            do {
                let size = try Data(contentsOf: url)
                if (size.count >= 1) {
                    byteSize += size.count
                }
            } catch {
                print("[CacheController] Failed to calculate cache size: \(error.localizedDescription)")
            }
        }
        let bcf = ByteCountFormatter()
        bcf.countStyle = .file
        if (byteSize == 0) {
            return "0 KB"
        }
        return bcf.string(fromByteCount: Int64(byteSize))
    }
    
    func clearCache() {
        do {
            let deleteRequests = [NSBatchDeleteRequest(fetchRequest: CoverCache.fetchRequest()), NSBatchDeleteRequest(fetchRequest: ChartCache.fetchRequest())]
            for request in deleteRequests {
                request.resultType = .resultTypeObjectIDs
                let batchDelete = try container.viewContext.execute(request) as? NSBatchDeleteResult
                guard let deleteResult = batchDelete?.result as? [NSManagedObjectID] else { fatalError("[CacheController] Type assertion failed.") }
                let deletedObjects: [AnyHashable: Any] = [NSDeletedObjectsKey: deleteResult]
                NSManagedObjectContext.mergeChanges(fromRemoteContextSave: deletedObjects, into: [container.viewContext])
            }
        } catch {
            print("[CacheController] Failed to purge cache: \(error.localizedDescription)")
        }
    }
}
