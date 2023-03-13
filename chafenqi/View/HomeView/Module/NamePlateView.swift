//
//  NamePlateView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/3/10.
//

import SwiftUI

struct NamePlateView: View {
    @AppStorage("settingsCurrentMode") var mode = 0
    @AppStorage("userNickname") var nickname = ""
    
    private var nameplateChuniColorTop = Color(red: 254, green: 241, blue: 65)
    private var nameplateChuniColorBottom = Color(red: 243, green: 200, blue: 48)
    
    @State private var plateBackgroundGradient: LinearGradient = LinearGradient(colors: [.black, .white], startPoint: .top, endPoint: .bottom)
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(plateBackgroundGradient)
            
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Image("nameplate_penguin")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .padding(.trailing, 10)
                        .frame(width: 100, height: 100)
                    
                }
            }
            
            HStack {
                VStack(alignment: .leading) {
                    Text(nickname)
                        .font(.system(size: 27))
                        .bold()
                        .frame(maxWidth: 150, alignment: .leading)
                    
                    HStack(alignment: .center) {
                        Text("Rating")
                        Text("999.00")
                            .font(.system(size: 20))
                            
                    }
                    Spacer()
                }
                Spacer()
            }
            .padding()
        }
        .padding()
        .frame(height: 150)
        .onAppear {
            // TODO: Replace placeholder color value for both game
            if (mode == 0) {
                plateBackgroundGradient = LinearGradient(colors: [nameplateChuniColorTop, nameplateChuniColorBottom], startPoint: .top, endPoint: .bottom)
            } else {
                
            }
        }
    }
}

struct NamePlateView_Previews: PreviewProvider {
    static var previews: some View {
        NamePlateView()
    }
}
