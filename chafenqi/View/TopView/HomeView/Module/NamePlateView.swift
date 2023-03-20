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
        VStack {
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
                        
                        if(user.currentMode == 0) {
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
                            
                        } else {
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
                        }
                    }
                }
                
                HStack {
                    VStack(alignment: .leading) {
                        HStack {
                            Text(user.displayName)
                                .foregroundColor(.black)
                                .font(.system(size: 25))
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
                                        .font(.system(size: 16))
                                    Image(systemName: "arrow.left.arrow.right")
                                }
                            }
                        }
                        .padding(.bottom, 5)
                        
                        Group {
                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    Text("Rating")
                                    if (user.currentMode == 0) {
                                        Text("\(user.chunithm?.profile.getRating() ?? 0.0, specifier: "%.2f") (\(user.chunithm?.profile.getMaximumRating() ?? 0.0, specifier: "%.2f"))")
                                            .bold()
                                    } else {
                                        Text(verbatim: "\(user.maimai?.custom.rawRating ?? 0)")
                                            .bold()
                                    }
                                }
                                
                                HStack {
                                    Group {
                                        if (user.currentMode == 0) {
                                            Group {
                                                Text("B")
                                                Text("\(user.chunithm?.profile.getAvgB30() ?? 0.0, specifier: "%.2f")")
                                                    .bold()
                                                Text("/")
                                                Text("R")
                                                Text("\(user.chunithm?.profile.getAvgR10() ?? 0.0, specifier: "%.2f")")
                                                    .bold()
                                            }
                                        } else {
                                            Group {
                                                Text("P")
                                                Text(verbatim: "\(user.maimai?.custom.pastRating ?? 0)")
                                                    .bold()
                                                Text("/")
                                                Text("N")
                                                Text(verbatim: "\(user.maimai?.custom.currentRating ?? 0)")
                                                    .bold()
                                            }
                                        }
                                    }
                                    
                                }
                                
                                HStack {
                                    if (user.currentMode == 0) {
                                        Text("OVERPOWER")
                                        
                                        Text("\(user.chunithm?.custom.overpower ?? 0.0, specifier: "%.2f")")
                                            .bold()
                                    } else {
                                        
                                        Text("排名")
                                        
                                        Text("#\(user.maimai?.custom.nationalRanking ?? 0)")
                                            .bold()
                                    }
                                }
                                
                                Spacer()
                                
                                HStack {
                                    if (user.currentMode == 0) {
                                        Text("更新于")
                                        Text(user.chunithm?.custom.lastUpdateDate ?? "暂无数据")
                                    } else {
                                        Text("更新于")
                                        Text(user.maimai?.custom.lastUpdateDate ?? "暂无数据")
                                    }
                                }
                            }
                        }
                        .foregroundColor(.black)
                        .font(.system(size: 16))
                    }
                    Spacer()
                }
                .padding()
            }
        }
        .padding()
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
