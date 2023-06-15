//
//  RatingAnaysisView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/3/22.
//

import SwiftUI

struct RatingAnalysisView: View {
    @ObservedObject var user: CFQUser
    
    @State private var nameplateChuniColorTop = Color(red: 254, green: 241, blue: 65)
    @State private var nameplateChuniColorBottom = Color(red: 243, green: 200, blue: 48)
    
    @State private var nameplateMaiColorTop = Color(red: 167, green: 243, blue: 254)
    @State private var nameplateMaiColorBottom = Color(red: 93, green: 166, blue: 247)
    
    var body: some View {
        if (user.didLogin && user.maimai != nil) {
            VStack(alignment: .leading) {
                Text("旧曲R25")
                    .bold()
                    .padding(.bottom)
                
                VStack {
                    let slice = user.maimai!.custom.pastSlice
                    let first = slice.first!
                    let last = slice.last!
                    HStack {
                        SongCoverView(coverURL: MaimaiDataGrabber.getSongCoverUrl(source: 0, coverId: getCoverNumber(id: String(first.musicId))), size: 50, cornerRadius: 5, withShadow: false)
                        VStack(alignment: .leading) {
                            Text(first.title)
                                .font(.system(size: 15))
                            Spacer()
                            Text("\(first.achievements, specifier: "%.4f")%")
                                .bold()
                        }
                        Spacer()
                        VStack {
                            Text("最高")
                            Text("\(first.rating)")
                                .bold()
                        }
                    }
                    
                    HStack {
                        SongCoverView(coverURL: MaimaiDataGrabber.getSongCoverUrl(source: 0, coverId: getCoverNumber(id: String(last.musicId))), size: 50, cornerRadius: 5, withShadow: false)
                        VStack(alignment: .leading) {
                            Text(last.title)
                                .font(.system(size: 15))
                            Spacer()
                            Text("\(last.achievements, specifier: "%.4f")%")
                                .bold()
                        }
                        Spacer()
                        VStack {
                            Text("最低")
                            Text("\(last.rating)")
                                .bold()
                        }
                    }
                }
                .frame(height: 110)
                
                
                Text("推荐歌曲")
                    .bold()
                    .padding(.vertical)
                
            }
        }
    }
}

struct RatingAnalysisView_Previews: PreviewProvider {
    
    static var previews: some View {
        VStack(alignment: .leading) {
            Text("旧曲R25")
                .bold()
                .padding(.bottom)

            VStack {
                HStack {
                    SongCoverView(coverURL: MaimaiDataGrabber.getSongCoverUrl(source: 0, coverId: "1000"), size: 50, cornerRadius: 5)
                    VStack(alignment: .leading) {
                        Text("song.title")
                            .font(.system(size: 15))
                        Spacer()
                        Text("song.achievements")
                            .bold()
                    }
                    Spacer()
                    VStack {
                        Text("最高")
                        Text("206")
                            .bold()
                    }
                }
                
                HStack {
                    SongCoverView(coverURL: MaimaiDataGrabber.getSongCoverUrl(source: 0, coverId: "1000"), size: 50, cornerRadius: 5)
                    VStack(alignment: .leading) {
                        Text("song.title")
                            .font(.system(size: 15))
                        Spacer()
                        Text("song.achievements")
                            .bold()
                    }
                    Spacer()
                    VStack {
                        Text("最低")
                        Text("206")
                            .bold()
                    }
                }
            }
            .frame(height: 110)

            
            Text("推荐歌曲")
                .bold()
                .padding(.vertical)
            
        }
    }
}
