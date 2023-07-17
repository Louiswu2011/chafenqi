//
//  UserLinkOptionView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/7/16.
//

import SwiftUI
import AlertToast

struct UserLinkOptionView: View {
    @ObservedObject var user: CFQNUser
    @ObservedObject var alertToast = AlertToastModel.shared
    
    @State private var isLoading = true
    @State private var options = CFQUserOptions()
    @State private var bind: String = ""
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("当前QQ号")
                    Spacer()
                    if isLoading {
                        Text("加载中...")
                            .foregroundColor(.gray)
                    } else if options.bindQQ == 0 {
                        Text("暂未绑定")
                            .foregroundColor(.gray)
                    } else {
                        Text(verbatim: "\(options.bindQQ)")
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Section {
                TextField("QQ号", text: $bind)
                    .keyboardType(.numberPad)
                    .autocorrectionDisabled(true)
                    .autocapitalization(.none)
                Button {
                    uploadOptions()
                } label: {
                    Text("绑定QQ号")
                }
            } footer: {
                Text("""
绑定QQ号即视为同意Chieri Bot查询您的以下信息:
- 中二节奏B30/R10数据
""")
            }
        }
        .navigationTitle("帐号关联")
        .navigationBarTitleDisplayMode(.inline)
        .toast(isPresenting: $alertToast.show) {
            alertToast.toast
        }
        .onAppear {
            isLoading = true
            loadOptions()
        }
    }
    
    func loadOptions() {
        Task {
            do {
                options = try await CFQUserServer.fetchUserOptions(authToken: user.jwtToken)
            } catch {
                alertToast.toast = AlertToast(displayMode: .hud, type: .error(.red), title: "数据加载失败")
            }
        }
        isLoading = false
    }
    
    func uploadOptions() {
        guard !bind.isEmpty else {
            alertToast.toast = AlertToast(displayMode: .hud, type: .error(.red), title: "QQ号不能为空")
            return
        }
        guard bind.isNumber else {
            alertToast.toast = AlertToast(displayMode: .hud, type: .error(.red), title: "QQ号格式错误")
            return
        }
        Task {
            do {
                let payload = CFQUserOptions(
                    bindQQ: Int(bind) ?? 0
                )
                if try await CFQUserServer.uploadUserOptions(options: payload, authToken: user.jwtToken) {
                    alertToast.toast = AlertToast(displayMode: .hud, type: .complete(.green), title: "数据上传成功")
                    loadOptions()
                    bind = ""
                } else {
                    alertToast.toast = AlertToast(displayMode: .hud, type: .error(.red), title: "数据上传失败")
                }
            } catch {
                alertToast.toast = AlertToast(displayMode: .hud, type: .error(.red), title: "数据上传失败")
            }
        }
    }
}

struct CFQUserOptions: Codable {
    var bindQQ: Int
    
    init() {
        self.bindQQ = 0
    }
    
    init(bindQQ: Int) {
        self.bindQQ = bindQQ
    }
}

struct UserLinkOptionView_Previews: PreviewProvider {
    static var previews: some View {
        UserLinkOptionView(user: CFQNUser())
    }
}
