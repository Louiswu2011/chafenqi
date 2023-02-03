//
//  MaimaiHomeView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/2/3.
//

import SwiftUI
import AlertToast

struct MaimaiHomeView: View {
    @AppStorage("settingsCoverSource") var coverSource = 0
    @AppStorage("loadedMaimaiSongs") var loadedSongs: Data = Data()
    
    @AppStorage("userNickname") var accountNickname = ""
    @AppStorage("userAccountName") var accountName = ""
    @AppStorage("userToken") var token = ""
    @AppStorage("userInfoData") var userInfoData = Data()
    
    @AppStorage("didLogin") var didLogin = false
    
    private var rows = [
        GridItem(),
        GridItem()
    ]
    
    var body: some View {
        ZStack {
            
        }
    }
}


struct MaimaiHomeView_Previews: PreviewProvider {
    static var previews: some View {
        MaimaiHomeView()
    }
}
