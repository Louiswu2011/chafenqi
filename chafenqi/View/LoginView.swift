//
//  LoginView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/3/22.
//

import SwiftUI
import AlertToast

enum LoginState {
    case loginPending
    case registerPending
    case loginRequesting
    case registerRequesting
}

struct LoginView: View {
    @AppStorage("JWT") var jwtToken = ""
    @ObservedObject var alertToast = AlertToastModel.shared
    @ObservedObject var user: CFQNUser
    
    @State var task: Task<Void, any Error>? = nil
    
    @State private var state: LoginState = .loginPending
    @State private var defaultAnimation: Animation = .spring()
    
    @State private var loginPrompt = "登录中"
    @State private var registerPrompt = "注册中"
    
    @State var account: String = "louiswu2011"
    @State var password: String = "bed200110"
    
    var body: some View {
        VStack {
            Image("Icon")
                .resizable()
                .aspectRatio(1, contentMode: .fit)
                .frame(width: 100)
                .mask(RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(AngularGradient(gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]), center: .center), lineWidth: 3))
                .padding(.bottom)
            
            HStack {
                Spacer()
                Text(getTitleText(state: state))
                    .font(.title)
                    .bold()
                    .frame(alignment: .center)
                    .padding(.bottom, 20)
                Spacer()
            }
            
            switch (state) {
            case .loginPending, .registerPending:
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
            case .loginRequesting, .registerRequesting:
                EmptyView()
            }
            
            switch(state) {
            case .loginPending:
                Button {
                    // Login Action
                    guard (!account.isEmpty && !password.isEmpty) else {
                        alertToast.toast = AlertToast(displayMode: .hud, type: .error(.red), title: "用户名或密码不能为空")
                        alertToast.show = true
                        return
                    }
                    withAnimation(defaultAnimation) {
                        loginPrompt = "登录中"
                        state = .loginRequesting
                        self.task = Task {
                            do {
                                let token = await login(username: account, password: password)
                                if (!token.isEmpty) {
                                    // TODO: Navigate to HomeView
                                    user.jwtToken = token
                                    try await user.load(username: account, forceReload: false)
                                    print("[Login] Successfully logged in.")
                                    withAnimation(defaultAnimation) {
                                        user.didLogin = true
                                    }
                                } else {
                                    alertToast.show = true
                                    state = .loginPending
                                }
                            } catch {
                                switch error {
                                case CFQNUserError.LoadingError(cause: let cause, _):
                                    alertToast.toast = AlertToast(displayMode: .hud, type: .error(.red), title: "网络连接错误", subTitle: cause)
                                default:
                                    alertToast.toast = AlertToast(displayMode: .hud, type: .error(.red), title: "加载错误", subTitle: String(describing: error))
                                }
                                alertToast.show = true
                                state = .loginPending
                            }
                        }
                    }
                } label: {
                    Text("登录")
                        .font(.system(size: 20))
                }
                .padding(.bottom)
                Button {
                    state = .registerPending
                } label: {
                    Text("注册新账号")
                        .font(.system(size: 15))
                }
            case .registerPending:
                Button {
                    // Register Action
                    guard (!account.isEmpty && !password.isEmpty) else {
                        alertToast.toast = AlertToast(displayMode: .hud, type: .error(.red), title: "用户名或密码不能为空")
                        alertToast.show = true
                        return
                    }
                    guard checkPasswordValidity(password: password) else {
                        alertToast.toast = AlertToast(displayMode: .hud, type: .error(.red), title: "密码长度必须为8位以上", subTitle: "且包含字母和数字")
                        alertToast.show = true
                        return
                    }
                    withAnimation(defaultAnimation) {
                        registerPrompt = "注册中"
                        state = .registerRequesting
                        self.task = Task {
                            do {
                                let success = await register(username: account, password: password)
                                alertToast.show = true
                                if (success) {
                                    // Auto login
                                    state = .loginPending
                                } else {
                                    // Fallback to register state
                                    state = .registerPending
                                }
                            }
                        }
                    }
                } label: {
                    Text("注册")
                        .font(.system(size: 20))
                }
                .padding(.bottom)
                Button {
                    state = .loginPending
                } label: {
                    Text("返回")
                        .font(.system(size: 15))
                }
            case .loginRequesting, .registerRequesting:
                ProgressView()
                    .padding(.bottom)
                Button {
                    withAnimation(defaultAnimation) {
                        state = .loginPending
                        self.task?.cancel()
                    }
                } label: {
                    Text("取消")
                }
            }
            
            
        }
        .padding()
        .toast(isPresenting: $alertToast.show, duration: 1, tapToDismiss: true) {
            alertToast.toast
        }
    }
    
    func login(username: String, password: String) async -> String {
        do {
            loginPrompt = "检查用户名和密码"
            return try await CFQUserServer.auth(username: username, password: password)
        } catch let err as CFQServerError {
            alertToast.toast = err.alertToast()
            return ""
        } catch {
            alertToast.toast = AlertToast(displayMode: .alert, type: .error(.red), title: "发生未知错误")
            return ""
        }
    }
    
    func register(username: String, password: String) async -> Bool {
        do {
            registerPrompt = "检查用户名是否可用"
            do {
                try await CFQUserServer.register(username: username, password: password)
            } catch CFQServerError.UsernameOccupiedError {
                // Username not unique
                alertToast.toast = AlertToast(displayMode: .hud, type: .error(.red), title: "发生错误", subTitle: "用户名已被占用")
                return false
            }
            alertToast.toast = AlertToast(displayMode: .alert, type: .complete(.green), title: "注册成功")
            return true
        } catch let err as CFQServerError {
            alertToast.toast = err.alertToast()
            return false
        } catch {
            alertToast.toast = AlertToast(displayMode: .alert, type: .error(.red), title: "发生未知错误")
            return false
        }
    }
    
    func getTitleText(state: LoginState) -> String {
        switch(state) {
        case .loginPending:
            return "登录到查分器"
        case .registerPending:
            return "注册查分器账号"
        case .loginRequesting:
            return "登录到查分器"
        case .registerRequesting:
            return "注册查分器账号"
        }
    }
    
    func checkPasswordValidity(password: String) -> Bool {
        return password.count >= 8 && password.isAlphanumeric()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(user: CFQNUser())
    }
}

extension String {
    func isAlphanumeric() -> Bool {
        return self.rangeOfCharacter(from: CharacterSet.alphanumerics.inverted) == nil && self != ""
    }

    func isAlphanumeric(ignoreDiacritics: Bool = false) -> Bool {
        if ignoreDiacritics {
            return self.range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil && self != ""
        }
        else {
            return self.isAlphanumeric()
        }
    }

}
