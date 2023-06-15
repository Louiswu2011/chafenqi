//
//  WelcomePage3View.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/20.
//

import SwiftUI

struct WelcomePage3View: View {
    var body: some View {
        VStack {
            VStack {
                Image(systemName: "paperplane.fill")
                    .resizable()
                    .foregroundColor(.accentColor)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100)
                    .padding()
                
                Text("传分器使用方法")
                    .font(.largeTitle)
                    .bold()
                
                HStack {
                    Image("first_prompt")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .shadow(radius: 2)
                        .frame(width: 220)
                        .padding(.trailing)
                    
                    Text("根据提示安装描述文件")
                        .lineLimit(3)
                        .font(.system(size: 18))
                }
                .padding()
                
                HStack {
                    Text("点击开关开启代理")
                        .lineLimit(2)
                        .font(.system(size: 20))
                        .padding(.trailing)
                    
                    Image("switch_prompt")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .shadow(radius: 2)
                        .frame(width: 220)
                }
                .padding()
                
                HStack {
                    Image("select_mode_prompt")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .shadow(radius: 2)
                        .frame(width: 220)
                        .padding(.trailing)
                    
                    Text("根据需要选择上传项目")
                        .lineLimit(2)
                        .font(.system(size: 18))
                }
                .padding()
                
                HStack {
                    Text("在任意聊天窗口发送并访问")
                        .lineLimit(2)
                        .font(.system(size: 16))
                        .padding(.trailing)
                    
                    Image("send_prompt")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .shadow(radius: 2)
                        .frame(width: 220)
                }
                .padding()
            }
        }
    }
}

struct WelcomePage3View_Previews: PreviewProvider {
    static var previews: some View {
        WelcomePage3View()
    }
}
