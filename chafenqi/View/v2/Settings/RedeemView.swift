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

您可以通过在爱发电进行赞助获得指定期限的订阅服务兑换码。
原爱发电赞助者均可获得3个月订阅服务（无金额限制），请在爱发电私信作者获取。
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
                    Text("兑换")
                }
                Link("获取兑换码...", destination: URL(string: "https://afdian.net/a/chafenqi")!)
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
