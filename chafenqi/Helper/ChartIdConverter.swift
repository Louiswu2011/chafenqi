//
//  ChartImageGrabber.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/19.
//

import Foundation

struct ChartIdConverter {
    private var map: Dictionary<String, String>
    
    static func getWebChartId(musicId: Int, map: [String: String]) throws -> String {
        let id = map["\(musicId)"]
        if (id == "Unknown") { throw CFQError.unsupportedError(reason: "World's End charts are not supported right now.") }
        return id!
    }
    
    static func getAvailableDiffs(musicId: Int, map: [String: String]) async throws -> [String] {
        let diffs = ["exp", "mst", "ult"]
        var availableDiffs: [String] = []
        let id = map["\(musicId)"]!
        if (id == "Unknown") { throw CFQError.unsupportedError(reason: "暂不支持WE谱面预览") }
        
        for diff in diffs {
            let chartURL = URL(string: "https://sdvx.in/chunithm/\(diff == "ult" ? "ult" : id.prefix(2))/obj/data\(id)\(diff).png")
            let request = URLRequest(url: chartURL!)
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                availableDiffs.append({
                    switch(diff) {
                    case "exp":
                        return "Expert"
                    case "mst":
                        return "Master"
                    case "ult":
                        return "Ultima"
                    default:
                        return "Master"
                    }
                }())
            }
        }
        
        return availableDiffs
    }
}

extension String {
    func toDiffIndex() -> Int {
        switch self {
        case "Basic": return 0
        case "Advanced": return 1
        case "Expert": return 2
        case "Master": return 3
        case "Ultima": return 4
        case "World's End": return 5
        default: return -1
        }
    }
}
