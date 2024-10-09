//
//  RatingShareView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2024/09/30.
//

import SwiftUI

struct RatingShareView: View {
    var type: String
    
    @ObservedObject var user: CFQNUser
    @State private var doneLoading = false
    @State private var image: UIImage? = nil
    
    var body: some View {
        VStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .cornerRadius(10.0)
                Spacer()
                HStack {
                    Button {
                        shareImage(image: image)
                    } label: {
                        Label("分享", systemImage: "square.and.arrow.up")
                    }
                }
            } else {
                ProgressView(label: {
                    Text("生成图片中...")
                })
            }
        }
        .navigationTitle(type == "b30" ? "B30分表" : "B50分表")
        .navigationBarTitleDisplayMode(.inline)
        .padding()
        .onAppear {
            image = nil
            if user.currentMode == 0 {
                fetchB30Image()
            } else {
                fetchB50Image()
            }
        }
    }
    
    func fetchB30Image() {
        Task {
            image = await CFQImageServer.getChunithmB30Image(authToken: user.jwtToken)
            if let b30Image = image {
                image = b30Image
            }
        }
    }
    
    func fetchB50Image() {
        Task {
            let b50Data = user.makeB50()
            image = await CFQImageServer.getMaimaiB50Image(data: b50Data)
            if let b50Image = image {
                image = b50Image
            }
        }
    }
    
    func shareImage(image: UIImage) {
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        UIApplication.shared.currentUIWindow()?.rootViewController?.present(activityViewController, animated: true)
    }
}

