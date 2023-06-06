//
//  HomeDelta.swift
//  chafenqi
//
//  Created by xinyue on 2023/6/1.
//

import SwiftUI

struct HomeDelta: View {
    @ObservedObject var user = CFQNUser()
    
    var body: some View {
        VStack {
            HStack {
                Text("出勤记录")
                    .font(.system(size: 20))
                    .bold()
                Spacer()
                
                NavigationLink {
                    DeltaListView(user: user)
                } label: {
                    Text("显示全部")
                        .font(.system(size: 18))
                }
            }
        }
        .padding()
    }
}

struct HomeDelta_Previews: PreviewProvider {
    static var previews: some View {
        HomeDelta()
    }
}
