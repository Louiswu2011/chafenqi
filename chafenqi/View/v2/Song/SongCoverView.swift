//
//  SongCoverView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/3.
//

import SwiftUI
import CoreData

struct SongCoverView: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) var context
    
    var coverURL: URL
    var size: CGFloat
    var cornerRadius: CGFloat
    var withShadow = true
    var switchShadowColor = false
    var diffColor: Color?
    
    var body: some View {
        ZStack {
            if (withShadow) {
                AsyncImage(url: coverURL, context: context, placeholder: {
                    ProgressView()
                }, image: {
                    Image(uiImage: $0)
                        .resizable()
                })
                // .scaledToFill()
                .frame(width: size, height: size)
                .cornerRadius(cornerRadius)
                .shadow(color: switchShadowColor ? (colorScheme == .dark ? Color.white.opacity(0.33) : Color.black.opacity(0.33)) : Color.black.opacity(0.33), radius: 5)
            } else {
                AsyncImage(url: coverURL, context: context, placeholder: {
                    ProgressView()
                }, image: {
                    Image(uiImage: $0)
                        .resizable()
                })
                // .scaledToFill()
                .frame(width: size, height: size)
                .cornerRadius(cornerRadius)
            }
            
            if let color = diffColor {
                VStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: size * 0.6, height: size * 0.07)
                        .foregroundColor(color)
                }
                .padding(5)
            }
        }
        .id(UUID())
    }
}
