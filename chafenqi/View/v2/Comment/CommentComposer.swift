//
//  CommentComposer.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/3/17.
//

import SwiftUI

struct CommentComposerView: View {
    @ObservedObject var toastManager = AlertToastManager.shared
    @ObservedObject var user: CFQNUser
    
    var musicId = 0
    var musicFrom = 0
    @State var message = ""
    // @State var replyComment: Comment? = nil
    
    @Binding var showingComposer: Bool
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                TextField("在这里输入你的评论...", text: $message)
                    .autocorrectionDisabled(true)
                    .multilineTextAlignment(.leading)
                    .autocapitalization(.none)
                Spacer()
                Text("将以\(user.username)的身份发布，请文明发言")
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
            }
            .padding()
            .navigationBarTitle("发表评论")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            do {
                                let result = try await CFQCommentServer.postComment(authToken: user.jwtToken, content: message, mode: musicFrom, musicId: musicId)
                                if (result) {
                                    showingComposer.toggle()
                                } else {
                                    print("[CommentComposer] Failed to post comment.")
                                }
                            } catch {
                                // TODO: Error handling
                                print(error)
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
