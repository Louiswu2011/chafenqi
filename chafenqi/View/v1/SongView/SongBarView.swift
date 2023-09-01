//
//  SongBarView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/14.
//

import SwiftUI

struct SongBarView: View {
    let song: ScoreEntry
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .foregroundColor(chunithmLevelColor[song.levelIndex]!)
            
            HStack(spacing: 0) {
                Text(song.title)
                    .if(song.levelIndex == 4) { view in
                        view.foregroundColor(.white)
                    }
                    .padding(.leading)
                
                Spacer()
                
                
                if (song.getStatus() != "Clear") {
                    ZStack {
                        Rectangle()
                            .foregroundColor(song.getClearBadgeColor())
                        
                        Text(song.getStatus())
                            .if(song.levelIndex == 4) { view in
                                view.foregroundColor(.white)
                            }
                    }
                    .frame(width: 40)
                    
                }
                
                ZStack {
                    Rectangle()
                        .foregroundColor(.teal)
                    
                    Text(String(song.score))
                        .bold()
                        .if(song.levelIndex == 4) { view in
                            view.foregroundColor(.white)
                        }
                }
                .frame(width: 90)
                .mask {
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: 100)
                        .padding(.trailing, 10)
                }
            }
        }
        .frame(height: 30)
        .padding(.horizontal)
    }
}

struct SongBarView_Previews: PreviewProvider {
    static var previews: some View {
        SongBarView(song: song)
    }
}

extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
