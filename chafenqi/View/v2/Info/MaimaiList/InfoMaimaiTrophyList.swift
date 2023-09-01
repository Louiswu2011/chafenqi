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
    
    let typeStrings = [
        "NORMAL": "普通称号",
        "BRONZE": "铜称号",
        "SILVER": "银称号",
        "GOLD": "金称号",
        "RAINBOW": "彩虹称号"
    ]
    
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
                    Text("\(typeStrings[type] ?? "普通称号") 共\(group[type]?.count ?? 0)个")
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
