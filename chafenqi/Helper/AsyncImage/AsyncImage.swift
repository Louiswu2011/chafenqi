//
//  AsyncImage.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/24.
//

import Foundation
import CoreData
import SwiftUI

struct AsyncImage<Placeholder: View>: View {
    @StateObject private var loader: ImageLoader
        private let placeholder: Placeholder
        private let image: (UIImage) -> Image
        
        init(
            url: URL,
            context: NSManagedObjectContext,
            @ViewBuilder placeholder: () -> Placeholder,
            @ViewBuilder image: @escaping (UIImage) -> Image = Image.init(uiImage:)
        ) {
            self.placeholder = placeholder()
            self.image = image
            _loader = StateObject(wrappedValue: ImageLoader(url: url, context: context))
        }
        
        var body: some View {
            content
                .onAppear(perform: loader.load)
        }
        
        private var content: some View {
            Group {
                if loader.image != nil {
                    image(loader.image!)
                } else {
                    placeholder
                        .padding()
                }
            }
        }
}
