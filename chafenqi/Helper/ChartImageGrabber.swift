//
//  ChartImageGrabber.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/22.
//

import Foundation
import UIKit

struct ChartImageGrabber {
    static func downloadChartImage(webChartId: String, diff: String) async throws -> UIImage {
        let barURL = URL(string: "https://sdvx.in/chunithm/\(diff == "ult" ? "ult" : webChartId.prefix(2))/bg/\(webChartId)bar.png")
        let bgURL = URL(string: "https://sdvx.in/chunithm/\(diff == "ult" ? "ult" : webChartId.prefix(2))/bg/\(webChartId)bg.png")
        let chartURL = URL(string: "https://sdvx.in/chunithm/\(diff == "ult" ? "ult" : webChartId.prefix(2))/obj/data\(webChartId)\(diff).png")
        
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
}
