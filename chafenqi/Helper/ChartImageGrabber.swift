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
    static func downloadChartImage(identifier: String, diff: String, mode: Int) async throws -> UIImage {
        @Environment(\.managedObjectContext) var context
        
        let barURL: URL?
        let bgURL: URL?
        let chartURL: URL?

        if (mode == 0) {
            barURL = URL(string: "https://sdvx.in/chunithm/\(diff == "ult" ? "ult" : identifier.prefix(2))/bg/\(identifier)bar.png")
            bgURL = URL(string: "https://sdvx.in/chunithm/\(diff == "ult" ? "ult" : identifier.prefix(2))/bg/\(identifier)bg.png")
            chartURL = URL(string: "https://sdvx.in/chunithm/\(diff == "ult" ? "ult" : identifier.prefix(2))/obj/data\(identifier)\(diff).png")
        } else {
            let title = identifier.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            barURL = URL(string: "http://43.139.107.206:8083/api/chunithm/chart?title=\(title)&type=bar")
            bgURL = URL(string: "http://43.139.107.206:8083/api/chunithm/chart?title=\(title)&type=bg")
            chartURL = URL(string: "http://43.139.107.206:8083/api/chunithm/chart?title=\(title)&type=\(diff)")
        }
        
        let fetchRequest = ChartCache.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "imageUrl == %@", chartURL?.absoluteString ?? "ongeki wen?")
        let matches = try? context.fetch(fetchRequest)
        if let match = matches?.first?.image {
            // print("[ChartImageGrabber] Read from cache.")
            return UIImage(data: match)!
        }
        
        do {
            let barImage = try await downloadImageFromUrl(url: barURL!)
            let bgImage = try await downloadImageFromUrl(url: bgURL!)
            let chartImage = try await downloadImageFromUrl(url: chartURL!)
            
            UIGraphicsBeginImageContext(barImage.size)

            let areaSize = CGRect(x: 0, y: 0, width: barImage.size.width, height: barImage.size.height)
            barImage.draw(in: areaSize)
            bgImage.draw(in: areaSize, blendMode: .normal, alpha: 1.0)
            chartImage.draw(in: areaSize, blendMode: .normal, alpha: 1.0)

            let mergedImage = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            
            saveToCache(mergedImage, chartUrl: chartURL?.absoluteString ?? "ongeki wen?")
            
            return mergedImage
        } catch {
            throw CFQError.requestTimeoutError
        }
    }
    
    private static func downloadImageFromUrl(url: URL) async throws -> UIImage {
        let request = URLRequest(url: url)
        let (data, _) = try await URLSession.shared.data(for: request)
        
        return UIImage(data: data)!
    }
    
    private static func saveToCache(_ image: UIImage, chartUrl: String) {
        @Environment(\.managedObjectContext) var context
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
