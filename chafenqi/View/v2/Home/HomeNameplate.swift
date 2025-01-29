//
//  NamePlateView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/3/10.
//

import SwiftUI

struct HomeNameplate: View {
    @Environment(\.managedObjectContext) var context
    @ObservedObject var user: CFQNUser
    
    @State private var updateTime = ""
    
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 5)
                    .fill(user.currentMode == 0 ?
                          user.homeUseCurrentVersionTheme ? nameplateThemedChuniGradientStyle : nameplateDefaultChuniGradientStyle :
                            user.homeUseCurrentVersionTheme ? nameplateThemedMaiGradientStyle : nameplateDefaultMaiGradientStyle
                    )
//                    .fill(user.currentMode == 0 ? nameplateDefaultChuniGradientStyle : nameplateDefaultMaiGradientStyle)
                    .shadow(radius: 5)
                
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
                            let displayName = user.currentMode == 0 ? user.chunithm.nickname ?? user.username : user.maimai.nickname
                            Text(displayName)
                                .foregroundColor(.black)
                                .font(.system(size: 25))
                                .bold()
                                .frame(maxWidth: 180, alignment: .leading)
                            
                            Spacer()
                            
                            NavigationLink {
                                if user.isPremium {
                                    if user.currentMode == 0 {
                                        PlayerChunithmInfoView(context: _context, user: user)
                                    } else if user.currentMode == 1 {
                                        PlayerMaimaiInfoView(context: _context, user: user)
                                    }
                                } else {
                                    NotPremiumView()
                                }
                            } label: {
                                HStack {
                                    Text("玩家信息")
                                    Image(systemName: "person.crop.square")
                                        .font(.system(size: 16))
                                }
                            }
                        }
                        .padding(.bottom, 5)
                        
                        Group {
                            VStack(alignment: .leading, spacing: 2) {
                                HStack {
                                    Text("Rating")
                                    if (user.currentMode == 0) {
                                        Text("\(user.chunithm.info.last?.rating ?? 0, specifier: "%.2f") (\(user.chunithm.custom.maxRating, specifier: "%.2f"))")
                                            .bold()
                                    } else {
                                        Text(verbatim: "\(user.maimai.custom.rawRating)")
                                            .bold()
                                    }
                                }
                                
                                HStack {
                                    Group {
                                        if (user.currentMode == 0) {
                                            Group {
                                                Text("B")
                                                Text("\(user.chunithm.custom.b30, specifier: "%.2f")")
                                                    .bold()
                                                Text("/")
                                                Text("R")
                                                Text("\(user.chunithm.custom.r10, specifier: "%.2f")")
                                                    .bold()
                                            }
                                        } else {
                                            Group {
                                                Text("P")
                                                Text(verbatim: "\(user.maimai.custom.pastRating)")
                                                    .bold()
                                                Text("/")
                                                Text("N")
                                                Text(verbatim: "\(user.maimai.custom.currentRating)")
                                                    .bold()
                                            }
                                        }
                                    }
                                    
                                }
                                
                                HStack {
                                    if (user.currentMode == 0) {
                                        Text("OVERPOWER")
                                        
                                        Text("\(user.chunithm.info.last?.rawOverpower ?? 0, specifier: "%.2f")")
                                            .bold()
                                    } else {
                                        Text("游玩次数")

                                        Text("\(user.maimai.info.last?.playCount ?? 0)")
                                            .bold()
                                    }
                                }
                                
                                Spacer()
                                
                                HStack {
                                    Text("更新于")
                                    if user.currentMode == 0 {
                                        Text(getUpdateTime(TimeInterval(user.chunithm.info.last?.timestamp ?? 0)))
                                    } else {
                                        Text(getUpdateTime(TimeInterval(user.maimai.info.last?.timestamp ?? 0)))
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
    
    func getUpdateTime(_ str: String) -> String {
        DateTool.updateDateString(from: str)
    }
    
    func getUpdateTime(_ epoch: TimeInterval) -> String {
        DateTool.updateTimestamp(from: epoch)
    }
    
    var avatarName: String {
        if (user.currentMode == 0) {
            return "nameplate_penguin"
        } else {
            return "nameplate_salt"
        }
    }
}

struct HomeNameplate_Previews: PreviewProvider {
    static var previews: some View {
        HomeNameplate(user: CFQNUser())
    }
}
