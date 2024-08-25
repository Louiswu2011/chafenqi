//
//  ChartImageGrabber.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/22.
//

import Foundation
import SwiftUI
import CoreData
import UIKit

class ChartImageGrabber: ObservableObject {
    func downloadChartImage(musicId: String, diffIndex: Int, context: NSManagedObjectContext) async throws -> UIImage {
        let barURL: URL?
        let bgURL: URL?
        let chartURL: URL?

        barURL = URL(string: "\(CFQServer.serverAddress)api/chunithm/preview?musicId=\(musicId)&diff=\(diffIndex)&type=bar")
        bgURL = URL(string: "\(CFQServer.serverAddress)api/chunithm/preview?musicId=\(musicId)&diff=\(diffIndex)&type=bg")
        chartURL = URL(string: "\(CFQServer.serverAddress)api/chunithm/preview?musicId=\(musicId)&diff=\(diffIndex)&type=chart")
        
        let fetchRequest = ChartCache.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "imageUrl == %@", chartURL?.absoluteString ?? "ongeki wen?")
        let matches = try? context.fetch(fetchRequest)
        if let match = matches?.first?.image {
            // print("[ChartImageGrabber] Read from cache.")
            return UIImage(data: match)!
        }
        
        do {
            async let barImage = try downloadImageFromUrl(url: barURL!, index: 0)
            async let bgImage = try downloadImageFromUrl(url: bgURL!, index: 1)
            async let chartImage = try downloadImageFromUrl(url: chartURL!, index: 2)
            
            let images = try await [barImage, bgImage, chartImage]
            
            UIGraphicsBeginImageContext(images[0].size)

            let areaSize = CGRect(x: 0, y: 0, width: images[0].size.width, height: images[0].size.height)
            images[0].draw(in: areaSize)
            images[1].draw(in: areaSize, blendMode: .normal, alpha: 1.0)
            images[2].draw(in: areaSize, blendMode: .normal, alpha: 1.0)

            let mergedImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            
            saveToCache(mergedImage, chartUrl: chartURL?.absoluteString ?? "ongeki wen?", context: context)
            
            return mergedImage
        } catch {
            throw CFQError.requestTimeoutError
        }
    }
    
    private func downloadImageFromUrl(url: URL, index: Int) async throws -> UIImage {
        let request = URLRequest(url: url)
        let (data, _) = try await URLSession.shared.data(for: request)
        
        let image = UIImage(data: data)
        if let image = image {
            return image
        } else {
            throw CFQError.BadRequestError
        }
    }
    
    private func saveToCache(_ image: UIImage, chartUrl: String, context: NSManagedObjectContext) {
        do {
            let chartCache = ChartCache(context: context)
            chartCache.image = image.pngData()!
            chartCache.imageUrl = chartUrl
            try context.save()
            print("[ChartImageGrabber] Saved \(chartUrl) to cache.")
        } catch {
            print("[ChartImageGrabber] Failed to save cache: \(error.localizedDescription)")
        }
    }
}
