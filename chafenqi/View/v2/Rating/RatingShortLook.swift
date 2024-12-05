//
//  RatingShortLook.swift
//  chafenqi
//
//  Created by xinyue on 2023/6/6.
//

import SwiftUI

struct RatingShortLook: View {
    @Environment(\.managedObjectContext) var context
    let screen = CGSize(width: UIScreen.main.bounds.size.width - 30, height: 1000)
    
    @ObservedObject var user = CFQNUser()
    
    @State var length = 35
    
    @State var list = [RatingPreviewBar]()
    @State var heights = [CGFloat]()
    
    @State var selectedIndex = 0
    
    @State var chuEntry: CFQChunithm.RatingEntry?
    @State var maiEntry: UserMaimaiBestScoreEntry?
    
    @State var indexText = ""
    @State var constant = ""
    @State var title = ""
    @State var grade = ""
    @State var score = ""
    @State var rating = ""
    
    @State var coverUrl: URL
    @State var id: Int = 0

    let chuniGradient = [Color(red: 254, green: 241, blue: 65), Color(red: 243, green: 200, blue: 48)]
    let maiGradient = [Color(red: 167, green: 243, blue: 254), Color(red: 93, green: 166, blue: 247)]
    
    var body: some View {
        VStack(alignment: .leading) {
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
                            grow()
                        }
                    }
                    
