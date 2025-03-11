//
//  ErrorLogger.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/9/4.
//

import Foundation

class Logger {
    enum LogLevel: String, Codable {
        case debug = "DEBUG"
        case info = "INFO"
        case warning = "WARNING"
        case error = "ERROR"
        case critical = "CRITICAL"
    }
    
    struct Log: Codable {
        var timestamp: TimeInterval
        var level: LogLevel
        var message: String
        
        var formattedDate: String {
            let date = Date(timeIntervalSince1970: timestamp)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            return formatter.string(from: date)
        }
    }
    
    static let shared = Logger()
    
    private var logs: Array<Log> = []
    private let queue = DispatchQueue(label: "com.chafenqi.logger", attributes: .concurrent)
    private let maxLogCount = 50
    private let logFileURL: URL
    
    private init() {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        logFileURL = documentsDirectory.appendingPathComponent("chafenqi_logs.json")
        loadLogsFromDisk()
    }
    
    func debug(_ message: String) {
        append(message, level: .debug)
    }
    
    func info(_ message: String) {
        append(message, level: .info)
    }
    
    func warning(_ message: String) {
        append(message, level: .warning)
    }
    
    func error(_ message: String) {
        append(message, level: .error)
    }
    
    func critical(_ message: String) {
        append(message, level: .critical)
    }
    
    private func append(_ message: String, level: LogLevel) {
        guard !message.isEmpty else { return }
        
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            do {
                let item = Log(timestamp: Date().timeIntervalSince1970, level: level, message: message)
                
                if self.logs.count >= self.maxLogCount {
                    self.logs.removeFirst()
                }
                self.logs.append(item)
                
                // Save to disk periodically
                if self.logs.count % 10 == 0 {
                    try self.saveLogsToDisk()
                }
            } catch {
                print("Error appending to log: \(error.localizedDescription)")
            }
        }
    }
    
    func getAllLogs() -> [Log] {
        var result: [Log] = []
        queue.sync {
            result = self.logs
        }
        return result
    }
    
    func getLogs(withLevel level: LogLevel) -> [Log] {
        var result: [Log] = []
        queue.sync {
            result = self.logs.filter { $0.level == level }
        }
        return result
    }
    
    func clearLogs() {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            self.logs.removeAll()
            try? self.saveLogsToDisk()
        }
    }
    
    private func saveLogsToDisk() throws {
        let data = try JSONEncoder().encode(logs)
        try data.write(to: logFileURL)
    }
    
    private func loadLogsFromDisk() {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            
            do {
                if FileManager.default.fileExists(atPath: self.logFileURL.path) {
                    let data = try Data(contentsOf: self.logFileURL)
                    let loadedLogs = try JSONDecoder().decode([Log].self, from: data)
                    
                    // Ensure we don't exceed the maximum log count
                    if loadedLogs.count > self.maxLogCount {
                        self.logs = Array(loadedLogs.suffix(self.maxLogCount))
                    } else {
                        self.logs = loadedLogs
                    }
                }
            } catch {
                print("Error loading logs from disk: \(error.localizedDescription)")
                self.logs = []
            }
        }
    }
    
    // Add this method to maintain backward compatibility
    func append(_ log: String) {
        info(log)
    }
}
