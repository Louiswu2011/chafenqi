//
//  SongCoverView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/3.
//

import SwiftUI
import CachedAsyncImage

struct SongCoverView: View {
    @Environment(\.colorScheme) var colorScheme
    
    var coverURL: URL
    var size: CGFloat
    var cornerRadius: CGFloat
    var withShadow = true
    var switchShadowColor = false
    
    var body: some View {
        if #available(iOS 15.0, *) {
            CachedAsyncImage(url: coverURL){ phase in
                if let image = phase.image {
                    if (withShadow) {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: size, height: size)
                            .cornerRadius(cornerRadius)
                            .shadow(color: switchShadowColor ? (colorScheme == .dark ? Color.white.opacity(0.33) : Color.black.opacity(0.33)) : Color.black.opacity(0.33), radius: 5)
                    } else {
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: size, height: size)
                            .cornerRadius(cornerRadius)
                    }
                    
                } else if phase.error != nil {
                    ProgressView()
                        .frame(width: size, height: size)
                } else {
                    ProgressView()
                        .frame(width: size, height: size)
                }
            }
        } else {
            if (withShadow) {
                AsyncImage(url: coverURL, placeholder: {
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
                AsyncImage(url: coverURL, placeholder: {
                    ProgressView()
                }, image: {
                    Image(uiImage: $0)
                        .resizable()
                })
                // .scaledToFill()
                .frame(width: size, height: size)
                .cornerRadius(cornerRadius)
            }
        }
    }
}
