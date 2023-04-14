//
//  CustomAlert.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/4/14.
//

import Foundation
import SwiftUI

struct CustomAlert: View {
    @Environment(\.presentationMode) var presentation
    let message: String
    let titlesAndActions: [(title: String, action: (() -> Void)?)] // = [.default(Text("OK"))]
    
    var body: some View {
        VStack {
            Text(message)
            Divider().padding([.leading, .trailing], 40)
            HStack {
                ForEach(titlesAndActions.indices, id: \.self) { i in
                    Button(self.titlesAndActions[i].title) {
                        (self.titlesAndActions[i].action ?? {})()
                        self.presentation.wrappedValue.dismiss()
                    }
                    .padding()
                }
            }
        }
    }
}
