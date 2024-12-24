//
//  HomeTeam.swift
//  chafenqi
//
//  Created by 刘易斯 on 2024/12/24.
//

import Foundation
import SwiftUI

struct HomeTeam: View {
    @ObservedObject var user: CFQNUser
    
    var body: some View {
        HStack {
            NavigationLink {
                TeamLandingPage(user: user)
            } label: {
                Text("团队")
            }
        }
    }
}
