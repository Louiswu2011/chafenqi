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
    4: Color(red: 129, green: 133, blue: 137),
    5: Color.white
]

let chunithmRankColor = [
    0: Color(hex: 0xffffa800),
    1: Color(hex: 0xffca8402),
    2: Color(hex: 0xff78ce95),
    3: Color(hex: 0xff369656),
    4: Color(hex: 0xfffe2f20),
    5: Color(hex: 0xff8e0a01),
    6: Color(hex: 0xff444444)
]

let nameplateDefaultChuniColorTop = Color(red: 254, green: 241, blue: 65)
let nameplateDefaultChuniColorBottom = Color(red: 243, green: 200, blue: 48)

let nameplateThemedChuniColors = [
    Color(red: 192, green: 230, blue: 249),
    Color(red: 219, green: 226, blue: 250),
    Color(red: 240, green: 223, blue: 246),
    Color(red: 248, green: 211, blue: 238),
    Color(red: 245, green: 178, blue: 225)
]
let nameplateThemedMaiColors = [
    Color(red: 235, green: 182, blue: 85),
    Color(red: 235, green: 187, blue: 87),
    Color(red: 236, green: 196, blue: 90),
    Color(red: 235, green: 200, blue: 89),
    Color(red: 242, green: 225, blue: 68)
]

let nameplateDefaultMaiColorTop = Color(red: 167, green: 243, blue: 254)
let nameplateDefaultMaiColorBottom = Color(red: 93, green: 166, blue: 247)

let nameplateDefaultChuniGradientStyle = LinearGradient(colors: [nameplateDefaultChuniColorTop, nameplateDefaultChuniColorBottom], startPoint: .top, endPoint: .bottom)
let nameplateDefaultMaiGradientStyle = LinearGradient(colors: [nameplateDefaultMaiColorTop, nameplateDefaultMaiColorBottom], startPoint: .top, endPoint: .bottom)

let nameplateThemedChuniGradientStyle = LinearGradient(colors: nameplateThemedChuniColors, startPoint: .topLeading, endPoint: .bottomTrailing)
let nameplateThemedMaiGradientStyle = LinearGradient(colors: nameplateThemedMaiColors, startPoint: .topLeading, endPoint: .bottomTrailing)

let leaderboardGoldColor = Color(hex: 0xaf9500)
let leaderboardSilverColor = Color(hex: 0xb4b4b4)
let leaderboardBronzeColor = Color(hex: 0x6a3805)
