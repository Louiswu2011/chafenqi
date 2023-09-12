//
//  ViewExtension.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/9/13.
//

import Foundation
import SwiftUI

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    @ViewBuilder func iff<Content:View>(_ condition: Bool, trueTransform: (Self) -> Content, falseTransform: (Self) -> Content) -> some View {
        if condition {
            trueTransform(self)
        } else {
            falseTransform(self)
        }
    }
    
    @ViewBuilder func iOS15if<Content: View>(_ trueTransform: (Self) -> Content, _ falseTransform: (Self) -> Content) -> some View {
        if Bool.iOS15 {
            trueTransform(self)
        } else {
            falseTransform(self)
        }
    }
}
