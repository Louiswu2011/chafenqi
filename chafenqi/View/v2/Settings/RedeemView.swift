//
//  RedeemView.swift
//  chafenqi
//
//  Created by xinyue on 2023/5/26.
//

import SwiftUI

struct RedeemView: View {
    @State var code = ""
    
    var body: some View {
        Form {
            Section {
                TextField("输入兑换码", text: $code)
                    .autocapitalization(.none)
                
            }
            Section {
                Button {
                    
                } label: {
                    Text("兑换...")
                }
            } footer: {
                Text(
                """
                通过兑换订阅服务，您可以解锁以下功能：
                """)
            }
        }
        
    }
}

struct RedeemView_Previews: PreviewProvider {
    static var previews: some View {
        RedeemView()
    }
}
