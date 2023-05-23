//
//  TokenUploderView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/5/9.
//

import SwiftUI
import AlertToast

struct TokenUploderView: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var user: CFQNUser
    @ObservedObject var alertToast = AlertToastModel.shared
    
    @State var fetching = false
    
    @State var username: String = ""
    @State var password: String = ""
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("用户名")
                    Spacer()
                    TextField("", text: $username)
                        .autocorrectionDisabled(true)
                        .autocapitalization(.none)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Text("密码")
                    Spacer()
                    SecureField("", text: $password)
                        .multilineTextAlignment(.trailing)
                }
            }
            
            Section {
                Button {
                    guard !username.isEmpty && !password.isEmpty else {
                        let emptyToast = AlertToast(displayMode: .alert, type: .error(.red), title: "用户名或密码不能为空")
                        alertToast.toast = emptyToast
                        return
                    }
                    Task {
                        await fetchToken()
                    }
                } label: {
                    HStack {
                        Text("获取Token")
                        Spacer()
                        if (fetching) {
                            ProgressView()
                        }
                    }
                }
            } footer: {
                Text("""
                查分器NEW不会存储您的用户名和密码，仅保留Token作上传用。
                
                初次使用请登录水鱼服务器以启用“上传到水鱼网”功能。
                如遇无法上传的情况，请再次登录并避免在水鱼网页端登录导致Token失效。
                """)
            }
        }
        .navigationTitle("登录到水鱼网")
        .navigationBarTitleDisplayMode(.inline)
        .toast(isPresenting: $alertToast.show, duration: 0.5, tapToDismiss: true) {
            alertToast.toast
        }
    }
    
    func fetchToken() async {
        fetching = true
        do {
            let body = ["username": username, "password": password]
            let bodyData = try! JSONSerialization.data(withJSONObject: body)
            
            let url = URL(string: "https://www.diving-fish.com/api/maimaidxprober/login")!
            var request = URLRequest(url: url)
            
            request.httpMethod = "POST"
            request.httpBody = bodyData
            request.setValue("\(data!.count)", forHTTPHeaderField: "Content-Length")
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            let (_, response) = try await URLSession.shared.data(for: request)
            
            let httpResponse = response as! HTTPURLResponse
            let rawCookie = httpResponse.value(forHTTPHeaderField: "Set-Cookie")
            
            if (httpResponse.statusCode == 401) {
                throw CFQServerError.CredentialsMismatchError
            }
            
            let tokenComponent = rawCookie!.components(separatedBy: ";")[0]
            let token = String(tokenComponent[tokenComponent.index(after: tokenComponent.firstIndex(of: "=")!)...])
            
            user.fishToken = token
            try await CFQFishServer.uploadToken(authToken: user.jwtToken, fishToken: token)
            
            presentationMode.wrappedValue.dismiss()
        } catch CFQServerError.CredentialsMismatchError {
            let mismatchToast = AlertToast(displayMode: .alert, type: .error(.red), title: "用户名或密码错误")
            alertToast.toast = mismatchToast
        } catch {
            let unknownToast = AlertToast(displayMode: .alert, type: .error(.red), title: "未知错误", subTitle: error.localizedDescription)
            alertToast.toast = unknownToast
        }
        fetching = false
    }
}

struct TokenUploderView_Previews: PreviewProvider {
    static var previews: some View {
        TokenUploderView(user: CFQNUser())
    }
}
