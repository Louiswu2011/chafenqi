//
//  InfoChunithmTrophyList.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/7/24.
//

import SwiftUI

struct InfoChunithmTrophyList: View {
    var list = [UserChunithmTrophyEntry]()
    let typeStrings = [
        "normal": "普通称号",
        "copper": "铜称号",
        "silver": "银称号",
        "gold": "金称号",
        "platinum": "白金称号"
    ]
    
    @State var group = [String: [UserChunithmTrophyEntry]]()
    
    var body: some View {
        Form {
            ForEach(Array(group.keys).sorted(by: { $0.chunithmTrophySignificance < $1.chunithmTrophySignificance }), id: \.hashValue) { key in
                Section {
                    ForEach(group[key]!, id: \.name) { trophy in
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
                    Text("\(typeStrings[key] ?? "普通") 共\(group[key]?.count ?? 0)个")
                }
            }
        }
        .onAppear {
            group = Dictionary(grouping: list, by: {
                $0.type
            })
        }
        .navigationTitle("称号一览")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InfoChunithmTrophyList_Previews: PreviewProvider {
    static var previews: some View {
        InfoChunithmTrophyList()
    }
}
