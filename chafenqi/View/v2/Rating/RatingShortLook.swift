//
//  RatingShortLook.swift
//  chafenqi
//
//  Created by xinyue on 2023/6/6.
//

import SwiftUI

struct RatingShortLook: View {
    let screen = CGSize(width: UIScreen.main.bounds.size.width - 30, height: 1000)
    
    @ObservedObject var user = CFQNUser()
    
    @State var length = 35
    
    @State var list = [RatingPreviewBar]()
    @State var heights = [CGFloat]()
    
    @State var selectedIndex = -1
    
    @State var chuEntry: CFQChunithm.BestScoreEntry?
    @State var maiEntry: CFQMaimai.BestScoreEntry?
    
    @State var coverUrl: URL
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(selectedIndex)")
            HStack(spacing: screen.width / CGFloat(length * 2)) {
                ForEach(list, id: \.self) { view in
                    view
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { value in
                        let unit = screen.width / CGFloat(length * 2)
                        let touchIndex = Int((value.location.x / unit).rounded(.down))
                        if !touchIndex.isMultiple(of: 2) {
                            selectedIndex = ((touchIndex + 1) / 2) - 1
                            grow(id: selectedIndex)
                            
                        }
                    }
                    
                    .onEnded { value in
                        shrink()
                    }
            )
            .frame(height: 90)
            
            SongCoverView(coverURL: coverUrl, size: 30, cornerRadius: 5)
            
        }
        .onAppear {
            for j in 0...length - 1 {
                heights.append(CGFloat(50))
                list.append(RatingPreviewBar(id: j, screen: screen, color: .init(red: .random(in: 0...255), green: .random(in: 0...255), blue: .random(in: 0...255)), height: $heights[j], length: length))
            }
        }
        .onChange(of: selectedIndex) { value in
            updateSong(id: value)
        }
        
    }
    
    func grow(id: Int) {
        if (0...(length - 1)).contains(id) {
            for i in heights.indices {
                if i == id {
                    withAnimation(.easeOut(duration: 0.1)) {
                        heights[i] = 90
                    }
                } else if i == id - 1 || i == id + 1 {
                    withAnimation(.easeOut(duration: 0.1)) {
                        heights[i] = 70
                    }
                } else if i == id - 2 || i == id + 2 {
                    withAnimation(.easeOut(duration: 0.1)) {
                        heights[i] = 55
                    }
                } else if i == id - 2 || i == id + 2 {
                    withAnimation(.easeOut(duration: 0.1)) {
                        heights[i] = 52
                    }
                } else {
                    withAnimation(.easeOut(duration: 0.1)) {
                        heights[i] = 50
                    }
                }
            }
        }
        
    }
    
    func shrink() {
        for i in heights.indices {
            withAnimation(.easeOut(duration: 0.1)) {
                heights[i] = 50
            }
        }
    }
    
    func updateSong(id: Int) {
        if (0...length - 1).contains(id) {
            if user.currentMode == 0 {
                chuEntry = user.chunithm.custom.b30Slice[id].associatedBestEntry
                if let entry = chuEntry {
                    coverUrl = ChunithmDataGrabber.getSongCoverUrl(source: 0, musicId: entry.idx)
                }
            } else if user.currentMode == 1 {
                maiEntry = user.maimai.custom.pastSlice[id]
                if let entry = maiEntry {
                    coverUrl = MaimaiDataGrabber.getSongCoverUrl(source: 0, coverId: getCoverNumber(id: entry.associatedSong!.musicId))
                }
            }
        }
    }
}

struct RatingPreviewBar: View, Hashable, Equatable {
    var id: Int
    
    static func == (lhs: RatingPreviewBar, rhs: RatingPreviewBar) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    var screen = UIScreen.main.bounds.size
    @State var color: Color
    @Binding var height: CGFloat
    @State var scaled = false
    
    var length: Int
    
    var body: some View {
        Rectangle()
            .foregroundColor(color)
            .frame(width: screen.width / CGFloat(length * 2), height: height)
    }
}
