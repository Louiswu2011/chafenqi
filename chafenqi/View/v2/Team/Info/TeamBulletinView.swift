//
//  TeamBulletinView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2024/12/25.
//

import Foundation
import SwiftUI
import CachedAsyncImage
import Inject
import AlertToast

struct TeamBulletinView: View {
    @ObserveInjection var inject
    
    @ObservedObject var team: CFQTeam
    @ObservedObject var user: CFQNUser
    @ObservedObject var alertToastModel = AlertToastModel.shared
    
    @State private var showPostSheet = false
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack {
                Button {
                    showPostSheet.toggle()
                } label: {
                    Label("发布留言", systemImage: "plus")
                }
                .padding(.bottom)
                
                if let pinned = team.current.bulletinBoard.first(where: { $0.id == team.current.info.pinnedMessageId }), let member = team.current.members.first(where: { $0.userId == pinned.userId }) {
                    TeamBulletinEntryView(bulletin: pinned, member: member)
                        .contextMenu {
                            Button {
                                deleteBulletin(id: pinned.id)
                            } label: {
                                Label("删除", systemImage: "trash")
                                    .foregroundStyle(Color.red)
                            }
                            .disabled(user.userId != pinned.userId && user.userId != team.current.info.leaderUserId)
                            
                            Button {
                                unpinBulletin()
                            } label: {
                                Label("取消置顶", systemImage: "pin.slash")
                            }
                            .disabled(user.userId != team.current.info.leaderUserId)
                        }
                        .padding(.horizontal)
                    Divider()
                }
                
                ForEach(team.current.bulletinBoard
                    .sorted { $0.timestamp > $1.timestamp }
                    .filter { $0.id != team.current.info.pinnedMessageId }, id: \.id) { bulletin in
                    if let member = team.current.members.first(where: { $0.userId == bulletin.userId }) {
                        TeamBulletinEntryView(bulletin: bulletin, member: member)
                            .contextMenu {
                                Button {
                                    deleteBulletin(id: bulletin.id)
                                } label: {
                                    Label("删除", systemImage: "trash")
                                        .foregroundStyle(Color.red)
                                }
                                .disabled(user.userId != bulletin.userId && user.userId != team.current.info.leaderUserId)
                                
                                Button {
                                    pinBulletin(id: bulletin.id)
                                } label: {
                                    Label("置顶", systemImage: "pin")
                                }
                                .disabled(user.userId != team.current.info.leaderUserId)
                            }
                            .padding(.horizontal)
                    }
                }
            }
        }
        .enableInjection()
        .sheet(isPresented: $showPostSheet) {
            TeamBulletinPostSheet(username: team.current.members.first(where: { $0.userId == user.userId })?.nickname.transformingHalfwidthFullwidth() ?? user.username, onCancel: { showPostSheet.toggle() }) { message in
                postBulletin(message: message)
            }
        }
    }
    
    func pinBulletin(id: Int) {
        Task {
            let result = await CFQTeamServer.adminSetPinnedMessage(authToken: user.jwtToken, game: user.currentMode, teamId: team.current.info.id, pinnedMessageId: id)
            if result.isEmpty {
                team.refresh(user: user)
            } else {
                alertToastModel.toast = AlertToast(displayMode: .hud, type: .error(Color.red), title: "置顶失败", subTitle: result)
            }
        }
    }
    
    func unpinBulletin() {
        Task {
            let result = await CFQTeamServer.adminResetPinnedMessage(authToken: user.jwtToken, game: user.currentMode, teamId: team.current.info.id)
            if result.isEmpty {
                team.refresh(user: user)
            } else {
                alertToastModel.toast = AlertToast(displayMode: .hud, type: .error(Color.red), title: "取消置顶失败", subTitle: result)
            }
        }
    }
    
    func deleteBulletin(id: Int) {
        if team.current.info.pinnedMessageId == id {
            unpinBulletin()
        }
        Task {
            let result = await CFQTeamServer.deleteTeamBulletinBoardEntry(authToken: user.jwtToken, game: user.currentMode, teamId: team.current.info.id, entryId: id)
            if result.isEmpty {
                team.refresh(user: user)
            } else {
                alertToastModel.toast = AlertToast(displayMode: .hud, type: .error(Color.red), title: "删除失败", subTitle: result)
            }
        }
    }
    
    func postBulletin(message: String) {
        Task {
            let result = await CFQTeamServer.addTeamBulletinBoardEntry(authToken: user.jwtToken, game: user.currentMode, teamId: team.current.info.id, message: message)
            if result.isEmpty {
                alertToastModel.toast = AlertToast(displayMode: .hud, type: .complete(Color.green), title: "发布成功")
                showPostSheet.toggle()
                team.refresh(user: user)
            } else {
                alertToastModel.toast = AlertToast(displayMode: .hud, type: .error(Color.red), title: "发布失败", subTitle: result)
            }
        }
    }
}

struct TeamBulletinEntryView: View {
    var bulletin: TeamBulletinBoardEntry
    var member: TeamMember
    
    @State private var expanded = false
    
    var body: some View {
        HStack {
            CachedAsyncImage(url: URL(string: member.avatar)) { image in
                image
                    .resizable()
                    .cornerRadius(5)
                    .aspectRatio(contentMode: .fit)
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
                .font(.caption)
                Divider()
                Text(bulletin.content)
                    .font(.body)
                    .lineLimit(expanded ? nil : 1)
                Spacer()
            }
        }
        .onTapGesture {
            withAnimation {
                expanded.toggle()
            }
        }
    }
}

struct TeamBulletinPostSheet: View {
    let username: String
    let onCancel: () -> Void
    let onPost: (String) -> Void
    
    @State private var message = ""
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                TextEditor(text: $message)
                    .autocorrectionDisabled(true)
                    .multilineTextAlignment(.leading)
                    .autocapitalization(.none)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .focused($isFocused, equals: true)
                Spacer()
                Text("将以\(username)的身份发布，请文明发言")
                    .font(.callout)
                    .foregroundStyle(Color.secondary)
            }
            .padding()
            .navigationBarTitle("发表留言")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        onPost(message)
                    } label: {
                        Text("提交")
                    }
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        message = ""
                        onCancel()
                    } label: {
                        Text("取消")
                    }
                }
            }
            .onAppear {
                isFocused = true
            }
        }
    }
}
