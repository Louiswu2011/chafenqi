//
//  InfoSkillList.swift
//  chafenqi
//
//  Created by xinyue on 2023/6/7.
//

import SwiftUI

struct InfoSkillList: View {
    var skills: [UserChunithmSkillEntry]
    
    var body: some View {
        Form {
            ForEach(skills, id: \.name) { skill in
                InfoSkillItem(skill: skill)
            }
        }
        .navigationTitle("技能列表")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InfoSkillItem: View {
    @Environment(\.managedObjectContext) var context
    var skill: UserChunithmSkillEntry
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: skill.url)!, context: context, placeholder: {
                ProgressView()
            }, image: { img in
                Image(uiImage: img)
                    .resizable()
            })
            .aspectRatio(1, contentMode: .fit)
            .frame(width: 50)
            
            VStack(alignment: .leading) {
                Text(skill.name)
                // Spacer()
                Text(skill.description)
                    .font(.system(size: 10))
                    .lineLimit(3)
            }
            Spacer()
            VStack {
                Text("等级")
                Text("\(skill.level)")
                    .font(.system(size: 16))
                    .bold()
            }
        }
        .frame(height: 60)
    }
}

