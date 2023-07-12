//
//  RedeemView.swift
//  chafenqi
//
//  Created by xinyue on 2023/5/26.
//

import SwiftUI
import AlertToast

let perks =
"""
注意：以下功能仍在开发中，开发动态请关注群聊

通过兑换订阅服务，您可以获得以下功能：
- 详细的用户数据面板
- 出勤数据记录
- Rating历史趋势
- 详细歌曲游玩记录
- 独特的赞助者标志

请点击上方按钮查看示意图及了解详情。
您可以通过在爱发电赞助指定方案以获得订阅服务兑换码，原爱发电赞助者已自动获得3个月订阅服务。
"""

struct RedeemView: View {
    @ObservedObject var user: CFQNUser
    
    @State var toastModel = AlertToastModel.shared
    @State var code = ""
    @State var isVerifying = false
    @State var isShowingPreview = false
    
    let successToast = AlertToast(displayMode: .hud, type: .complete(.green), title: "兑换成功", subTitle: "刷新即可生效")
    let failureToast = AlertToast(displayMode: .hud, type: .error(.red), title: "兑换码无效", subTitle: "请检查是否输入错误")
    
    var body: some View {
        Form {
            Section {
                TextField("输入兑换码", text: $code)
                    .autocapitalization(.none)
                Button {
                    toastModel.show = false
                    isVerifying.toggle()
                    Task {
                        await verify()
                    }
                } label: {
                    HStack {
                        Text("兑换")
                        if isVerifying {
                            Spacer()
                            ProgressView()
                        }
                    }
                }
                .disabled(isVerifying)
            }
            
            Section {
                Link("获取兑换码...", destination: URL(string: "https://afdian.net/a/chafenqi")!)
                NavigationLink {
                    NotPremiumView()
                } label: {
                    Text("了解详细功能")
                }
            } footer: {
                Text(perks)
            }
        }
        .navigationTitle(user.isPremium ? "续费会员" : "加入会员")
        .navigationBarTitleDisplayMode(.inline)
        .toast(isPresenting: $toastModel.show, duration: 1, tapToDismiss: true) {
            toastModel.toast
        }
        .sheet(isPresented: $isShowingPreview) {
            PerkSheetView()
        }
    }
    
    // MARK: Verify Code
    func verify() async {
        do {
            let result = try await CFQUserServer.redeem(username: user.username, code: code)
            if result {
                toastModel.toast = successToast
            } else {
                toastModel.toast = failureToast
            }
        } catch {
            toastModel.toast = failureToast
        }
        isVerifying = false
    }
}

