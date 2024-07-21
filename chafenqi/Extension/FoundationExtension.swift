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
