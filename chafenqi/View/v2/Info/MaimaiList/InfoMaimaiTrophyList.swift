//
//  InfoMaimaiTrophyList.swift
//  chafenqi
//
//  Created by xinyue on 2023/6/14.
//

import SwiftUI

struct InfoMaimaiTrophyList: View {
    @Environment(\.managedObjectContext) var context
    var list: [CFQMaimai.ExtraEntry.TrophyEntry]
    
    @State var group = [String: [CFQMaimai.ExtraEntry.TrophyEntry]]()
    
    var body: some View {
        Form {
            ForEach(Array(group.keys).sorted(by: { a, b in a.significance < b.significance }), id: \.hashValue) { type in
                Section {
                    ForEach(group[type]!, id: \.name) { trophy in
                        HStack {
                            Spacer()
                            VStack(alignment: .center) {
                                Text(trophy.name)
                                    .bold()
                                    .multilineTextAlignment(.center)
                                
                                Text(trophy.description)
                                    .multilineTextAlignment(.center)
                            }
                            Spacer()
                        }
                    }
                } header: {
                    Text(type)
                }
            }
            
        }
        .navigationTitle("称号一览")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            group = Dictionary(grouping: list, by: {
                $0.type
            })
        }
    }
}
