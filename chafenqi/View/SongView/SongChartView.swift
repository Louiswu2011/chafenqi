//
//  SongChartView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/21.
//

import SwiftUI
import CachedAsyncImage

struct SongChartView: View {
    
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var viewState = CGSize.zero
    
    var webChartId: String
    var diff: String
    
    var body: some View {
        ScrollView(.horizontal) {
            ZStack {
                let barURL = URL(string: "https://sdvx.in/chunithm/\(webChartId.prefix(2))/bg/\(webChartId)bar.png")
                let bgURL = URL(string: "https://sdvx.in/chunithm/\(webChartId.prefix(2))/bg/\(webChartId)bg.png")
                let chartURL = URL(string: "https://sdvx.in/chunithm/\(webChartId.prefix(2))/obj/data\(webChartId)\(diff).png")
                
                CachedAsyncImage(url: bgURL) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else if let error = phase.error {
                        Color.red
                    } else {
                        ProgressView()
                    }
                }
                
                CachedAsyncImage(url: barURL) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else if let error = phase.error {
                        Color.red
                    } else {
                        ProgressView()
                    }
                }
                
                CachedAsyncImage(url: chartURL) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } else if let error = phase.error {
                        Color.red
                    } else {
                        ProgressView()
                    }
                }
            }
        }
        
    }
}

struct SongChartView_Previews: PreviewProvider {
    static var previews: some View {
        SongChartView(webChartId: "0", diff: "mst")
    }
}
