//
//  ModalView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/24.
//

import SwiftUI

struct ModalView<T: View>: UIViewControllerRepresentable {
    let view: T
    let isModal: Bool
    let onDismissalAttempt: (()->())?
    
    func makeUIViewController(context: Context) -> UIHostingController<T> {
        UIHostingController(rootView: view)
    }
    
    func updateUIViewController(_ uiViewController: UIHostingController<T>, context: Context) {
        context.coordinator.modalView = self
        uiViewController.rootView = view
        uiViewController.parent?.presentationController?.delegate = context.coordinator
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIAdaptivePresentationControllerDelegate {
        var modalView: ModalView
        
        init(_ modalView: ModalView) {
            self.modalView = modalView
        }
        
        func presentationControllerShouldDismiss(_ presentationController: UIPresentationController) -> Bool {
            !modalView.isModal
        }
        
        func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
            modalView.onDismissalAttempt?()
        }
    }
}

extension View {
    func presentation(isModal: Bool, onDismissalAttempt: (()->())? = nil) -> some View {
        ModalView(view: self, isModal: isModal, onDismissalAttempt: onDismissalAttempt)
    }
}
