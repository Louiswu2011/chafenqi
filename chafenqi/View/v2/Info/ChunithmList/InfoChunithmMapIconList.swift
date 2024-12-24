//
//  InfoChunithmMapIconList.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/8/31.
//

import SwiftUI

struct InfoChunithmMapIconList: View {
    var mapIcons: [UserChunithmMapIconEntry]
    
    var body: some View {
        Form {
            Section {
                ForEach(mapIcons, id: \.name) { mapIcon in
                    InfoChunithmMapIconItem(mapIcon: mapIcon)
                }
            } header: {
                Text("共\(mapIcons.count)个地图头像")
            }
        }
        .navigationTitle("地图头像列表")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InfoChunithmMapIconItem: View {
    @Environment(\.managedObjectContext) var context
    var mapIcon: UserChunithmMapIconEntry
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: mapIcon.url)!, context: context, placeholder: {
                ProgressView()
            }, image: { img in
                Image(uiImage: img)
                    .resizable()
            })
            .aspectRatio(contentMode: .fit)
            .frame(width: 50)
            
            Text(mapIcon.name)
                .lineLimit(1)
            
            Spacer()
            
            if mapIcon.current {
                Text("当前头像")
                    .bold()
            }
        }
        .frame(height: 60)
    }
}
