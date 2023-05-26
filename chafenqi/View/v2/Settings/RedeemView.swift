//
//  RedeemView.swift
//  chafenqi
//
//  Created by xinyue on 2023/5/26.
//

import SwiftUI

let perks =
"""
通过兑换订阅服务，您可以获得以下功能：
- 出勤数据记录
- Rating历史趋势
- 详细歌曲游玩记录
- 独特的赞助者标志
"""

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
                Text(perks)
            }
        }
        
    }
}

struct RedeemView_Previews: PreviewProvider {
    static var previews: some View {
        RedeemView()
    }
}
