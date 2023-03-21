//
//  RecentView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/18.
//

import SwiftUI

struct RecentView: View {
    @ObservedObject var user: CFQUser
    
    var body: some View {
        VStack {
            if(user.didLogin) {
                if (user.currentMode == 0) {
                    if (user.chunithm!.recent.isEmpty || user.chunithm!.custom.recentSong.isEmpty) {
                        VStack{
                            Text("暂无最近记录")
                                .padding()
                            Text("可通过传分器上传")
                        }
                    } else {
                        Form {
                            Section {
                                ForEach(user.chunithm!.recent.indices) { index in
                                    NavigationLink {
                                        RecentDetailView(user: user, chuSong: user.chunithm!.custom.recentSong[index], chuRecord: user.chunithm!.recent[index], mode: 0)
                                    } label: {
                                        RecentBasicView(user: user, chunithmSong: user.chunithm!.custom.recentSong[index], chunithmRecord: user.chunithm!.recent[index], mode: 0)
                                    }
                                }
                            }
                        }
                    }
                } else {
                    if (user.maimai!.recent.isEmpty || user.chunithm!.custom.recentSong.isEmpty) {
                        VStack{
                            Text("暂无最近记录")
                                .padding()
                            Text("可通过传分器上传")
                        }
                    } else {
                        Form {
                            Section {
                                ForEach(user.maimai!.recent.indices) { index in
                                    NavigationLink {
                                        RecentDetailView(user: user, maiSong: user.maimai!.custom.recentSong[index], maiRecord: user.maimai!.recent[index], mode: 1)
                                    } label: {
                                        RecentBasicView(user: user, maimaiSong: user.maimai!.custom.recentSong[index], maimaiRecord: user.maimai!.recent[index], mode: 1)
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                Text("请先登录查分器账号！")
            }
        }
        .navigationTitle("最近动态")
        .navigationBarTitleDisplayMode(.inline)
    }
}

