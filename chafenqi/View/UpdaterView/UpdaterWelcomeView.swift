//
//  UpdaterWelcomeView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/8.
//

import SwiftUI

struct UpdaterWelcomeView: View {
    @ObservedObject var service = TunnelManagerService.shared
    
    @State var isInstalling = false
    
    var body: some View {
        VStack {
            Text("首次使用请安装VPN描述文件")
                .font(.title2)
                .bold()
                .padding()
            
            if(isInstalling) {
                ProgressView()
            } else {
                Button {
                    installProfileToDevice()
                } label: {
                    Text("安装")
                }
                .buttonStyle(.automatic)
            }
        }
    }
    
    func installProfileToDevice() {
        isInstalling = true
        
        service.installProfile { result in
            switch result {
            case .success():
                isInstalling = false
            case .failure(let error):
                print(error)
                isInstalling = false
            }
        }
    }
}

struct UpdaterWelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        UpdaterWelcomeView()
    }
}
