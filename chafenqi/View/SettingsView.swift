//
//  SettingsView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/9.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("settingsCoverSource") var coverSource = ""
    @AppStorage("userAccountId") var accountId = ""
    @AppStorage("userAccountName") var accountName = ""
    @AppStorage("userAccountType") var accountType = "QQ号"
    
    @State private var accountInfo = ""
    
    var sourceOptions = ["Github", "Gitee"]
    var accountOptions = ["QQ号", "账户名"]
    
    var body: some View {
        NavigationView {
            List {
                Section("常规") {
                    Picker("封面来源", selection: $coverSource) {
                        ForEach(sourceOptions, id: \.self) {
                            Text($0)
                        }
                    }
                    // .pickerStyle(.wheel)
                }
                Section("账户") {

                        Picker("类型", selection: $accountType) {
                            ForEach (accountOptions, id: \.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(.segmented)
                        
                        if (accountType == "QQ号") {
                            TextField("输入QQ号", text: $accountId)
                        } else {
                            TextField("输入账户名", text: $accountName)
                        }
                    
                    
                }
            }
            .navigationTitle("设置")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
