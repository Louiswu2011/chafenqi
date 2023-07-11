//
//  InfoMaimaiNameplateList.swift
//  chafenqi
//
//  Created by xinyue on 2023/6/14.
//

import SwiftUI

struct InfoMaimaiNameplateList: View {
    @Environment(\.managedObjectContext) var context
    var list: [CFQMaimai.ExtraEntry.NameplateEntry]
    
    @State private var image = UIImage()
    
    var body: some View {
        Form {
            ForEach(list, id: \.image) { nameplate in
                VStack {
                    AsyncImage(url: URL(string: nameplate.image)!, context: context, placeholder: {
                        ProgressView()
                    }, image: { img in
                        let _ = DispatchQueue.main.async {
                            self.image = img
                        }
                        Image(uiImage: img)
                            .resizable()
                            
                    })
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 60)
                    .contextMenu {
                        Button {
                            UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                        } label: {
                            Label("保存到相册", systemImage: "square.and.arrow.down")
                        }
                    }
                    Text(nameplate.name)
                        .bold()
                    Text(nameplate.description)
                }
            }
        }
        .navigationTitle("姓名框一览")
        .navigationBarTitleDisplayMode(.inline)
    }
}
