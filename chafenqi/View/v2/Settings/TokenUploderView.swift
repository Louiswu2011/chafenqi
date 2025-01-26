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
    @State var testing = false
    
    @State var username: String = ""
    @State var password: String = ""
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("当前状态")
                    Spacer()
                    Text(user.remoteOptions.fishToken.isEmpty ? "未绑定" : "已绑定")
                        .foregroundColor(.gray)
                }
            }
            
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
                        let emptyToast = AlertToast(displayMode: .hud, type: .error(.red), title: "用户名或密码不能为空")
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
                .disabled(fetching)
                
                Button {
                    testing = true
                    Task {
                        let result = await user.testFishToken()
                        if result {
                            alertToast.toast = AlertToast(displayMode: .hud, type: .complete(.green), title: "Token有效")
                        } else {
                            alertToast.toast = AlertToast(displayMode: .hud, type: .error(.red), title: "Token已失效", subTitle: "请重新获取水鱼Token")
                        }
                        testing = false
                    }
                } label: {
                    HStack {
                        Text("验证Token")
                        Spacer()
                        if testing {
                            ProgressView()
                        }
                    }
                }
                .disabled(user.remoteOptions.fishToken.isEmpty || testing)
            } footer: {
                Text("""
                查分器NEW不会存储您的用户名和密码，仅保留Token作上传用。
                
                “上传到水鱼网”功能需要使用您的水鱼网登陆Token。
                如遇无法上传的情况，请重新获取Token并避免在水鱼网页端登录导致Token失效。
                """)
            }
        }
        .navigationTitle("更新水鱼Token")
        .navigationBarTitleDisplayMode(.inline)
        .toast(isPresenting: $alertToast.show, duration: 1, tapToDismiss: true) {
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
            request.setValue("\(bodyData.count)", forHTTPHeaderField: "Content-Length")
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
            
            user.remoteOptions.fishToken = token
            if !(try await CFQUserServer.uploadUserOption(authToken: user.jwtToken, param: "fish_token", value: token)) {
                alertToast.toast = AlertToast(displayMode: .hud, type: .error(.red), title: "上传失败", subTitle: "请联系开发者")
            }
            
            presentationMode.wrappedValue.dismiss()
        } catch CFQServerError.CredentialsMismatchError {
            let mismatchToast = AlertToast(displayMode: .hud, type: .error(.red), title: "用户名或密码错误")
            alertToast.toast = mismatchToast
        } catch {
            let unknownToast = AlertToast(displayMode: .hud, type: .error(.red), title: "未知错误", subTitle: error.localizedDescription)
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
