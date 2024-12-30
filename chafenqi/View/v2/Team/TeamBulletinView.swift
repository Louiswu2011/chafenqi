//
//  TeamBulletinView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2024/12/25.
//

import Foundation
import SwiftUI
import CachedAsyncImage

struct TeamBulletinView: View {
    @ObservedObject var team: CFQTeam
    @ObservedObject var user: CFQNUser
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack {
                ForEach(team.current.bulletinBoard, id: \.id) { bulletin in
                    if let member = team.current.members.first(where: { $0.userId == bulletin.userId }) {
                        TeamBulletinEntryView(bulletin: bulletin, member: member)
                            .contextMenu {
                                Button {
                                    
                                } label: {
                                    Label("删除", systemImage: "trash")
                                        .foregroundStyle(Color.red)
                                }
                                .disabled(user.userId != bulletin.userId && user.userId != team.current.info.leaderUserId)
                                
                                Button {
                                    
                                } label: {
                                    Label("置顶", systemImage: "pin")
                                }
                                .disabled(user.userId != team.current.info.leaderUserId)
                            }
                            .padding()
                    }
                }
            }
        }
    }
}

struct TeamBulletinEntryView: View {
    var bulletin: TeamBulletinBoardEntry
    var member: TeamMember
    
    var body: some View {
        HStack {
            CachedAsyncImage(url: URL(string: member.avatar)) { image in
                image
                    .resizable()
                    .cornerRadius(5)
            } placeholder: {
                ProgressView()
            }
            .frame(width: 75, height: 75)
            
            VStack(alignment: .leading) {
                HStack {
                    Text(member.nickname.transformingHalfwidthFullwidth())
                    Spacer()
                    Text(DateTool.ymdhmsDateString(from: TimeInterval(bulletin.timestamp)))
                }
                Divider()
                Text(bulletin.content)
                    .bold()
                    .font(.body)
                Spacer()
            }
        }
        .frame(height: 75)
    }
}
