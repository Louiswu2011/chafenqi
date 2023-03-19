//
//  RecentSpotlightCardView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/3/10.
//

import SwiftUI

struct RecentSpotlightView: View {
    
    @State var spotlightText = "新纪录"
    @State var dateSincePlayed = "2天前"
    
    @State var record = MaimaiRecentRecord.shared
    @State var chuRecord = ChunithmRecentRecord.shared
    
    var body: some View {
        ZStack {
            // TODO: Change to diff color
            RoundedRectangle(cornerRadius: 5)
                .foregroundColor(maimaiLevelColor[record.getLevelIndex()] ?? .blue)
            
            HStack {
                VStack {
                    HStack {
                        Text(record.title)
                            .font(.system(size: 18))
                        
                        Spacer()
                        
                        Text(spotlightText)
                            .font(.system(size: 18))
                            .bold()
                    }
                    
                    Spacer()
                    
                    HStack {
                        Text(record.achievement)
                            .font(.system(size: 24))
                            .bold()
                        
                        Spacer()
                        
                        NavigationLink {
                            
                        } label: {
                            Text("前往详情")
                                .font(.system(size: 18))
                        }
                    }
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
