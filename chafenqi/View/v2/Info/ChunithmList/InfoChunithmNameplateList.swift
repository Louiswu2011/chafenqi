//
//  InfoChunithmNameplateView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/7/24.
//

import SwiftUI

struct InfoChunithmNameplateList: View {
    @Environment(\.managedObjectContext) var context
    var list = [CFQChunithm.ExtraEntry.NameplateEntry]()
    
    @State private var image = [String: UIImage]()
    
    var body: some View {
        Form {
            Section {
                ForEach(list, id: \.url) { nameplate in
                    HStack {
                        Spacer()
                        VStack(alignment: .center) {
                            AsyncImage(url: URL(string: nameplate.url)!, context: context, placeholder: {
                                ProgressView()
                            }, image: { img in
                                let _ = DispatchQueue.main.async {
                                    self.image[nameplate.url] = img
                                }
                                Image(uiImage: img)
                                    .resizable()
                                
                            })
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 60)
                            .contextMenu {
                                Button {
                                    if let image = self.image[nameplate.url] {
                                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                                    }
                                } label: {
                                    Label("保存到相册", systemImage: "square.and.arrow.down")
                                }
                            }
                            Text(nameplate.name)
                                .bold()
                        }
                        Spacer()
                    }
                }
            } header: {
                Text("共\(list.count)个名牌版")
            }
        }
        .navigationTitle("名牌版一览")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct InfoChunithmNameplateList_Previews: PreviewProvider {
    static var previews: some View {
        InfoChunithmNameplateList()
    }
}
