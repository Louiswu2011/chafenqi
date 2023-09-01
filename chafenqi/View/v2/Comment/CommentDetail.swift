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
    @ObservedObject var user: CFQNUser
    
    var musicId: Int
    var musicFrom: Int
    
    var comments: Array<UserComment>
    
    @State var showingComposer = false
    // @State var replyingTo: Comment? = nil
    
    var body: some View {
        Group {
            VStack {
                if comments.isEmpty {
                    Text("暂无评论，点击加号发表评论")
                        .foregroundColor(.gray)
                } else {
                    Form {
                        ForEach(Array(comments.enumerated()), id: \.offset) { index, comment in
                            VStack(alignment: .leading) {
                                HStack {
                                    // TODO: Add Like/Dislike counter
                                    Text(comment.username)
                                        .font(.system(size: 15))
                                        .bold()
                                        .lineLimit(1)
                                    Spacer()
                                    
                                    
                                    Text("#\(comment.id)")
                                        .font(.system(size: 15))
                                        .foregroundColor(.gray)
                                    
                                    
                                    Text(comment.dateString)
                                        .font(.system(size: 15))
                                        .foregroundColor(.gray)
                                    
                                }
                                .padding(.vertical, 10)
                                
                                Text(comment.content)
                                    .multilineTextAlignment(.leading)
                                    .padding(.bottom, 10)
                            }
                            .contextMenu {
                                Button {
                                    showingComposer.toggle()
                                } label: {
                                    Image(systemName: "arrowshape.turn.up.backward")
                                    Text("回复")
                                }
                                
                                if (comment.username == user.username) {
                                    Button {
                                        Task {
                                            //                                    let result = await comment.delete()
                                            //                                    if (result) {
                                            //                                        comments.remove(at: index)
                                            //                                        // TODO: Add success toast
                                            //                                    } else {
                                            //                                        // TODO: Add fail toast
                                            //                                    }
                                        }
                                    } label: {
                                        Image(systemName: "trash")
                                        Text("删除")
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
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
                CommentComposerView(user: user, musicId: musicId, musicFrom: musicFrom, showingComposer: $showingComposer)
            }
            .navigationTitle("评论")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

