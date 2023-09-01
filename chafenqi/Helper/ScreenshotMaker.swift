//
//  ScreenshotMaker.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/8/3.
//

import Foundation
import CoreData
import SwiftUI
import UIKit

typealias ScreenshotMakerClosure = (ScreenshotMaker) -> Void

struct ScreenshotMakerView: UIViewRepresentable {
    let closure: ScreenshotMakerClosure
    
    init(_ closure: @escaping ScreenshotMakerClosure) {
        self.closure = closure
    }
    
    func makeUIView(context: Context) -> ScreenshotMaker {
        let view = ScreenshotMaker(frame: .zero)
        return view
    }
    
    func updateUIView(_ uiView: ScreenshotMaker, context: Context) {
        DispatchQueue.main.async {
            closure(uiView)
        }
    }
}

class ScreenshotMaker: UIView {
    func screenshot() -> UIImage? {
        guard let containerView = self.superview?.superview,
              let containerSuperview = containerView.superview else { return nil }
        let renderer = UIGraphicsImageRenderer(bounds: containerView.frame)
        return renderer.image { (context) in
            containerSuperview.backgroundColor = .white
            containerSuperview.layer.render(in: context.cgContext)
        }
    }
}

extension View {
    func snapshotSelf() -> UIImage {
        return snapshot(self)
    }
    
    func snapshotWithContext(_ context: NSManagedObjectContext) -> UIImage {
        return snapshot(self.environment(\.managedObjectContext, context))
    }
    
    func snapshot(_ view: some View) -> UIImage {
        let controller = UIHostingController(rootView: view)
        let view = controller.view
        
        let targetSize = controller.view.intrinsicContentSize
        let bounds = CGRect(origin: .zero, size: targetSize)
        
        view?.bounds = bounds
        view?.backgroundColor = .clear
        
        let window = UIWindow(frame: bounds)
        window.rootViewController = controller
        window.makeKeyAndVisible()
        
        let image = controller.view.asImage()
        controller.view.removeFromSuperview()
        return image
    }
    
    func screenshotView(_ closure: @escaping ScreenshotMakerClosure) -> some View {
        let screenshotView = ScreenshotMakerView(closure)
        return overlay(screenshotView.allowsHitTesting(false))
    }
}

extension UIView {
    func asImage() -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { context in
            layer.render(in: context.cgContext)
        }
    }
}
