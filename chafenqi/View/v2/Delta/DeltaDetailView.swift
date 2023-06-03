//
//  DeltaDetailView.swift
//  chafenqi
//
//  Created by xinyue on 2023/5/29.
//

import SwiftUI

struct DeltaDetailView: View {
    @ObservedObject var user = CFQNUser()
    
    @State var deltaIndex = 0
    @State var isLoaded = false
    
    @State var dateString: String = ""
    @State var rating: String = ""
    @State var ratingDelta: String = ""
    @State var pc: String = ""
    @State var pcDelta: String = ""
    
    @State var chuLog: CFQChunithmRecentScoreEntries = []
    @State var maiLog: CFQMaimaiRecentScoreEntries = []
    
    @State var chartType = 0
    
    var body: some View {
        ScrollView {
            if isLoaded {
                VStack {
                    HStack {
                        DeltaTextBlock(title: "Rating", currentValue: rating, deltaValue: ratingDelta)
                            .padding(.trailing, 5)
                        DeltaTextBlock(title: "游玩次数", currentValue: pc, deltaValue: pcDelta)
                        Spacer()
                    }
                    .padding(.bottom)
                    
                    HStack {
                        Text("游玩记录")
                            .font(.system(size: 20))
                            .bold()
                        Spacer()
                        NavigationLink {
                            if user.currentMode == 0 {
                                DeltaPlayList(user: user, chuLog: chuLog)
                            } else if user.currentMode == 1 {
                                DeltaPlayList(user: user, maiLog: maiLog)
                            }
                        } label: {
                            Text("显示全部")
                        }
                    }
                    VStack {
                        if user.currentMode == 0 {
                            ForEach(Array(chuLog.prefix(3)), id: \.timestamp) { entry in
                                NavigationLink {
                                    RecentDetail(user: user, chuEntry: entry)
                                } label: {
                                    HStack {
                                        SongCoverView(coverURL: ChunithmDataGrabber.getSongCoverUrl(source: user.chunithmCoverSource, musicId: String(entry.associatedSong!.musicID)), size: 65, cornerRadius: 5)
                                            .padding(.trailing, 5)
                                        Spacer()
                                        VStack {
                                            HStack {
                                                Text(entry.timestamp.customDateString)
                                                Spacer()
                                            }
                                            Spacer()
                                            HStack(alignment: .bottom) {
                                                Text(entry.title)
                                                    .font(.system(size: 17))
                                                    .lineLimit(2)
                                                Spacer()
                                                Text("\(entry.score)")
                                                    .font(.system(size: 21))
                                                    .bold()
                                            }
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        } else if user.currentMode == 1 {
                            ForEach(Array(maiLog.prefix(3)), id: \.timestamp) { entry in
                                NavigationLink {
                                    RecentDetail(user: user, maiEntry: entry)
                                } label: {
                                    HStack {
                                        SongCoverView(coverURL: MaimaiDataGrabber.getSongCoverUrl(source: user.maimaiCoverSource, coverId: getCoverNumber(id: String(entry.associatedSong!.musicId))), size: 65, cornerRadius: 5)
                                            .padding(.trailing, 5)
                                        Spacer()
                                        VStack {
                                            HStack {
                                                Text(entry.timestamp.customDateString)
                                                Spacer()
                                            }
                                            Spacer()
                                            HStack(alignment: .bottom) {
                                                Text(entry.title)
                                                    .font(.system(size: 17))
                                                    .lineLimit(2)
                                                Spacer()
                                                Text("\(entry.score, specifier: "%.4f")%")
                                                    .font(.system(size: 21))
                                                    .bold()
                                            }
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .onAppear {
            isLoaded = false
            loadVar()
        }
        .navigationTitle(dateString)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func loadVar() {
        if user.currentMode == 0 && user.chunithm.delta.count > 1 {
            let latestDelta = user.chunithm.delta[deltaIndex]
            dateString = latestDelta.createdAt.toDateString(format: "yyyy-MM-dd hh:mm")
            rating = String(format: "%.2f", latestDelta.rating)
            pc = "\(latestDelta.playCount)"
            if deltaIndex == user.chunithm.delta.count - 1 {
                ratingDelta = getRatingDelta(current: 0, past: 0)
                pcDelta = getPCDelta(current: 0, past: 0)
            } else {
                let secondDelta = user.chunithm.delta[deltaIndex + 1]
                ratingDelta = getRatingDelta(current: latestDelta.rating, past: secondDelta.rating)
                pcDelta = getPCDelta(current: latestDelta.playCount, past: secondDelta.playCount)
            }
            chuLog = getChuPlaylist()
        } else if user.currentMode == 1 && user.maimai.delta.count > 1 {
            let latestDelta = user.maimai.delta[deltaIndex]
            rating = "\(latestDelta.rating)"
            pc = "\(latestDelta.playCount)"
            if deltaIndex == user.maimai.delta.count - 1 {
                ratingDelta = getRatingDelta(current: 0, past: 0)
                pcDelta = getPCDelta(current: 0, past: 0)
            } else {
                let secondDelta = user.maimai.delta[deltaIndex + 1]
                ratingDelta = getRatingDelta(current: latestDelta.rating, past: secondDelta.rating)
                pcDelta = getPCDelta(current: latestDelta.playCount, past: secondDelta.playCount)
            }
            maiLog = getMaiPlaylist()
        }
        isLoaded = true
    }
    
    func getRatingDelta(current lhs: Double, past rhs: Double) -> String {
        let rawValue = lhs - rhs
        if rawValue > 0 {
            return "+" + String(format: "%.2f", rawValue)
        } else if rawValue < 0 {
            return String(format: "%.2f", rawValue)
        } else {
            return "\u{00B1}0"
        }
    }
    
    func getRatingDelta(current lhs: Int, past rhs: Int) -> String {
        let rawValue = lhs - rhs
        if rawValue > 0 {
            return "+\(rawValue)"
        } else if rawValue < 0 {
            return "\(rawValue)"
        } else {
            return "\u{00B1}0"
        }
    }
    
    func getPCDelta(current lhs: Int, past rhs: Int) -> String {
        let rawValue = lhs - rhs
        if rawValue > 0 {
            return "+\(rawValue)"
        } else if rawValue < 0 {
            return "\(rawValue)"
        } else {
            return "\u{00B1}0"
        }
    }
    
    func convertDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = .autoupdatingCurrent
        formatter.formatOptions = [.withColonSeparatorInTimeZone, .withSpaceBetweenDateAndTime, .withFractionalSeconds, .withInternetDateTime]
        if let date = formatter.date(from: dateString) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "M-d"
            dateFormatter.locale = .autoupdatingCurrent
            dateFormatter.timeZone = .autoupdatingCurrent
            return dateFormatter.string(from: date)
        }
        return ""
    }
    
    func getChuPlaylist() -> CFQChunithmRecentScoreEntries {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = .autoupdatingCurrent
        formatter.formatOptions = [.withColonSeparatorInTimeZone, .withSpaceBetweenDateAndTime, .withFractionalSeconds, .withInternetDateTime]
        if let latestTimestamp = formatter.date(from: user.chunithm.delta[deltaIndex].createdAt)?.timeIntervalSince1970 {
            var filtered = user.chunithm.recent
            if deltaIndex == user.chunithm.delta.count - 1 {
                // last
                filtered = filtered.filter {
                    (0...latestTimestamp).contains(TimeInterval($0.timestamp))
                }
            } else {
                if let secondTimestamp = formatter.date(from: user.chunithm.delta[deltaIndex + 1].createdAt)?.timeIntervalSince1970 {
                    filtered = filtered.filter {
                        (secondTimestamp...latestTimestamp).contains(TimeInterval($0.timestamp))
                    }
                }
            }
            return filtered
        }
        return []
    }
    
    func getMaiPlaylist() -> CFQMaimaiRecentScoreEntries {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = .autoupdatingCurrent
        formatter.formatOptions = [.withColonSeparatorInTimeZone, .withSpaceBetweenDateAndTime, .withFractionalSeconds, .withInternetDateTime]
        if let latestTimestamp = formatter.date(from: user.maimai.delta[deltaIndex].createdAt)?.timeIntervalSince1970 {
            var filtered = user.maimai.recent
            if deltaIndex == user.maimai.delta.count - 1 {
                // last
                filtered = filtered.filter {
                    (0...latestTimestamp).contains(TimeInterval($0.timestamp))
                }
            } else {
                if let secondTimestamp = formatter.date(from: user.maimai.delta[deltaIndex + 1].createdAt)?.timeIntervalSince1970 {
                    filtered = filtered.filter {
                        (secondTimestamp...latestTimestamp).contains(TimeInterval($0.timestamp))
                    }
                }
            }
            return filtered
        }
        return []
    }

}

struct DeltaTextBlock: View {
    var title: String
    var currentValue: String
    var deltaValue: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
            HStack(alignment: .bottom) {
                Text(currentValue)
                    .font(.system(size: 25))
                Text(deltaValue)
            }
        }
    }
}

struct DeltaDetailView_Previews: PreviewProvider {
    static var previews: some View {
        DeltaDetailView()
    }
}
