//
//  MaimaiHomeView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/3.
//

import SwiftUI
import AlertToast

struct MaimaiHomeView: View {
    @AppStorage("settingsCoverSource") var coverSource = 0
    @AppStorage("loadedMaimaiSongs") var loadedSongs: Data = Data()
    
    @AppStorage("userNickname") var accountNickname = ""
    @AppStorage("userAccountName") var accountName = ""
    @AppStorage("userToken") var token = ""
    
    @AppStorage("didLogin") var didLogin = false
    
    private var rows = [
        GridItem(),
        GridItem()
    ]
    
    var body: some View {
        ZStack {
            HStack {
                ZStack {
                    CutCircularProgressView(progress: 0.6, lineWidth: 10, width: 70, color: Color.indigo)
                    
                    Text("12345")
                        .foregroundColor(Color.indigo)
                        .textFieldStyle(.roundedBorder)
                        .font(.title3)
                    
                    Text("R10")
                        .padding(.top, 60)
                }
                .padding()
                .padding(.top, 50)
                
                ZStack {
                    CutCircularProgressView(progress: 0.7, lineWidth: 14, width: 100, color: Color.pink)
                    
                    Text("5678")
                        .foregroundColor(Color.pink)
                        .textFieldStyle(.roundedBorder)
                        .font(.title)
                        .transition(.opacity)
                    
                    Text("Rating")
                        .padding(.top, 70)
                }
                .padding()
                
                
                ZStack {
                    // TODO: get max
                    CutCircularProgressView(progress: 0.3, lineWidth: 10, width: 70, color: Color.cyan)
                    
                    Text("3234")
                        .foregroundColor(Color.cyan)
                        .textFieldStyle(.roundedBorder)
                        .font(.title3)
                    
                    Text("B30")
                        .padding(.top, 60)
                }
                .padding()
                .padding(.top, 50)
            }
            .navigationTitle(didLogin ? "LOUIS的个人资料" : "查分器DX")
        }
    }
}


struct MaimaiHomeView_Previews: PreviewProvider {
    static var previews: some View {
        MaimaiHomeView()
    }
}
