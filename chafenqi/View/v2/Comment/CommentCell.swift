//
//  CommentCell.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/3/13.
//

import SwiftUI

struct CommentCell: View {
    @State var comment: UserComment
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(comment.username)
                    .font(.system(size: 15))
                    .bold()
                    .lineLimit(1)
                Spacer()
                Text(comment.dateString)
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            .padding(.top)
            
            Text(comment.content)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .padding(.horizontal, 20)
                .padding(.vertical)
        }
        
    }
}

struct CommentCell_Previews: PreviewProvider {
    static var previews: some View {
        CommentCell(comment: UserComment.shared)
    }
}
