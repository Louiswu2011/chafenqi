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

let maimaiLevelColor = [
    0: Color(red: 128, green: 216, blue: 98),
    1: Color(red: 242, green: 218, blue: 71),
    2: Color(red: 237, green: 127, blue: 132),
    3: Color(red: 176, green: 122, blue: 238),
    4: Color(red: 206, green: 164, blue: 251)
]

let chunithmLevelColor = [
    0: Color(red: 73, green: 166, blue: 137),
    1: Color(red: 237, green: 123, blue: 33),
    2: Color(red: 205, green: 85, blue: 77),
    3: Color(red: 171, green: 104, blue: 249),
    4: Color(red: 32, green: 32, blue: 32),
    5: Color.white
]
