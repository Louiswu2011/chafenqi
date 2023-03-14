//
//  CommentDetail.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/3/13.
//

import SwiftUI
import AlertToast

struct CommentDetail: View {
    @AppStorage("settingsCurrentMode") var mode = 0
    @AppStorage("didLogin") var didLogin = false
    
    @AppStorage("userAccountName") var accountName = ""
    @AppStorage("userNickname") var accountNickname = ""
    
    @ObservedObject var toastManager = AlertToastManager.shared
    
    @State var from: Int = 0
    
    @State var comments: Array<Comment> = []
    @State var showingComposer = false
    @State var replyingTo: Comment? = nil
    
    var body: some View {
        Form {
            ForEach(Array(comments.enumerated()), id: \.offset) { index, comment in
                VStack(alignment: .leading) {
                    HStack {
                        // TODO: Add Like/Dislike counter
                        Text(comment.nickname)
                            .font(.system(size: 15))
                            .bold()
                            .lineLimit(1)
                        Spacer()
                        
//                        HStack {
//                            Image(systemName: "hand.thumbsup")
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(width: 15)
//                            Text("\(comment.like)")
//                        }
//                        .onTapGesture {
//                            comments[index].addLike()
//                        }
//
//                        HStack {
//                            Image(systemName: "hand.thumbsdown")
//                                .resizable()
//                                .aspectRatio(contentMode: .fit)
//                                .frame(width: 15)
//                            Text("\(comment.dislike)")
//                        }
                        
                        Text(comment.getDateString())
                            .font(.system(size: 15))
                            .foregroundColor(.gray)

                    }
                    .padding(.vertical)
                    
                    Text(comment.message)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .padding(.bottom)
                }
                .contextMenu {
                    if (comment.sender != accountName) {
//                        Button {
//                            Task {
//                                let result = await comment.postLike()
//                                if (result) {
//                                    // TODO: Add success toast
//                                } else {
//                                    // TODO: Add fail toast
//                                }
//                            }
//                        } label: {
//                            Image(systemName: "hand.thumbsup")
//                            Text("赞")
//                        }
//
//                        Button {
//                            Task {
//                                let result = await comment.postDislike()
//                                if (result) {
//                                    // TODO: Add success toast
//                                } else {
//                                    // TODO: Add fail toast
//                                }
//                            }
//                        } label: {
//                            Image(systemName: "hand.thumbsdown")
//                            Text("踩")
//                        }
                    }
                    
                    Button {
                        replyingTo = comment
                        showingComposer.toggle()
                    } label: {
                        Image(systemName: "arrowshape.turn.up.forward")
                        Text("回复")
                    }
                    
                    if (comment.sender == accountName) {
                        Button {
                            Task {
                                let result = await comment.delete()
                                if (result) {
                                    comments.remove(at: index)
                                    // TODO: Add success toast
                                } else {
                                    // TODO: Add fail toast
                                }
                            }
                        } label: {
                            Image(systemName: "trash")
                            Text("删除")
                        }
                    }
                }
            }
            .navigationTitle("评论")
            .navigationBarTitleDisplayMode(.inline)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    replyingTo = nil
                    showingComposer.toggle()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .buttonStyle(.borderless)
        .toast(isPresenting: $toastManager.showingCommentPostSucceed, duration: 2, tapToDismiss: true) {
            AlertToast(displayMode: .alert, type: .complete(.green), title: "提交成功")
        }
        .sheet(isPresented: $showingComposer) {
            CommentComposerView(replyComment: replyingTo, showingComposer: $showingComposer)
        }
    }
}

struct CommentDetail_Previews: PreviewProvider {
    static var previews: some View {
        CommentDetail(comments: [Comment.shared, Comment.shared, Comment.shared, Comment.shared, Comment.shared])
    }
}

struct CommentComposerView: View {
    @AppStorage("settingsCurrentMode") var mode = 0
    @AppStorage("userAccountName") var accountName = ""
    @AppStorage("userNickname") var accountNickname = ""
    
    @ObservedObject var toastManager = AlertToastManager.shared
    
    @State var from: Int = 0
    @State var message = ""
    @State var replyComment: Comment? = nil
    
    @Binding var showingComposer: Bool
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                TextField("在这里输入你的评论...", text: $message)
                    .autocorrectionDisabled(true)
                    .multilineTextAlignment(.leading)
                    .autocapitalization(.none)
                Spacer()
                Text("将以\(accountNickname)的身份发布，请文明发言")
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
                                sender: accountName,
                                nickname: accountNickname,
                                mode: mode,
                                musicId: from,
                                reply: reply ?? -1
                            )
                            if (result) {
                                toastManager.showingCommentPostSucceed.toggle()
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
