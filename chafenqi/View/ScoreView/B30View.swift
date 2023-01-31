//
//  B30View.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/1/26.
//

import SwiftUI

struct B30View: View {
    var body: some View {
        NavigationView {
            VStack {
                Text("Hellp")
                Text("Hellp")
                Text("Hellp")
                
                List {
                    Text("a")
                    Text("a")
                    Text("a")
                    Text("a")
                }
            }
        }
    }
}

struct B30View_Previews: PreviewProvider {
    static var previews: some View {
        B30View()
    }
}
