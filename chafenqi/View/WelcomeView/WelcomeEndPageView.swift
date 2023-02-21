//
//  WelcomeEndPageView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/20.
//

import SwiftUI

struct WelcomeEndPageView: View {
    @Binding var isShowingWelcome: Bool
    
    var body: some View {
        VStack(alignment: .center) {
            Image(systemName: "checkmark")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.accentColor)
                .frame(width: 80)
                .padding(.top, 40)
                .padding()
            
            Text("你是准备就绪的")
                .font(.largeTitle)
                .bold()
                .padding()
            
            Text("可通过 “设置 - 重置教程” 来重温该教程")
            
            Spacer()
            
            Button {
                isShowingWelcome.toggle()
            } label: {
                Text("开始使用")
                    .font(.system(size: 20))
            }
            .padding()
            .buttonStyle(.borderedProminent)

        }
    }
}

struct WelcomeEndPageView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeEndPageView(isShowingWelcome: .constant(true))
    }
}
