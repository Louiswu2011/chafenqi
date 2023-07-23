//
//  PlayerInfoView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/5/9.
//

import SwiftUI
import CachedAsyncImage

struct PlayerChunithmInfoView: View {
    @Environment(\.managedObjectContext) var context
    @ObservedObject var user: CFQNUser
    
    @State private var isLoaded = false
    
    @State private var avatarUrlString = ""
    @State private var skillUrlString = ""
    
    @State private var charName = ""
    @State private var charLevel = ""
    @State private var skillName = ""
    @State private var skillDescription = ""
    @State private var friendCodeString = ""
    
    @State private var skillLevel = 0
    @State private var playCount = 0
    @State private var currentGold = 0
    @State private var totalGold = 0
    @State private var charCount = 0
    @State private var skillCount = 0
    @State private var nameplateCount = 0
    @State private var trophyCount = 0
    @State private var ticketCount = 0
    @State private var mapIconCount = 0
    
    @State private var overpowerRaw = 0.0
    @State private var overpowerPercent = 0.0
    @State private var charProgress = 0.0
    
    @State private var avatarImg = UIImage()
    
    
    var body: some View {
        ScrollView {
            if isLoaded {
                AsyncImage(url: URL(string: avatarUrlString)!, context: context, placeholder: {
                    ProgressView()
                }, image: { img in
                    let _ = DispatchQueue.main.async {
                        self.avatarImg = img
                    }
                    Image(uiImage: img)
                        .resizable()
                })
                .aspectRatio(1, contentMode: .fit)
                .frame(width: 250)
                .contextMenu {
                    Button {
                        UIImageWriteToSavedPhotosAlbum(avatarImg, nil, nil, nil)
                    } label: {
                        Label("保存到相册", systemImage: "square.and.arrow.down")
                    }
                }
                
                VStack(spacing: 5) {
                    Text(charName)
                        .font(.system(size: 18))
                        .bold()
                    
                    HStack {
                        VStack {
                            Text("等级")
                            Text(charLevel)
                                .font(.system(size: 16))
                                .bold()
                        }
                        ProgressView(value: 0.3)
                    }
                    .padding(.bottom)
                    
                    HStack {
                        AsyncImage(url: URL(string: skillUrlString)!, context: context, placeholder: {
                            ProgressView()
                        }, image: { img in
                            Image(uiImage: img)
                                .resizable()
                        })
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: 45)
                        
                        VStack(alignment: .leading) {
                            Text(skillName)
                            Spacer()
                            Text(skillDescription)
                                .font(.system(size: 10))
                        }
                        Spacer()
                        VStack {
                            Text("等级")
                            Text("\(skillLevel)")
                                .font(.system(size: 16))
                                .bold()
                        }
                    }
                    .padding(.bottom)
                    
                    HStack {
                        Text("游玩次数")
                        Spacer()
                        Text("\(playCount)")
                            .bold()
                    }
                    HStack {
                        Text("OVERPOWER")
                        Spacer()
                        Text("\(overpowerRaw, specifier: "%.2f")")
                            .bold()
                        Text("(\(overpowerPercent, specifier: "%.2f")%)")
                    }
                    HStack {
                        Text("金币数")
                        Spacer()
                        Text("\(currentGold)")
                            .bold()
                        Text("(\(totalGold))")
                    }
                    .padding(.bottom, 15)
                    
                    HStack {
                        NavigationLink {
                            InfoCharacterList(characters: user.chunithm.extra.characters)
                        } label: {
                            HStack {
                                Text("角色")
                                Spacer()
                                Text("\(charCount)")
                                    .bold()
                            }
                        }
                        NavigationLink {
                            InfoSkillList(skills: user.chunithm.extra.skills)
                        } label: {
                            HStack {
                                Text("技能")
                                Spacer()
                                Text("\(skillCount)")
                                    .bold()
                            }
                        }
                    }
                    HStack {
                        NavigationLink {
                            InfoChunithmNameplateList(list: user.chunithm.extra.nameplates)
                        } label: {
                            HStack {
                                Text("名牌版")
                                Spacer()
                                Text("\(nameplateCount)")
                                    .bold()
                            }
                        }
                        NavigationLink {
                            InfoChunithmTrophyList(list: user.chunithm.extra.trophies)
                        } label: {
                            HStack {
                                Text("称号")
                                Spacer()
                                Text("\(trophyCount)")
                                    .bold()
                            }
                        }
                    }
                    HStack {
                        HStack {
                            Text("功能票")
                            Spacer()
                            Text("\(ticketCount)")
                                .bold()
                        }
                        HStack {
                            Text("地图头像")
                            Spacer()
                            Text("\(mapIconCount)")
                                .bold()
                        }
                    }
                    
                    
                }
                .padding()
                
                HStack {
                    Text("好友代码")
                    Spacer()
                    Text(friendCodeString)
                        .bold()
                    Button {
                        UIPasteboard.general.string = friendCodeString
                    } label: {
                        Text("复制")
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("玩家信息")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            loadVar()
        }
    }
    
    func loadVar() {
        guard user.isPremium && !user.chunithm.extra.collections.isEmpty else { return }
        if user.currentMode == 0 {
            if let currentAvatar = user.chunithm.extra.collections.last {
                avatarUrlString = currentAvatar.charUrl
                charName = currentAvatar.charName
                charLevel = currentAvatar.charRank
                charProgress = currentAvatar.charExp
            } else {
                avatarUrlString = "https://chunithm.wahlap.com/mobile/img/71e1e250b22e2f4f.png"
            }
            if let currentSkill = user.chunithm.extra.skills.first(where: {
                $0.current == 1
            }) {
                skillUrlString = currentSkill.icon
                skillLevel = currentSkill.level
                skillName = currentSkill.name
                skillDescription = currentSkill.description
            }
            playCount = user.chunithm.info.playCount
            overpowerRaw = user.chunithm.info.overpower_raw
            overpowerPercent = user.chunithm.info.overpower_percent
            currentGold = user.chunithm.info.currentGold
            totalGold = user.chunithm.info.totalGold
            charCount = user.chunithm.extra.characters.count
            skillCount = user.chunithm.extra.skills.count
            nameplateCount = user.chunithm.extra.nameplates.count
            trophyCount = user.chunithm.extra.trophies.count
            ticketCount = user.chunithm.extra.tickets.reduce(0) { $0 + $1.count }
            mapIconCount = user.chunithm.extra.mapIcons.count
            friendCodeString = user.chunithm.info.friendCode
            isLoaded = true
        }
        
    }
}

struct PlayerInfoView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerChunithmInfoView(user: CFQNUser())
    }
}
