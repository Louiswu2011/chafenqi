//
//  InfoCharacterList.swift
//  chafenqi
//
//  Created by xinyue on 2023/6/14.
//

import SwiftUI

struct InfoMaimaiCharacterList: View {
    var list: [UserMaimaiCharacterEntry]
    
    @State var group = [String: [UserMaimaiCharacterEntry]]()
    
    var body: some View {
        Form {
            ForEach(Array(group.keys).sorted(), id: \.hashValue) { area in
                Section {
                    ForEach(group[area]!, id: \.url) { char in
                        InfoMaimaiCharacterEntry(char: char)
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


struct InfoMaimaiCharacterEntry: View {
    @Environment(\.managedObjectContext) var context
    var char: UserMaimaiCharacterEntry
    
    @State var image = UIImage()
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: char.url)!, context: context, placeholder: {
                ProgressView()
            }, image: { img in
                let _ = DispatchQueue.main.async {
                    self.image = img
                }
                Image(uiImage: img)
                    .resizable()
            })
            .aspectRatio(contentMode: .fit)
            .mask(RoundedRectangle(cornerRadius: 5))
            .frame(width: 60, height: 60)
            .contextMenu {
                Button {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                } label: {
                    Label("保存到相册", systemImage: "square.and.arrow.down")
                }
            }
            VStack {
                HStack {
                    Text(char.name)
                        .bold()
                    Spacer()
                    Text("\(char.level)")
                }
            }
        }
    }
}
