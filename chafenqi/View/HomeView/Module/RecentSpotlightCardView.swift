//
//  RecentSpotlightCardView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/3/10.
//

import SwiftUI

struct RecentSpotlightCardView: View {
    
    @State var spotlightText = "新纪录"
    @State var dateSincePlayed = "2天前"
    @State var record = MaimaiRecentRecord.shared
    
    var body: some View {
        ZStack {
            // TODO: Change to diff color
            RoundedRectangle(cornerRadius: 5)
                .foregroundColor(maimaiLevelColor[record.getLevelIndex()] ?? .blue)
            
            HStack {
                VStack {
                    HStack {
                        Text(record.title)
                            .font(.system(size: 20))
                        
                        Spacer()
                        
                        Text(spotlightText)
                            .font(.system(size: 20))
                            .bold()
                    }
                    
                    Spacer()
                    
                    HStack {
                        Text(record.achievement)
                            .font(.system(size: 30))
                            .bold()
                        
                        Spacer()
                    }
                }
            }
            .padding()
        }
        .frame(height: 100)
    }

}

struct RecentSpotlightCardView_Previews: PreviewProvider {
    static var previews: some View {
        RecentSpotlightCardView()
    }
}
