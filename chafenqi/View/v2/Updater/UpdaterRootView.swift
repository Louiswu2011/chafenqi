//
//  UpdaterRootView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/5/8.
//

import SwiftUI

struct UpdaterRootView: View {
    @ObservedObject var user: CFQNUser
    @ObservedObject var service = TunnelManagerService.shared
    
    
    var body: some View {
        VStack {
            if (service.manager != nil) {
                UpdaterView(user: user)
            } else {
                UpdaterWelcomeView()
            }
        }
        .onAppear {
            loadProfileFromDevice()
        }
        .navigationTitle("传分")
        .navigationBarTitleDisplayMode(.inline)
        
    }
    
    func loadProfileFromDevice() {
        service.loadProfile { result in
            switch result {
            case .success():
                print("[Updater] Profile Loaded.")
            case .failure(let error):
                print(error)
            }
        }
    }
}

struct UpdaterRootView_Previews: PreviewProvider {
    static var previews: some View {
        UpdaterRootView(user: CFQNUser())
    }
}


