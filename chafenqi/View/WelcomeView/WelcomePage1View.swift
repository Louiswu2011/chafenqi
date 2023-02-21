//
//  WelcomePageView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/20.
//

import SwiftUI

struct WelcomePage1View: View {
    var bundleVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    var bundleBuildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
    
    var body: some View {
        VStack(alignment: .center) {
            Image("Icon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .mask {
                    RoundedRectangle(cornerRadius: 15)
                }
                .frame(width: 100)
                .padding(.top, 40)
                .padding()
            
            Text("欢迎使用查分器NEW")
                .font(.largeTitle)
                .bold()
            
            Spacer()
            
            Button {
                
            } label: {
                Text("滑动前往下一页")
                Image(systemName: "arrow.forward")
            }
            .padding()
            
            Text("\(bundleVersion) Build \(bundleBuildNumber)")
                .font(.system(size: 15))
                .foregroundColor(.gray)
        }
    }
}

struct WelcomePageView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomePage1View()
    }
}
