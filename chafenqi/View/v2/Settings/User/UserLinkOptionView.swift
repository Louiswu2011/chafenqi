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
    @State private var isUploading = false
    @State private var bind: String = ""
    @State private var currentQQ = ""
    
    var body: some View {
        Form {
            Section {
                HStack {
                    Text("当前QQ号")
                    Spacer()
                    if isLoading {
//                        Text("加载中...")
//                            .foregroundColor(.gray)
                        ProgressView()
                    } else if currentQQ.isEmpty {
                        Text("暂未绑定")
                            .foregroundColor(.gray)
                    } else {
                        Text(currentQQ)
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
                    if isUploading {
                        ProgressView()
                    } else {
                        Text("绑定QQ号")
                    }
                }
                .disabled(isUploading)
            } footer: {
                Text("""
绑定QQ号即视为同意查分器NEW共享您的以下信息:
- 中二节奏 B30/R10数据
- 中二节奏 单曲成绩数据
- 舞萌DX B50数据
- 舞萌DX 单曲成绩数据
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
            currentQQ = await CFQUserServer.fetchUserOption(authToken: user.jwtToken, param: "bindQQ")
            isLoading = false
        }
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
        isUploading = true
        Task {
            do {
                if try await CFQUserServer.uploadUserOption(authToken: user.jwtToken, param: "bindQQ", value: bind) {
                    alertToast.toast = AlertToast(displayMode: .hud, type: .complete(.green), title: "数据上传成功")
                    loadOptions()
                    bind = ""
                } else {
                    alertToast.toast = AlertToast(displayMode: .hud, type: .error(.red), title: "数据上传失败")
                }
            } catch {
                alertToast.toast = AlertToast(displayMode: .hud, type: .error(.red), title: "数据上传失败")
            }
            isUploading = false
        }
    }
}

struct UserLinkOptionView_Previews: PreviewProvider {
    static var previews: some View {
        UserLinkOptionView(user: CFQNUser())
    }
}
