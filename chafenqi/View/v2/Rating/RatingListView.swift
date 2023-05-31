//
//  RatingListView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/5/9.
//

import SwiftUI

struct RatingListView: View {
    @ObservedObject var user: CFQNUser
    
    var body: some View {
        ScrollView {
            VStack {
                if (user.currentMode == 0 && user.chunithm.isNotEmpty) {
                    ChunithmRatingListView(user: user)
                } else if (user.currentMode == 1 && user.maimai.isNotEmpty) {
                    MaimaiRatingListView(user: user)
                }
            }
            .padding()
            .navigationTitle("Rating列表")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct MaimaiRatingListView: View {
    @ObservedObject var user: CFQNUser
    
    @State var pastFold = false
    @State var currentFold = false
    
    var body: some View {
        VStack {
            HStack {
                Text(verbatim: "\(user.maimai.custom.rawRating)")
                    .font(.system(size: 30))
                    .bold()
                Spacer()
                Text(verbatim: "Past \(user.maimai.custom.pastRating) / New \(user.maimai.custom.currentRating)")
            }
            .padding(.bottom)
            
            HStack {
                Text("旧曲 B35")
                    .font(.system(size: 20))
                    .bold()
                Spacer()
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        pastFold.toggle()
                    }
                } label: {
                    Text(pastFold ? "展开" : "收起")
                }
            }
            .padding(.bottom)
            
            if (!pastFold) {
                VStack(spacing: 15) {
                    ForEach(Array(user.maimai.custom.pastSlice.enumerated()), id: \.offset) { index, entry in
                        NavigationLink {
                            SongDetailView(user: user, maiSong: entry.associatedSong!)
                        } label: {
                            MaimaiRatingBannerView(user: user, index: index + 1, entry: entry)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            HStack {
                Text("新曲 B15")
                    .font(.system(size: 20))
                    .bold()
                Spacer()
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        currentFold.toggle()
                    }
                } label: {
                    Text(currentFold ? "展开" : "收起")
                }
            }
            .padding(.bottom)
            
            if (!currentFold) {
                VStack(spacing: 15) {
                    ForEach(Array(user.maimai.custom.currentSlice.enumerated()), id: \.offset) { index, entry in
                        NavigationLink {
                            SongDetailView(user: user, maiSong: entry.associatedSong!)
                        } label: {
                            MaimaiRatingBannerView(user: user, index: index + 1, entry: entry)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

struct ChunithmRatingListView: View {
    @ObservedObject var user: CFQNUser
    
    @State var bestFold = false
    @State var recentFold = false
    
    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                Text("\(user.chunithm.info.rating, specifier: "%.2f")")
                    .font(.system(size: 30))
                    .bold()
                Spacer()
                Text("Best \(user.chunithm.custom.b30, specifier: "%.2f") / Recent \(user.chunithm.custom.r10, specifier: "%.2f")")
                    .font(.system(size: 20))
            }
            .padding(.bottom)
            
            HStack {
                Text("最佳成绩 B30")
                    .font(.system(size: 20))
                    .bold()
                Spacer()
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        bestFold.toggle()
                    }
                } label: {
                    Text(bestFold ? "展开" : "收起")
                }
            }
            .padding(.bottom)
            
            if(!bestFold) {
                VStack(spacing: 15) {
                    ForEach(Array(user.chunithm.custom.b30Slice.enumerated()), id: \.offset) { index, entry in
                        NavigationLink {
                            SongDetailView(user: user, chuSong: entry.associatedBestEntry!.associatedSong!)
                        } label: {
                            ChunithmRatingBannerView(user: user, index: index + 1, entry: entry)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            HStack {
                Text("最近成绩 R10")
                    .font(.system(size: 20))
                    .bold()
                Spacer()
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        recentFold.toggle()
                    }
                } label: {
                    Text(recentFold ? "展开" : "收起")
                }
            }
            .padding(.bottom)
            
            if(!recentFold) {
                VStack(spacing: 15) {
                    ForEach(Array(user.chunithm.custom.r10Slice.enumerated()), id: \.offset) { index, entry in
                        NavigationLink {
                            SongDetailView(user: user, chuSong: entry.associatedBestEntry!.associatedSong!)
                        } label: {
                            ChunithmRatingBannerView(user: user, index: index + 1, entry: entry)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }
}

struct RatingListView_Previews: PreviewProvider {
    static var previews: some View {
        RatingListView(user: CFQNUser())
    }
}
