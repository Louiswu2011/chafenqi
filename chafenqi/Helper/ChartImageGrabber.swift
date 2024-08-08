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

struct ChartImageGrabber {
    static func downloadChartImage(identifier: String, diff: String, mode: Int, context: NSManagedObjectContext) async throws -> UIImage {
        let barURL: URL?
        let bgURL: URL?
        let chartURL: URL?

        if (mode == 0) {
            barURL = URL(string: "https://sdvx.in/chunithm/\(diff == "ult" ? "ult" : identifier.prefix(2))/bg/\(identifier)bar.png")
            bgURL = URL(string: "https://sdvx.in/chunithm/\(diff == "ult" ? "ult" : identifier.prefix(2))/bg/\(identifier)bg.png")
            chartURL = URL(string: "https://sdvx.in/chunithm/\(diff == "ult" ? "ult" : identifier.prefix(2))/obj/data\(identifier)\(diff).png")
        } else {
            let title = identifier.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            barURL = URL(string: "https://chafenqi.nltv.top/api/chunithm/chart?title=\(title)&type=bar")
            bgURL = URL(string: "https://chafenqi.nltv.top/api/chunithm/chart?title=\(title)&type=bg")
            chartURL = URL(string: "https://chafenqi.nltv.top/api/chunithm/chart?title=\(title)&type=\(diff)")
        }
        
        let fetchRequest = ChartCache.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "imageUrl == %@", chartURL?.absoluteString ?? "ongeki wen?")
        let matches = try? context.fetch(fetchRequest)
        if let match = matches?.first?.image {
            // print("[ChartImageGrabber] Read from cache.")
            return UIImage(data: match)!
        }
        
        do {
            async let barImage = try downloadImageFromUrl(url: barURL!)
            async let bgImage = try downloadImageFromUrl(url: bgURL!)
            async let chartImage = try downloadImageFromUrl(url: chartURL!)
            
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
    
    private static func downloadImageFromUrl(url: URL) async throws -> UIImage {
        let request = URLRequest(url: url)
        let (data, _) = try await URLSession.shared.data(for: request)
        
        return UIImage(data: data) ?? UIImage()
    }
    
    private static func saveToCache(_ image: UIImage, chartUrl: String, context: NSManagedObjectContext) {
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
