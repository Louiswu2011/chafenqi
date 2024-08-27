//
//  FoundationExtension.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/9/13.
//

import Foundation
import SwiftUI

extension String {
    var displayRate: String {
        return self.replacingOccurrences(of: "p", with: "+").uppercased()
    }
}

extension Array where Element: Equatable {
    var unique: [Element] {
        var uniqueValues: [Element] = []
        forEach { item in
            guard !uniqueValues.contains(item) else { return }
            uniqueValues.append(item)
        }
        return uniqueValues
    }
}

extension Array where Element == Double {
    func getOrNull(_ index: Int, defaultValue: Double = 0.0) -> Double {
        if index >= self.count || index < 0 {
            return defaultValue
        } else {
            return self[index]
        }
    }
}
