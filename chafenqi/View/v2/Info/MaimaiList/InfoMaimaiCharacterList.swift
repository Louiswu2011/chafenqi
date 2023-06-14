//
//  InfoCharacterList.swift
//  chafenqi
//
//  Created by xinyue on 2023/6/14.
//

import SwiftUI

struct InfoMaimaiCharacterList: View {
    @Environment(\.managedObjectContext) var context
    var list: [CFQMaimai.ExtraEntry.CharacterEntry]
    
    @State var group = [String: [CFQMaimai.ExtraEntry.CharacterEntry]]()
    
    var body: some View {
        Form {
            ForEach(Array(group.keys).sorted(), id: \.hashValue) { area in
                Section {
                    ForEach(group[area]!, id: \.image) { char in
                        HStack {
                            AsyncImage(url: URL(string: char.image)!, context: context, placeholder: {
                                ProgressView()
                            }, image: { img in
                                Image(uiImage: img)
                                    .resizable()
                            })
                            .aspectRatio(contentMode: .fit)
                            .mask(RoundedRectangle(cornerRadius: 5))
                            .frame(width: 60, height: 60)
                            
                            VStack {
                                HStack {
                                    Text(char.name)
                                        .bold()
                                    Spacer()
                                    Text(char.level)
                                }
                            }
                        }
                    }
                } header: {
                    Text(area)
                }
            }
        }
        .navigationTitle("角色一览")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            group = Dictionary(grouping: list, by: {
                $0.area
            })
        }
    }
}
