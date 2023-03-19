//
//  RatingDetailView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/3/19.
//

import SwiftUI

struct RatingDetailView: View {
    @ObservedObject var user: CFQUser
    
    var body: some View {
        ScrollView {
            if (user.currentMode == 0) {
                RatingDetailChunithmView(chunithm: user.chunithm!)
            } else {
                RatingDetailMaimaiView(maimai: user.maimai!)
            }
        }
        .onAppear {
            // Debug only
            // user.currentMode = 0
        }
        .padding()
        .navigationTitle("Rating详情")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct RatingDetailMaimaiView: View {
    @State var maimai: CFQUser.Maimai
    
    var body: some View {
        VStack {
            HStack {
                Text(verbatim: "\(maimai.custom.rawRating)")
                    .font(.system(size: 30))
                    .bold()
                Spacer()
                Text(verbatim: "Past \(maimai.custom.pastRating) / New \(maimai.custom.currentRating)")
            }
            
            Divider()
            
            HStack {
                Text("旧曲 B25")
                    .font(.system(size: 20))
                    .bold()
                Spacer()
            }
            
            HStack {
                Text("新曲 B15")
                    .font(.system(size: 20))
                    .bold()
                Spacer()
            }
        }
    }
}

struct RatingDetailChunithmView: View {
    @State var chunithm: CFQUser.Chunithm
    
    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                Text("\(chunithm.profile.getRating(), specifier: "%.2f")")
                    .font(.system(size: 30))
                    .bold()
                Spacer()
                Text("Best \(chunithm.profile.getAvgB30(), specifier: "%.2f") / Recent \(chunithm.profile.getAvgR10(), specifier: "%.2f")")
                    .font(.system(size: 20))
            }
            
            Divider()
            
            HStack {
                Text("最佳成绩 B30")
                    .font(.system(size: 20))
                    .bold()
                Spacer()
            }
            
            HStack {
                Text("最近成绩 R10")
                    .font(.system(size: 20))
                    .bold()
                Spacer()
            }
        }
    }
}

struct RatingDetailView_Previews: PreviewProvider {
    static var previews: some View {
        RatingDetailView(user: CFQUser())
    }
}
