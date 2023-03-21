//
//  SponsorView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/3/20.
//

import SwiftUI

struct SponsorView: View {
    var body: some View {
        VStack {
            Form {
                Section {
                    TextInfoView(text: "SoreHait", info: "代码级指导")
                    TextInfoView(text: "bakapiano", info: "国服代理传分方案")
                    TextInfoView(text: "Diving-Fish", info: "数据支持")
                    TextInfoView(text: "sdvx.in", info: "中二侧谱面数据")
                } header: {
                    Text("技术支持")
                }
                
                Section {
                    TextInfoView(text: "0Shu", info: "App图标设计")
                } header: {
                    Text("美术支持")
                }
                
                Section {
                    Text("ruirui")
                    Text("寒蝉.")
                    Text("冰翎")
                    Text("百夜")
                    Text("陆仁贾")
                    Text("铺盖")
                    Text("dark童")
                    Text("yozaki")
                } header: {
                    Text("爱发电赞助人员")
                } footer: {
                    Text("排名不分先后，默认显示爱发电昵称")
                }
                
                
            }
        }
        .navigationTitle("鸣谢")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SponsorView_Previews: PreviewProvider {
    static var previews: some View {
        SponsorView()
    }
}
