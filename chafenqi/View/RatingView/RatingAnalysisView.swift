//
//  RatingAnaysisView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/3/22.
//

import SwiftUI

struct RatingAnalysisView: View {
    var body: some View {
        VStack {
            HStack(alignment: .bottom) {
                Text("Past")
                Text("8888")
                    .font(.system(size: 20))
                    .bold()
            }
            Divider()
            
        }
    }
}

struct RatingAnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        RatingAnalysisView()
    }
}
