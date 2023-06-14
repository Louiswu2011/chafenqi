//
//  CharacterCapsule.swift
//  chafenqi
//
//  Created by xinyue on 2023/6/14.
//

import SwiftUI
import ColorKit

struct CharacterCapsule: View {
    @Environment(\.managedObjectContext) var context
    @State var imageURL: String
    @State var level: String
    
    @State var dominantColors: [UIColor] = []
    @State var didLoad = false
    
    var body: some View {
        VStack {
            ZStack {
                Capsule()
                    .foregroundColor(didLoad ? Color(uiColor: dominantColors[2]).opacity(0.6) : .clear)
                    .frame(width: 80, height: 125)
                VStack {
                    AsyncImage(url: URL(string: imageURL)!, context: context, placeholder: {
                        ProgressView()
                    }, image: { img in
                        let _ = DispatchQueue.main.async {
                            loadImage(img: img)
                        }
                        Image(uiImage: img)
                            .resizable()
                    })
                    .background(
                        Circle()
                            .foregroundColor(didLoad ? Color(uiColor: dominantColors[1]).opacity(0.8) : .clear)
                            .frame(width: 70, height: 70)
                    )
                    .mask(Circle())
                    .frame(width: 70, height: 70)
                    .padding(.top, 5)
                    Spacer()
                    Text(level)
                        .bold()
                        .padding(.bottom, 20)
                }
            }
        }
        .frame(width: 80, height: 125)
    }
    
    func loadImage(img: UIImage) {
        do {
            dominantColors = try img.dominantColors()
        } catch {
            dominantColors = [UIColor.clear]
        }
        didLoad = true
    }
}

extension UIColor {
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        return (red, green, blue, alpha)
    }
}

extension Color {
    init(uiColor: UIColor) {
        self.init(red: Double(uiColor.rgba.red),
                  green: Double(uiColor.rgba.green),
                  blue: Double(uiColor.rgba.blue),
                  opacity: Double(uiColor.rgba.alpha))
    }
}

extension Shape {
    /// fills and strokes a shape
    public func fill<S:ShapeStyle>(
        _ fillContent: S,
        stroke       : StrokeStyle
    ) -> some View {
        ZStack {
            self.fill(fillContent)
            self.stroke(style:stroke)
        }
    }
}
