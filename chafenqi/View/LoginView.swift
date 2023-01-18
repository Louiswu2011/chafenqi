//
//  LoginView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/6.
//

import SwiftUI

struct LoginView: View {
    
    @State private var username = ""
    @State private var password = ""
    
    @State private var isSecured: Bool = true
    
    var body: some View {
        VStack {
            Text("用查分器账号登录")
                .font(.title)
                .padding()
            
            TextField("用户名", text: $username)
                .padding(.leading)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
                .cornerRadius(20.0)
                
            
            SecureField("密码", text: $password)
                .cornerRadius(20.0)
                .padding()
            
            Button ("登录") {
                
            }
            
        }.padding()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
