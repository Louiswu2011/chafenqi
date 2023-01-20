//
//  ChartImageGrabber.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/19.
//

import Foundation

struct ChartIdConverter {
    private var map: Dictionary<String, String>
    
    init() throws {
        let path = Bundle.main.url(forResource: "IdMap", withExtension: "json")
        let content: Data
        do {
            content = try Data(contentsOf: path!)
            map = try JSONDecoder().decode(Dictionary<String, String>.self, from: content)
            print("Successfully loaded ID map file.")
        } catch {
            throw CFQError.IOError(file: path!.absoluteString)
        }
        
    }
    
    func getWebChartId(musicId: Int) throws -> String {
        let id = map["\(musicId)"]
        if (id == "Unknown") { throw CFQError.unsupportedError(reason: "World's End charts are not supported right now.") }
        return id!
    }
    
    func getAvailableDiffs(musicId: Int) async throws -> [String] {
        let diffs = ["exp", "mst", "ult"]
        var availableDiffs: [String] = []
        let id = map["\(musicId)"]!
        if (id == "Unknown") { throw CFQError.unsupportedError(reason: "World's End charts are not supported right now.") }
        
        for diff in diffs {
            let chartURL = URL(string: "https://sdvx.in/chunithm/\(id.prefix(2))/obj/data\(id)\(diff).png")
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
