//
//  HomeRating.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/5/9.
//

import SwiftUI

struct HomeRating: View {
    @ObservedObject var user: CFQNUser
    
    var body: some View {
        HStack {
            Text("Rating分析")
                .font(.system(size: 20))
                .bold()
            Spacer()
            
            NavigationLink {
                RatingListView(user: user)
            } label: {
                Text("显示全部")
                    .font(.system(size: 18))
            }
        }
        .padding()
    }
}

struct HomeRating_Previews: PreviewProvider {
    static var previews: some View {
        HomeRating(user: CFQNUser())
    }
}
