//
//  CommentDetail.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/3/13.
//

import SwiftUI
import AlertToast

struct CommentDetail: View {
    @ObservedObject var toastManager = AlertToastManager.shared
    @ObservedObject var user: CFQUser
    
    @State var from: Int = 0
    
    @State var comments: Array<Comment> = []
    @State var showingComposer = false
    @State var replyingTo: Comment? = nil
    
    var body: some View {
        Group {
            Form {
                ForEach(Array(comments.enumerated()), id: \.offset) { index, comment in
                    VStack(alignment: .leading) {
                        HStack {
                            // TODO: Add Like/Dislike counter
                            let displayName = comment.nickname.isEmpty ? comment.sender : comment.nickname
                            Text(displayName)
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
                            
                            
                            Text("#\(comment.uid)")
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                            
                            
                            Text(comment.getDateString())
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                            
                        }
                        .padding(.vertical)
                        
                        HStack {
                            Text(comment.concatReply())
                                .multilineTextAlignment(.leading)
                                .lineLimit(50)
                        }
                        .padding(.bottom)
                        
                    }
                    .contextMenu {
                        if (comment.sender != user.username) {
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
                            Image(systemName: "arrowshape.turn.up.backward")
                            Text("回复")
                        }
                        
                        if (comment.sender == user.username) {
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
                CommentComposerView(user: user, comments: comments, from: from, replyComment: replyingTo, showingComposer: $showingComposer)
            }
            .navigationTitle("评论")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