                    .onEnded { value in
                        shrink()
                    }
            )
            .frame(height: 55)
            
            withAnimation {
                getImage()
            }
            
        }
        .onAppear {
            if list.isEmpty && heights.isEmpty {
                for j in 0...length - 1 {
                    heights.append(CGFloat(1))
                    list.append(RatingPreviewBar(id: j, screen: screen, color: user.currentMode == 0 ? getColor(from: chuniGradient[1], to: chuniGradient[0], ratio: Double(j + 1) / Double(length)) : getColor(from: maiGradient[1], to: maiGradient[0], ratio: Double(j + 1) / Double(length)), height: $heights[j], length: length))
                }
            }
            selectedIndex = 0
            updateSong()
        }
        .onChange(of: selectedIndex) { value in
            updateSong()
        }
        
    }
    
    func grow() {
        if (0...(length - 1)).contains(selectedIndex) {
            for i in heights.indices {
                if i == selectedIndex {
                    withAnimation(.easeOut(duration: 0.1)) {
                        heights[i] = 2.2
                    }
                } else if i == selectedIndex - 1 || i == selectedIndex + 1 {
                    withAnimation(.easeOut(duration: 0.1)) {
                        heights[i] = 1.3
                    }
                } else if i == selectedIndex - 2 || i == selectedIndex + 2 {
                    withAnimation(.easeOut(duration: 0.1)) {
                        heights[i] = 1.1
                    }
                } else if i == selectedIndex - 2 || i == selectedIndex + 2 {
                    withAnimation(.easeOut(duration: 0.1)) {
                        heights[i] = 1.05
                    }
                } else {
                    withAnimation(.easeOut(duration: 0.1)) {
                        heights[i] = 1
                    }
                }
            }
        }
        
    }
    
    func shrink() {
        for i in heights.indices {
            withAnimation(.easeOut(duration: 0.1)) {
                heights[i] = 1
            }
        }
    }
    
    func updateSong() {
        if (0...length - 1).contains(selectedIndex) {
            if user.currentMode == 0 {
                chuEntry = user.chunithm.rating[selectedIndex]
                if let entry = chuEntry {
                    indexText = "#\(selectedIndex + 1)"
                    coverUrl = ChunithmDataGrabber.getSongCoverUrl(source: 1, musicId: entry.idx)
                    constant = String(format: "%.1f", entry.associatedBestEntry!.associatedSong!.charts.constants[entry.levelIndex])
                    rating = String(format: "%.2f", entry.rating)
                    grade = entry.grade
                    score = String(entry.score)
                    title = entry.title
                }
            } else if user.currentMode == 1 {
                let pastCount = user.maimai.custom.pastSlice.count
                
                guard pastCount >= 1 else { return }
                let currentCount = user.maimai.custom.currentSlice.count
                if (0...pastCount - 1).contains(selectedIndex) {
                    // Past
                    maiEntry = user.maimai.custom.pastSlice[selectedIndex]
                    if let entry = maiEntry {
                        indexText = "旧曲 #\(selectedIndex + 1)"
                        coverUrl = MaimaiDataGrabber.getSongCoverUrl(source: 0, coverId: entry.associatedSong?.coverId ?? 0)
                        constant = String(format: "%.1f", entry.associatedSong!.constants[entry.levelIndex])
                        rating = String(entry.rating)
                        grade = entry.rateString
                        score = String(format: "%.4f", entry.achievements) + "%"
                        title = entry.associatedSong?.title ?? ""
                    }
                } else if (pastCount...pastCount + currentCount - 1).contains(selectedIndex) {
                    // Current
                    maiEntry = user.maimai.custom.currentSlice[selectedIndex - user.maimai.custom.pastSlice.count]
                    if let entry = maiEntry {
                        indexText = "新曲 #\(selectedIndex - pastCount + 1)"
                        coverUrl = MaimaiDataGrabber.getSongCoverUrl(source: 0, coverId: entry.associatedSong?.coverId ?? 0)
                        constant = String(format: "%.1f", entry.associatedSong!.constants[entry.levelIndex])
                        rating = String(entry.rating)
                        grade = entry.rateString
                        score = String(format: "%.4f", entry.achievements) + "%"
                        title = entry.associatedSong?.title ?? ""
                    }
                }
                
            }
        }
    }
    
    @ViewBuilder
    func getImage() -> some View {
        NavigationLink {
            if let entry = chuEntry {
                SongDetailView(user: user, chuSong: entry.associatedBestEntry!.associatedSong!)
            } else if let entry = maiEntry {
                SongDetailView(user: user, maiSong: entry.associatedSong!)
            }
        } label: {
            HStack {
                ZStack {
                    AsyncImage(url: coverUrl, context: context, placeholder: {
                        ProgressView()
                    }, image: { img in
                        Image(uiImage: img)
                            .resizable()
                    })
                    .aspectRatio(1, contentMode: .fit)
                    .mask(RoundedRectangle(cornerRadius: 5))
                    .id(coverUrl.hashValue)
                    
                    if let entry = chuEntry {
                        let color = chunithmLevelColor[entry.levelIndex]
                        RoundedRectangle(cornerRadius: 5)
                            .strokeBorder(color ?? Color.white, lineWidth: 2)
                            .frame(width: 60, height: 60)
                    } else if let entry = maiEntry {
                        let color = maimaiLevelColor[entry.levelIndex]
                        RoundedRectangle(cornerRadius: 5)
                            .strokeBorder(color ?? Color.white, lineWidth: 2)
                            .frame(width: 60, height: 60)
                    }
                }
                
                Group {
                    VStack(alignment: .leading) {
                        HStack {
                            let constant = constant
                            Text(indexText)
                            Text("\(constant)/\(rating)")
                                .bold()
                        }
                        Spacer()
                        Text("\(title)")
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        HStack {
                            GradeBadgeView(grade: grade)
                                .id(grade.hashValue)
                        }
                        Spacer()
                        Text("\(score)")
                        
                    }
                }
                .font(.system(size: 18))
            }
        }
        .frame(height: 60)
        .buttonStyle(.plain)
    }
    
    func getColor(from: Color, to: Color, ratio: Double) -> Color {
        if let from = from.cgColor?.components {
            if let to = to.cgColor?.components {
                let r = from[0] + (to[0] - from[0]) * ratio
                let g = from[1] + (to[1] - from[1]) * ratio
                let b = from[2] + (to[2] - from[2]) * ratio
                let a = from[3] + (to[3] - from[3]) * ratio
                return Color.init(red: r, green: g, blue: b, opacity: a)
            }
        }
        return .clear
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
            .frame(width: screen.width / CGFloat(length * 2), height: 20)
            .scaleEffect(y: height, anchor: .bottom)
    }
}

