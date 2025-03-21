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

extension Double {
    func cut(remainingDigits: Int) -> Double {
        return floor(self * pow(10, Double(remainingDigits))) / pow(10, Double(remainingDigits))
    }
}

extension Date {
    var startOfMonth: Date {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month], from: self)
        return  calendar.date(from: components)!
    }
    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar(identifier: .gregorian).date(byAdding: components, to: startOfMonth)!
    }

}

extension Collection {
    // Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript(orNil index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
