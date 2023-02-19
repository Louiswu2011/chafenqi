//
//  UpdaterHelpView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/19.
//

import SwiftUI

struct UpdaterHelpView: View {
    @Binding var isShowingHelp: Bool
    
    var body: some View {
        let width: CGFloat = 350
        
        VStack(alignment: .center) {
            Text("传分器帮助")
                .font(.largeTitle)
                .bold()
                .padding()
            
            HStack() {
                Image(systemName: "1.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 40)
                    .padding(.horizontal)
                
                VStack(alignment: .leading) {
                    Text("打开代理开关")
                        .font(.system(size: 20))
                        .bold()
                    Text("当显示\"已连接\"时即为连接成功")
                }
            }
            .padding()
            .frame(width: width)
            
            HStack {
                Image(systemName: "2.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 40)
                    .padding(.horizontal)
                
                VStack(alignment: .leading) {
                    Text("选择舞萌DX/中二节奏NEW分数上传")
                        .font(.system(size: 20))
                        .bold()
                    Text("分数上传链接将复制到剪贴板")
                }
            }
            .padding()
            .frame(width: width)
            
            HStack {
                Image(systemName: "3.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 40)
                    .padding(.horizontal)
                
                VStack(alignment: .leading) {
                    Text("打开微信任意聊天窗口发送并点击链接")
                        .font(.system(size: 20))
                        .bold()
                    Text("如遇微信提示是否访问，请点击继续访问")
                }
            }
            .padding()
            .frame(width: width)
            
            HStack {
                Image(systemName: "4.circle")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 40)
                    .padding(.horizontal)
                
                VStack(alignment: .leading) {
                    Text("等候分数上传")
                        .font(.system(size: 20))
                        .bold()
                    Text("目前分数上传成功后会显示乱码，后续将会调整为正常的信息")
                }
            }
            .padding()
            .frame(width: width)
            
            Text("注：打开代理期间无法访问网络属正常现象，无需等候消息发送成功即可直接点击链接。\n更新完成后请及时关闭代理，防止服务器拥堵及影响到正常网络链接。")
                .font(.system(size: 15))
                .padding()
            
            Button {
                isShowingHelp.toggle()
            } label: {
                Text("我知道了")
            }
            .buttonStyle(.borderedProminent)
            .padding()
        }
    }
}

struct UpdaterHelpView_Previews: PreviewProvider {
    static var previews: some View {
        UpdaterHelpView(isShowingHelp: .constant(true))
    }
}
