//
//  CommentDetail.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/3/13.
//

import SwiftUI

struct CommentDetail: View {
    @AppStorage("settingsCurrentMode") var mode = 0
    @AppStorage("didLogin") var didLogin = false
    
    @AppStorage("userAccountName") var accountName = ""
    
    @State var comments: Array<Comment> = []
    
    var body: some View {
        Form {
            ForEach(comments, id: \.uid) { comment in
                VStack(alignment: .leading) {
                    HStack {
                        Text(comment.nickname)
                            .font(.system(size: 15))
                            .bold()
                            .lineLimit(1)
                        Spacer()
                        Text(comment.getDateString())
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                        
                        Menu {
                            if (comment.sender != accountName) {
                                Button {
                                    
                                } label: {
                                    Image(systemName: "hand.thumbsup")
                                    Text("赞")
                                }
                                
                                Button {
                                    
                                } label: {
                                    Image(systemName: "hand.thumbsdown")
                                    Text("踩")
                                }
                            }
                            
                            Button {
                                
                            } label: {
                                Image(systemName: "arrowshape.turn.up.forward")
                                Text("回复")
                            }
                            
                            if (comment.sender == accountName) {
                                Button {
                                    
                                } label: {
                                    Image(systemName: "trash")
                                    Text("删除")
                                }
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                        }
                    }
                    .padding(.vertical)
                    
                    Text(comment.message)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .padding(.bottom)
                }
            }
            .navigationTitle("评论")
            .navigationBarTitleDisplayMode(.inline)
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .buttonStyle(.borderless)
        
    }
}

struct CommentDetail_Previews: PreviewProvider {
    static var previews: some View {
        CommentDetail(comments: [Comment.shared])
    }
}
