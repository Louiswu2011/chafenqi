//
//  TeamLeaderboardPage.swift
//  chafenqi
//
//  Created by Louis Wu on 2025/01/03.
//

import Foundation
import SwiftUI
import Inject

struct TeamLeaderboardPage: View {
    @ObserveInjection var inject
    
    @ObservedObject var team: CFQTeam
    @ObservedObject var user: CFQNUser
    
    @State private var showHelpSheet: Bool = false
    
    let currentDate = Date.now
    
    var body: some View {
        let dateComponents = Calendar(identifier: .gregorian).dateComponents([.year, .month], from: currentDate)
        let start = DateTool.shared.yyyymmddTransformer.string(from: Date().startOfMonth)
        let end = DateTool.shared.yyyymmddTransformer.string(from: Date().endOfMonth)
        VStack {
            if team.isLoading {
                ProgressView()
            } else {
                VStack {
                    Text(verbatim: "\(dateComponents.year ?? 2025) 第\(dateComponents.month ?? 1)赛季")
                        .bold()
                    Text("\(start) ~ \(end)")
                        .font(.footnote)
                    Text("当前暂无进行中的活动")
                        .font(.footnote)
                        .padding(.top, 5)
                }
                Divider()
                ScrollView {
                    LazyVStack {
                        ForEach(Array(zip(team.sortedList.indices, team.sortedList)), id: \.0) { index, team in
                            TeamLeaderboardEntry(team: team, rank: index + 1)
                        }
                    }
                }
            }
        }
        .enableInjection()
        .navigationTitle("团队排行榜")
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            withAnimation {
                team.refresh(user: user)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showHelpSheet.toggle()
                } label: {
                    Image(systemName: "questionmark.circle")
                }
            }
        }
        .sheet(isPresented: $showHelpSheet) {
            TeamLeaderboardHelpView(showHelpSheet: $showHelpSheet)
        }
    }
}

struct TeamLeaderboardEntry: View {
    let team: TeamBasicInfo
    let rank: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("#\(rank)")
                    .if(rank <= 3) { text in
                        text.bold()
                    }
                    .if(rank == 1) { text in
                        text.foregroundColor(leaderboardGoldColor)
                    }
                    .if(rank == 2) { text in
                        text.foregroundColor(leaderboardSilverColor)
                    }
                    .if(rank == 3) { text in
                        text.foregroundColor(leaderboardBronzeColor)
                    }
                Text(team.displayName)
                    .if(rank <= 3) { text in
                        text.bold()
                    }
                    .lineLimit(1)
                Spacer()
                Text(team.currentActivityPoints > 0 ? "\(team.currentActivityPoints)Pt" : "暂未参加")
            }
            Text("\(team.remarks)")
                .font(.footnote)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }
}

struct TeamLeaderboardHelpView: View {
    @Binding var showHelpSheet: Bool
    
    var body: some View {
        VStack {
            Text("团队排行榜帮助")
                .font(.title)
            
            Spacer()
            
            VStack(spacing: 30) {
                IconWithInfoBlock(imageSystemName: "paperplane", title: "游玩并上传成绩", message: "加入团队后，在机台上游玩任意曲目并上传，即可为团队累计积分")
                IconWithInfoBlock(imageSystemName: "calendar", title: "积分赛季", message: "团队积分以月份为周期进行统计，每月1号将重置积分")
                IconWithInfoBlock(imageSystemName: "rosette", title: "赛季内活动", message: "赛季内将不定期举办团队积分活动，详情可参考排行榜页面")
                IconWithInfoBlock(imageSystemName: "info.circle", title: "关于积分", message: "成功上传后，可获得的积分由本次游玩曲目数和游玩成绩相关")
            }
            
            Spacer()
            
            Button {
                showHelpSheet.toggle()
            } label: {
                Text("关闭")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .enableInjection()
    }
}

struct IconWithInfoBlock: View {
    var imageSystemName: String
    var title: String
    var message: String
    var foregroundColor: Color = .blue
    
    var body: some View {
        HStack {
            Image(systemName: imageSystemName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30)
                .foregroundColor(.blue)
                .padding(.trailing, 8)
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .bold()
                Text(message)
            }
            Spacer()
        }
    }
}
