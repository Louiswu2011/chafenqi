//
//  MultiplePicker.swift
//  chafenqi
//
//  Created by 刘易斯 on 2024/08/27.
//

import Foundation
import SwiftUI

struct MultiplePicker: View {
    var title: String
    var options: [String]
    @Binding var selections: [String]
    
    var body: some View {
        NavigationLink {
            Form {
                ForEach(Array(options.enumerated()), id: \.offset) { (index, option) in
                    MultiplePickerItem(option: option, selections: $selections)
                }
            }
        } label: {
            HStack {
                Text(title)
                Spacer()
                if selections.count == 1 {
                    Text(selections.first ?? "")
                        .foregroundColor(.gray)
                } else if selections.count > 1 {
                    Text("已选择\(selections.count)项")
                        .foregroundColor(.gray)
                }
            }
        }
    }
}
