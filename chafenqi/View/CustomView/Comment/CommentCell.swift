//
//  CommentCell.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/3/13.
//

import SwiftUI

struct CommentCell: View {
    @State var comment: Comment
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(comment.sender)
                    .font(.system(size: 15))
                    .bold()
                    .lineLimit(1)
                Spacer()
                Text(comment.getDateString())
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            .padding(.top)
            
            Text(comment.message)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .padding(.horizontal, 20)
                .padding(.vertical)
        }
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(.gray.opacity(0.2))
        )
        .contextMenu {
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
    }
}

struct CommentCell_Previews: PreviewProvider {
    static var previews: some View {
        CommentCell(comment: Comment.shared)
    }
}
