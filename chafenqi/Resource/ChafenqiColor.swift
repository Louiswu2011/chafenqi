//
//  ChafenqiColor.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/25.
//

import Foundation
import SwiftUI

struct ChafenqiColor {
    static let accent = Color(red: 241, green: 103, blue: 103)
    static let secondary = Color(red: 255, green: 184, blue: 76)
    static let auxilary = Color(red: 164, green: 89, blue: 209)
    static let background = Color(red: 245, green: 234, blue: 234)
}


extension Color {
    init(red: Int, green: Int, blue: Int){
        self.init(red: Double(red) / 255, green: Double(green) / 255, blue: Double(blue) / 255)
    }
}
