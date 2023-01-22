//
//  SongChartView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/21.
//

import SwiftUI
import CachedAsyncImage

struct SongChartView: View {
    
    @State var chartImage: UIImage
    
    var body: some View {
        ScrollView(.horizontal) {
            Image(uiImage: chartImage)
                .resizable()
                .scaledToFill()
                .background(Color.black)
        }
    }
}
