//
//  WelcomePage2View.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/20.
//

import SwiftUI

struct WelcomePage2View: View {
    var body: some View {
        VStack {
            Image(systemName: "gear")
                .resizable()
                .foregroundColor(.accentColor)
                .aspectRatio(contentMode: .fit)
                .frame(width: 100)
                .padding()
            
            Text("首次使用设置")
                .font(.largeTitle)
                .bold()
            
            HStack {
                Image("settings_prompt")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .shadow(radius: 2)
                    .frame(width: 220)
                    .padding(.trailing)
                
                Text("点击齿轮进入设置")
                    .lineLimit(2)
                    .font(.system(size: 20))
            }
            .padding()
            
            HStack {
                Text("填入查分器账号")
                    .lineLimit(2)
                    .font(.system(size: 20))
                    .padding(.trailing)
                
                Image("login_prompt")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .shadow(radius: 2)
                    .frame(width: 220)
            }
            .padding()
            
            HStack {
                Image("switch_mode_prompt")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .shadow(radius: 2)
                    .frame(width: 220)
                    .padding(.trailing)
                
                Text("更改数据来源")
                    .lineLimit(2)
                    .font(.system(size: 20))
            }
            .padding()
        }
    }
}

struct WelcomePage2View_Previews: PreviewProvider {
    static var previews: some View {
        WelcomePage2View()
    }
}
