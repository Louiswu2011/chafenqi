//
//  DeltaListView.swift
//  chafenqi
//
//  Created by xinyue on 2023/5/29.
//

import SwiftUI

struct DeltaListView: View {
    @ObservedObject var user = CFQNUser()
    
    @State var deltaCount = 0
    @State var playCount = 0
    @State var avgPlayCount: Double = 0
    @State var avgRatingGrowth: Double = 0
    
    var body: some View {
        ScrollView {
            HStack(spacing: 10) {
                VStack(alignment: .leading) {
                    Text("上传次数")
                    Text("\(deltaCount)")
                        .font(.system(size: 25))
                        .bold()
                }
                VStack(alignment: .leading) {
                    Text("游玩次数")
                    Text("\(playCount)")
                        .font(.system(size: 25))
                        .bold()
                }
                Spacer()
                VStack(alignment: .trailing) {
                    Text("估算花费")
                    Text("¥\(playCount * 2)")
                        .font(.system(size: 25))
                        .bold()
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 5)
            HStack(spacing: 10) {
                VStack(alignment: .leading) {
                    Text("平均游玩次数")
                    Text("\(avgPlayCount)")
                        .font(.system(size: 20))
                }
                VStack(alignment: .leading) {
                    Text("近7次Rating平均增长")
                    Text("\(avgRatingGrowth)")
                        .font(.system(size: 20))
                }
                Spacer()
            }
            .padding([.horizontal, .bottom])
            HStack {
                Text("出勤记录")
                    .font(.system(size: 18))
                    .bold()
                Spacer()
                Text("收起")
            }
            .padding(.horizontal)
            if user.currentMode == 0 && user.chunithm.delta.count > 2 {
                DeltaList(user: user, chuDelta: user.chunithm.delta)
            } else if user.currentMode == 1 && user.maimai.delta.count > 2 {
                DeltaList(user: user, maiDelta: user.maimai.delta)
            } else {
                DeltaList(user: user)
            }
            
        }
        .onAppear {
            loadVar()
        }
        .navigationTitle("上传记录")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func loadVar() {
        if user.currentMode == 0 {
            let latest7 = user.chunithm.delta.suffix(7)
            
            deltaCount = user.chunithm.delta.count
            playCount = user.chunithm.info.playCount
            avgPlayCount = Double(playCount) / Double(deltaCount)
            if let latest = latest7.last {
                if let first = latest7.first {
                    avgRatingGrowth = (latest.rating - first.rating) / Double(latest7.count)
                }
            }
        } else if user.currentMode == 1 {
            let latest7 = user.maimai.delta.suffix(7)
            
            deltaCount = user.maimai.delta.count
            playCount = user.maimai.info.playCount
            avgPlayCount = Double(playCount) / Double(deltaCount)
            if let latest = latest7.last {
                if let first = latest7.first {
                    avgRatingGrowth = Double(latest.rating - first.rating) / Double(latest7.count)
                }
            }
        }
    }
}

struct DeltaList: View {
    @ObservedObject var user: CFQNUser
    
    @State var chuDelta: CFQChunithmDeltaEntries?
    @State var maiDelta: CFQMaimaiDeltaEntries?
    
    var body: some View {
        VStack {
            if let deltas = chuDelta {
                ForEach(Array(deltas.enumerated()), id: \.offset) { index, value in
                    NavigationLink {
                        DeltaDetailView(user: user, deltaIndex: index)
                    } label: {
                        HStack {
                            Text(value.createdAt)
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                    }
                }
            } else if let deltas = maiDelta {
                ForEach(Array(deltas.enumerated()), id: \.offset) { index, value in
                    NavigationLink {
                        DeltaDetailView(user: user, deltaIndex: index)
                    } label: {
                        HStack {
                            Text(value.createdAt)
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                    }
                }
            } else {
                HStack(alignment: .center) {
                    Text("上传次数不足\n请先上传两次以上")
                        .multilineTextAlignment(.center)
                }
            }
        }
        .padding()
    }
}

struct DeltaListView_Previews: PreviewProvider {
    static var previews: some View {
        DeltaListView()
    }
}
