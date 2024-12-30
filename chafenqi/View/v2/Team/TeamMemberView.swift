//
//  TeamMemberView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2024/12/25.
//

import Foundation
import SwiftUI
import CachedAsyncImage

struct TeamMemberView: View {
    @ObservedObject var team: CFQTeam
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack {
                ForEach(team.current.members, id: \.userId) { member in
                    TeamMemberEntryView(member: member)
                }
            }
        }
    }
}

struct TeamMemberEntryView: View {
    var member: TeamMember
    
    @State private var expanded: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                CachedAsyncImage(url: URL(string: member.avatar)) { image in
                    image
                        .resizable()
                        .cornerRadius(5)
                        .scaledToFit()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 75, height: 75)
                
                Spacer()
                
                VStack {
                    if expanded {
                        Text(member.trophy)
                            .tint(Color.secondary)
                        Spacer()
                    }
                    Text(member.nickname.transformingHalfwidthFullwidth())
                        .bold()
                    if expanded {
                        Spacer()
                        HStack {
                            Text("Rating")
                            Text(member.rating)
                                .bold()
                            Spacer()
                            Text("游玩次数")
                            Text("\(member.playCount)")
                                .bold()
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(height: 75)
            .if(expanded) {
                $0.padding(.bottom)
            }
            
            if expanded {
                HStack {
                    Text("加入时间：")
                    Spacer()
                    Text(DateTool.ymdhmsDateString(from: TimeInterval(member.joinAt)))
                }
                .font(.caption)
                
                HStack {
                    Text("贡献点数：")
                    Spacer()
                    Text("\(member.activityPoints)P")
                }
                .font(.caption)
                
                HStack {
                    Text("最后游玩时间：")
                    Spacer()
                    Text(DateTool.ymdhmsDateString(from: TimeInterval(member.lastActivityAt)))
                }
                .font(.caption)
            }
        }
        .padding()
        .lineLimit(1)
        .onTapGesture {
            withAnimation {
                expanded.toggle()
            }
        }
    }
}
