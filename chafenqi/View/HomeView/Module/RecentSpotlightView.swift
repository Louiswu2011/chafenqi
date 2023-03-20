//
//  RecentSpotlightCardView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/3/10.
//

import SwiftUI

struct RecentSpotlightView: View {    
    @ObservedObject var user = CFQUser()
    
    var body: some View {
        ZStack {
            Group {
                if (user.currentMode == 0) {
                    ChunithmSpotlightView(record: user.chunithm!.recent.first, spotlightText: "Recent")
                    ChunithmSpotlightView(record: user.chunithm!.recent.getLatestNewRecord(), spotlightText: "NewRecord")
                    ChunithmSpotlightView(record: user.chunithm!.recent.getLatestHighscore(), spotlightText: "Highscore")
                } else {
                    MaimaiSpotlightView(record: user.maimai!.recent.first, spotlightText: "Recent")
                    MaimaiSpotlightView(record: user.maimai!.recent.getLatestNewRecord(), spotlightText: "NewRecord")
                    MaimaiSpotlightView(record: user.maimai!.recent.getLatestHighscore(), spotlightText: "Highscore")
                }
            }
            .padding()
        }
        .frame(height: 80)
    }

}

struct RecentSpotlightCardView_Previews: PreviewProvider {
    static var previews: some View {
        RecentSpotlightView()
    }
}

struct ChunithmSpotlightView: View {
    @State var record: ChunithmRecentRecord?
    @State var spotlightText: String
    
    var body: some View {
        HStack {
            
        }
    }
}

struct MaimaiSpotlightView: View {
    @State var record: MaimaiRecentRecord?
    @State var spotlightText: String
    
    var body: some View {
        HStack {
            
        }
    }
}
