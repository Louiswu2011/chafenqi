//
//  WelcomeView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/20.
//

import SwiftUI

struct WelcomeTabView: View {
    @Binding var isShowingWelcome: Bool
    
    var body: some View {
        TabView {
            WelcomePage1View()
            WelcomePage2View()
            WelcomePage3View()
            WelcomeEndPageView(isShowingWelcome: $isShowingWelcome)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeTabView(isShowingWelcome: .constant(true))
    }
}
