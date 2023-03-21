//
//  RatingAnalysisView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/3/22.
//

import SwiftUI

struct RatingAnalysisView: View {
    var body: some View {
        VStack {
            HStack {
                Text("B30")
                    .bold()
                Text("平均")
            }
        }
    }
}

struct RatingAnalysisView_Previews: PreviewProvider {
    static var previews: some View {
        RatingAnalysisView()
    }
}
