//
//  RatingListView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/5/9.
//

import SwiftUI

struct RatingListView: View {
    @Environment(\.managedObjectContext) var context
    @ObservedObject var user: CFQNUser
    
    @State private var image: UIImage? = nil
    @State private var doneLoading: Bool = false
    
    var body: some View {
        ScrollView {
            if (user.currentMode == 0 && user.chunithm.isNotEmpty) {
                ChunithmRatingListView(user: user)
                    .padding()
            } else if (user.currentMode == 1 && user.maimai.isNotEmpty) {
                MaimaiRatingListView(user: user)
                    .padding()
            }
        }
        .navigationTitle("Rating列表")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    RatingShareView(type: user.currentMode == 0 ? "b30" : "b50", user: user)
                } label: {
                    // Image(systemName: "square.and.arrow.up")
                    Text("生成分表")
                }
            }
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
                LazyVStack(spacing: 15) {
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
                LazyVStack(spacing: 15) {
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
    @State var newFold = false
    
    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                Text("\(user.chunithm.info.last?.rating ?? 0, specifier: "%.2f")")
                    .font(.system(size: 30))
                    .bold()
                Spacer()
                Text("Best \(user.chunithm.custom.b30, specifier: "%.2f") / New \(user.chunithm.custom.n20, specifier: "%.2f")")
                    .font(.system(size: 20))
            }
            .padding(.bottom)
            
            HStack {
                Text("旧曲成绩 B30")
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
                LazyVStack(spacing: 15) {
                    ForEach(Array(user.chunithm.rating.best.enumerated()), id: \.offset) { index, entry in
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
                Text("新曲成绩 N20")
                    .font(.system(size: 20))
                    .bold()
                Spacer()
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        newFold.toggle()
                    }
                } label: {
                    Text(newFold ? "展开" : "收起")
                }
            }
            .padding(.bottom)
            
            if(!newFold) {
                LazyVStack(spacing: 15) {
                    ForEach(Array(user.chunithm.rating.new.enumerated()), id: \.offset) { index, entry in
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
