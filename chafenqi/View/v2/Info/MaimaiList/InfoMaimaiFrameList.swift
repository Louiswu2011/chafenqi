//
//  InfoMaimaiFrameList.swift
//  chafenqi
//
//  Created by xinyue on 2023/6/14.
//

import SwiftUI

struct InfoMaimaiFrameList: View {
    @Environment(\.managedObjectContext) var context
    var list: [CFQMaimai.ExtraEntry.FrameEntry]
    
    @State var group = [String: [CFQMaimai.ExtraEntry.FrameEntry]]()
    
    var body: some View {
        Form {
            ForEach(Array(group.keys).sorted(), id: \.hashValue) { area in
                Section {
                    ForEach(group[area]!, id: \.image) { frame in
                        VStack {
                            AsyncImage(url: URL(string: frame.image)!, context: context, placeholder: {
                                ProgressView()
                            }, image: { img in
                                Image(uiImage: img)
                                    .resizable()
                                
                            })
                            .aspectRatio(contentMode: .fit)
                            Text(frame.name)
                                .bold()
                            Text(frame.description)
                        }
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
