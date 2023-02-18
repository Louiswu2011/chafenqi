//
//  RecentView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/18.
//

import SwiftUI

struct RecentView: View {
    @AppStorage("didLogin") var didLogin = false
    
    @AppStorage("settingsChunithmCoverSource") var chunithmCoverSource = 0
    @AppStorage("settingsMaimaiCoverSource") var maimaiCoverSource = 0
    @AppStorage("settingsCurrentMode") var currentMode = 0
    
    @AppStorage("userAccountName") var accountName = ""
    
    @AppStorage("userChunithmRecentData") var chuRecentData = Data()
    @AppStorage("userMaimaiRecentData") var maiRecentData = Data()
    
    @State var chuRecent: Array<ChunithmRecentRecord> = []
    @State var maiRecent: Array<MaimaiRecentRecord> = []
    @State var status: LoadStatus = .loading(hint: "加载中...")
    
    var body: some View {
        VStack {
            if(didLogin) {
                if (currentMode == 0) {
                    switch status {
                    case .loading(let hint):
                        VStack {
                            ProgressView()
                                .padding()
                            Text(hint)
                        }
                    case .complete:
                        List {
                            ForEach(chuRecent, id: \.timestamp) { entry in
                                Text(entry.title)
                            }
                        }
                    default:
                        Text("?")
                    }
                }
            } else {
                Text("请先登录查分器账号！")
            }
        }
        .onAppear {
            Task {
                await getRecentData()
            }
        }
        .navigationTitle("最近记录")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    chuRecentData = Data()
                    maiRecentData = Data()
                    chuRecent = []
                    maiRecent = []
                    Task {
                        await getRecentData()
                    }
                }) {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
    }
    
    func getRecentData() async {
        status = .loading(hint: "加载中...")
        if (currentMode == 0) {
            guard chuRecentData.isEmpty else { status = .complete; return }
            do {
                chuRecentData = try await ChunithmDataGrabber.getRecentData(username: accountName)
                if (chuRecent.isEmpty) {
                    chuRecent = try JSONDecoder().decode(Array<ChunithmRecentRecord>.self, from: chuRecentData)
                }
                status = .complete
            } catch {
                
            }
        }
    }
}

struct RecentView_Previews: PreviewProvider {
    static var previews: some View {
        RecentView()
    }
}
