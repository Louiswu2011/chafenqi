//
//  NamePlateView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/3/10.
//

import SwiftUI

struct NamePlateView: View {
    @ObservedObject var user: CFQUser
    
    @State private var nameplateChuniColorTop = Color(red: 254, green: 241, blue: 65)
    @State private var nameplateChuniColorBottom = Color(red: 243, green: 200, blue: 48)
    
    @State private var nameplateMaiColorTop = Color(red: 167, green: 243, blue: 254)
    @State private var nameplateMaiColorBottom = Color(red: 93, green: 166, blue: 247)
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(LinearGradient(colors: [nameplateChuniColorTop, nameplateChuniColorBottom], startPoint: .top, endPoint: .bottom))
                .shadow(radius: 5)
                .opacity(user.currentMode == 0 ? 1 : 0)
                
            RoundedRectangle(cornerRadius: 5)
                .fill(LinearGradient(colors: [nameplateMaiColorTop, nameplateMaiColorBottom], startPoint: .top, endPoint: .bottom))
                .shadow(radius: 5)
                .opacity(user.currentMode == 1 ? 1 : 0)
            
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    ZStack {
                        Image("nameplate_penguin")
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
                            .opacity(user.currentMode == 0 ? 1 : 0)
                        Image("nameplate_salt")
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
                            .opacity(user.currentMode == 1 ? 1 : 0)
                    }
                }
            }
            
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Text(user.displayName)
                            .font(.system(size: 28))
                            .bold()
                            .frame(maxWidth: 150, alignment: .leading)
                        
                        Spacer()
                        
                        Button {
                            withAnimation(.easeInOut(duration: 0.1)) {
                                user.currentMode.flip()
                            }
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
                            if (user.currentMode == 0) {
                                Text("\(user.chunithm?.rating.rating ?? 0.00, specifier: "%.2f")")
                                    .font(.system(size: 18))
                                    .bold()
                            } else {
                                Text("\(user.maimai?.custom.rawRating ?? 0)")
                                    .font(.system(size: 18))
                                    .bold()
                            }
                        }
                        
                        HStack(alignment: .center) {
                            if (user.currentMode == 0) {
                                Text("OVERPOWER")
                                    .font(.system(size: 18))
                                
                                Text("\(user.chunithm?.custom.overpower ?? 0.0, specifier: "%.2f")")
                                    .font(.system(size: 18))
                                    .bold()
                            } else {
                                Text("排名")
                                    .font(.system(size: 18))
                                
                                Text("#\(user.maimai?.custom.nationalRanking ?? 0)")
                                    .font(.system(size: 18))
                                    .bold()
                            }
                        }
                        
                        HStack(alignment: .center) {
                            
                            if (user.currentMode == 0) {
                            
                            } else {
                                Text("平均完成率")
                                    .font(.system(size: 18))
                                Text("\(user.maimai?.custom.avgAchievement ?? 0, specifier: "%.4f")%")
                                    .font(.system(size: 18))
                                    .bold()
                            }
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
    }
    
    var gradient: LinearGradient {
        if (user.currentMode == 0) {
            return LinearGradient(colors: [nameplateChuniColorTop, nameplateChuniColorBottom], startPoint: .top, endPoint: .bottom)
        } else {
            return LinearGradient(colors: [nameplateMaiColorTop, nameplateMaiColorBottom], startPoint: .top, endPoint: .bottom)
        }
    }
    
    var avatarName: String {
        if (user.currentMode == 0) {
            return "nameplate_penguin"
        } else {
            return "nameplate_salt"
        }
    }
}

struct NamePlateView_Previews: PreviewProvider {
    static var previews: some View {
        HomeTopView()
    }
}
