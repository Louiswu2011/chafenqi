//
//  ImageLoader.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/24.
//

import Combine
import UIKit
import SwiftUI
import CoreData

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    
    private var viewContext: NSManagedObjectContext
    
    private(set) var isLoading = false
    
    private let url: URL
    private var cancellable: AnyCancellable?
    
    private static let imageProcessingQueue = DispatchQueue(label: "image-processing")
    
    init(url: URL, cache: ImageCache? = nil, context: NSManagedObjectContext) {
        self.url = url
        self.viewContext = context
    }
    
    deinit {
        cancel()
    }
    
    func load() {
        guard !isLoading else { return }

        let fetchRequest = CoverCache.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "imageUrl == %@", url.absoluteString)
        let matches = try? viewContext.fetch(fetchRequest)
        if let match = matches?.first?.image {
            let img = UIImage(data: match)
            self.image = img
            isLoading = false
            // print("[ImageLoader] Read from cache.")
            return
        }
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .handleEvents(receiveSubscription: { [weak self] _ in self?.onStart() },
                          receiveOutput: { [weak self] in self?.saveToCache($0) },
                          receiveCompletion: { [weak self] _ in self?.onFinish() },
                          receiveCancel: { [weak self] in self?.onFinish() })
            .subscribe(on: Self.imageProcessingQueue)
            .receive(on: DispatchQueue.main)
            .sink {
                [weak self] in self?.image = $0
            }
    }
    
    func cancel() {
        cancellable?.cancel()
    }
    
    private func onStart() {
        isLoading = true
    }
    
    private func onFinish() {
        isLoading = false
    }
    
    private func saveToCache(_ image: UIImage?) {
        if let image = image {
            let pngData = image.pngData()!
            let cacheItem = CoverCache(context: viewContext)
            cacheItem.imageUrl = self.url.absoluteString
            cacheItem.image = pngData
            do {
                try viewContext.save()
                print("[ImageLoader] Saved \(self.url.absoluteString) to cache.")
            } catch {
                print("[ImageLoader] Failed to save cache: \(error.localizedDescription)")
            }
        }
    }
}
