//
//  TeamActivityView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2024/12/25.
//

import Foundation
import SwiftUI
import CachedAsyncImage

struct TeamActivityView: View {
    @ObservedObject var team: CFQTeam
    
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack {
                ForEach(team.current.activities.sorted(by: { $0.timestamp > $1.timestamp }), id: \.id) { activity in
                    if let member = team.current.members.first(where: { $0.userId == activity.userId }) {
                        TeamActivityEntryView(activity: activity, member: member)
                    }
                }
            }
        }
    }
}

struct TeamActivityEntryView: View {
    var activity: TeamActivity
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
            .frame(width: 60, height: 60)
            
            VStack(alignment: .leading) {
                Text(try! AttributedString(markdown: "**\(member.nickname.transformingHalfwidthFullwidth())** \(activity.activity)"))
                    .lineLimit(2)
                Spacer()
                HStack {
                    Spacer()
                    Text(DateTool.ymdhmsDateString(from: TimeInterval(activity.timestamp)))
                        .font(.caption)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: 60)
        .padding(.horizontal)
    }
}
