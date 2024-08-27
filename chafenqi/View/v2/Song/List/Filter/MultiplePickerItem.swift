//
//  MultiplePickerItem.swift
//  chafenqi
//
//  Created by 刘易斯 on 2024/08/27.
//

import Foundation
import SwiftUI

struct MultiplePickerItem: View {
    var option: String
    @State var isSelected: Bool = false
    @Binding var selections: [String]
    
    var body: some View {
        Button {
            if selections.contains(option) {
                selections.removeAll { entry in entry == option }
                isSelected = false
            } else {
                selections.append(option)
                isSelected = true
            }
        } label: {
            HStack {
                Text(option)
                Spacer()
                if selections.contains(option) {
                    Image(systemName: "checkmark")
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onAppear {
            if selections.contains(option) {
                isSelected = true
            } else {
                isSelected = false
            }
        }
    }
}
