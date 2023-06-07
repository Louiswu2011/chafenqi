//
//  InfoCharacterList.swift
//  chafenqi
//
//  Created by xinyue on 2023/6/7.
//

import SwiftUI

struct InfoCharacterList: View {
    var characters: [CFQChunithm.ExtraEntry.CharacterEntry]
    
    var body: some View {
        Form {
            ForEach(characters, id: \.name) { char in
                InfoCharacterItem(character: char)
            }
        }
        .navigationTitle("角色列表")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InfoCharacterItem: View {
    @Environment(\.managedObjectContext) var context
    var character: CFQChunithm.ExtraEntry.CharacterEntry
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: character.url)!, context: context, placeholder: {
                ProgressView()
            }, image: { img in
                Image(uiImage: img)
                    .resizable()
            })
            .aspectRatio(1 ,contentMode: .fit)
            .mask(RoundedRectangle(cornerRadius: 5))
            .frame(width: 50)
            
            VStack {
                HStack {
                    Text(character.name)
                        .lineLimit(1)
                    Spacer()
                    if character.current == 1 {
                        Text("当前角色")
                    }
                    Text("LV \(character.rank)")
                }
                Spacer()
                ProgressView(value: character.exp)
            }
            .padding(.vertical, 5)
        }
        .frame(height: 60)
    }
}
