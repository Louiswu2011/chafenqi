//
//  LoginView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/3/22.
//

import SwiftUI

struct LoginView: View {
    @State var account: String = ""
    @State var password: String = ""
    
    var body: some View {
        VStack {
            Text("登录到查分器")
                .font(.title)
                .bold()
                .padding(.bottom, 20)
            VStack(spacing: 15) {
                HStack {
                    TextField("用户名", text: $account)
                        .autocorrectionDisabled(true)
                        .autocapitalization(.none)
                }
                HStack {
                    SecureField("密码", text: $password)
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 20)
            Button {
                
            } label: {
                Text("登录")
            }
        }
        .padding()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
