//
//  CommentComposer.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/3/17.
//

import SwiftUI

struct CommentComposerView: View {
    @ObservedObject var toastManager = AlertToastManager.shared
    @ObservedObject var user: CFQUser
    
    @State var comments = []
    @State var from: Int
    @State var message = ""
    @State var replyComment: Comment? = nil
    
    @Binding var showingComposer: Bool
    
    var body: some View {
        let displayName = user.nickname.isEmpty ? user.username : user.nickname
        
        NavigationView {
            VStack(alignment: .leading) {
                TextField("在这里输入你的评论...", text: $message)
                    .autocorrectionDisabled(true)
                    .multilineTextAlignment(.leading)
                    .autocapitalization(.none)
                Spacer()
                Text("将以\(displayName)的身份发布，请文明发言")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
            }
            .padding()
            .navigationBarTitle("发表评论")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        let reply = replyComment?.uid
                        Task {
                            let result = await CommentHelper.postComment(
                                message: message,
                                sender: user.username,
                                nickname: user.nickname,
                                mode: user.currentMode,
                                musicId: from,
                                reply: reply ?? -1
                            )
                            if (result) {
                                // toastManager.showingCommentPostSucceed.toggle()
                                
                                showingComposer.toggle()
                            }
                        }
                    } label: {
                        Text("提交")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingComposer.toggle()
                    } label: {
                        Text("取消")
                    }
                }
            }
        }
    }
}
