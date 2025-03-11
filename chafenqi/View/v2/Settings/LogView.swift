//
//  LogView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/9/4.
//

import SwiftUI

struct LogView: View {
    @State private var logger = Logger.shared
    
    var body: some View {
        List {
            ForEach(logger.getAllLogs().reversed(), id: \.timestamp) { log in
                VStack(alignment: .leading) {
                    Text(log.timestamp.toDateString(format: "yyyy-MM-dd HH:mm:ss") + " " + log.level.rawValue)
                        .foregroundColor(.gray)
                        .font(.system(size: 12))
                    Text(log.message)
                }
            }
        }
        .navigationTitle("调试输出")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct LogView_Previews: PreviewProvider {
    static var previews: some View {
        LogView()
    }
}
