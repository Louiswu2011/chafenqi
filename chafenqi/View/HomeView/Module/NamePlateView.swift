//
//  NamePlateView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/3/10.
//

import SwiftUI

struct NamePlateView: View {
    @AppStorage("settingsCurrentMode") var mode = 0
    @AppStorage("userAccountName") var username = ""
    @AppStorage("userNickname") var nickname = ""
    
    private var nameplateChuniColorTop = Color(red: 254, green: 241, blue: 65)
    private var nameplateChuniColorBottom = Color(red: 243, green: 200, blue: 48)
    
    private var nameplateMaiColorTop = Color(red: 167, green: 243, blue: 254)
    private var nameplateMaiColorBottom = Color(red: 93, green: 166, blue: 247)
    
    @State private var plateBackgroundGradient: LinearGradient = LinearGradient(colors: [.black, .white], startPoint: .top, endPoint: .bottom)
    @State private var plateImageName = ""
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(plateBackgroundGradient)
                .shadow(radius: 5)
            
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Image(plateImageName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .padding(.trailing, 10)
                        .frame(width: 110, height: 110)
                        .contextMenu {
                            Button {
                                // TODO: Add custom avatar
                            } label: {
                                Image(systemName: "rectangle.on.rectangle.angled")
                                Text("照片图库")
                            }
                        }
                    
                }
            }
            
            HStack {
                VStack(alignment: .leading) {
                    let displayName = nickname.isEmpty ? username : nickname
                    
                    HStack {
                        Text(displayName)
                            .font(.system(size: 28))
                            .bold()
                            .frame(maxWidth: 150, alignment: .leading)
                        
                        Spacer()
                        
                        Button {
                            
                        } label: {
                            HStack {
                                Text("切换游戏")
                                    .font(.system(size: 18))
                                Image(systemName: "arrow.left.arrow.right")
                            }
                        }
                    }
                    .padding(.bottom, 5)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack() {
                            Text("Rating")
                                .font(.system(size: 18))
                            Text("10302")
                                .font(.system(size: 18))
                                .bold()
                        }
                        
                        HStack(alignment: .center) {
                            Text("排名")
                                .font(.system(size: 18))
                            Text("#1000")
                                .font(.system(size: 18))
                                .bold()
                        }
                        
                        HStack(alignment: .center) {
                            Text("总完成率")
                                .font(.system(size: 18))
                            Text("100000%")
                                .font(.system(size: 18))
                                .bold()
                        }
                    }
                    // .padding(.top, 10)
                    Spacer()
                }
                Spacer()
            }
            .padding()
        }
        .padding()
        .frame(height: 200)
        .onAppear {
            if (mode == 0) {
                plateBackgroundGradient = LinearGradient(colors: [nameplateChuniColorTop, nameplateChuniColorBottom], startPoint: .top, endPoint: .bottom)
                plateImageName = "nameplate_penguin"
            } else {
                plateBackgroundGradient = LinearGradient(colors: [nameplateMaiColorTop, nameplateMaiColorBottom], startPoint: .top, endPoint: .bottom)
                plateImageName = "nameplate_salt"
            }
        }
    }
}

struct NamePlateView_Previews: PreviewProvider {
    static var previews: some View {
        NamePlateView()
    }
}
