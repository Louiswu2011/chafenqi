//
//  UpdaterMainView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/8.
//

import SwiftUI
import AlertToast

struct UpdaterRouterView: View {
    @ObservedObject var user: CFQUser
    @ObservedObject var service = TunnelManagerService.shared
    
    var body: some View {
        VStack {
            if (service.manager != nil) {
                UpdaterMainView(user: user)
            } else {
                UpdaterWelcomeView()
            }
        }
        .onAppear {
            loadProfileFromDevice()
        }
        .navigationTitle("国服更新器")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func loadProfileFromDevice() {
        service.loadProfile { result in
            switch result {
            case .success():
                print("Loaded")
            case .failure(let error):
                print(error)
            }
        }
    }
}

struct UpdaterRouterView_Previews: PreviewProvider {
    static var previews: some View {
        UpdaterRouterView(user: CFQUser())
    }
}
