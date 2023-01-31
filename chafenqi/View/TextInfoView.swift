//
//  TextInfoView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/31.
//

import SwiftUI

struct TextInfoView: View {
    @State var text: String
    @State var info: String
    
    var body: some View {
        HStack {
            Text(text)
            Spacer()
            Text(info)
                .foregroundColor(Color.gray)
                .lineLimit(1)
        }
    }
}

