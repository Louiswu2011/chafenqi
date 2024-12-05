//
//  InfoMaimaiFrameList.swift
//  chafenqi
//
//  Created by xinyue on 2023/6/14.
//

import SwiftUI

struct InfoMaimaiFrameList: View {
    @Environment(\.managedObjectContext) var context
    var list: [UserMaimaiFrameEntry]
    
    @State var group = [String: [UserMaimaiFrameEntry]]()
    
    var body: some View {
        Form {
            ForEach(Array(group.keys).sorted(), id: \.hashValue) { area in
                Section {
                    ForEach(group[area]!, id: \.url) { frame in
                        InfoMaimaiFrameEntry(frame: frame)
                    }
                } header: {
                    Text(area)
                }
            }
        }
        .navigationTitle("底板一览")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            group = Dictionary(grouping: list, by: {
                $0.area
            })
        }
    }
}

struct InfoMaimaiFrameEntry: View {
    @Environment(\.managedObjectContext) var context
    var frame: UserMaimaiFrameEntry
    
    @State var image = UIImage()
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: frame.url)!, context: context, placeholder: {
                ProgressView()
            }, image: { img in
                Image(uiImage: img)
                    .resizable()
                
            })
            .aspectRatio(contentMode: .fit)
            .contextMenu {
                Button {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                } label: {
                    Label("保存到相册", systemImage: "square.and.arrow.down")
                }
            }
            Text(frame.name)
                .bold()
            Text(frame.description)
        }
    }
}
