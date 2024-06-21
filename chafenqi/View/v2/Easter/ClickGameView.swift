//
//  ClickGameView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/7/29.
//

import SwiftUI

struct ClickGameView: View {
    @GestureState private var isTouching = false
    
    @State private var clickCount = 0
    @State private var size: CGFloat = 40
    
    @State private var durations: [TimeInterval] = []
    @State private var duration: TimeInterval = .infinity
    @State private var minimumDuration: TimeInterval = .infinity
    @State private var maximumSpeed: TimeInterval = 0
    @State private var avgDuration: TimeInterval = .infinity
    @State private var previousInstant: TimeInterval = 0
    
    var minimumClickToActivate = 16
    
    var body: some View {
        ZStack {
            Color.orange
            
            VStack {
                HStack(alignment: .lastTextBaseline) {
                    Text("打了")
                    Text("\(clickCount)")
                        .bold()
                        .font(.system(size: size))
                        .padding(.bottom, 30)
                    Text("次交")
                }
                HStack(spacing: 80) {
                    VStack(spacing: 10) {
                        Text("当前")
                        Text("\(getCurrentSpeed(), specifier: "%.0f")")
                            .bold()
                        Text("BPM下的16分交")
                            .font(.system(size: 12))
                    }
                    VStack(spacing: 10) {
                        Text("最高")
                        Text("\(maximumSpeed, specifier: "%.0f")")
                            .bold()
                        Text("BPM下的16分交")
                            .font(.system(size: 12))
                    }
                }
                .padding(.horizontal, 30)
                Button {
                    fatalError("Crashed by design.")
                } label: {
                    Text("别按我")
                }
                .padding(.top)
            }
        }
        .simultaneousGesture(
            LongPressGesture(minimumDuration: .leastNonzeroMagnitude)
            .updating($isTouching) { current, state, transaction in
                onTouchDown()
            }
        )
        .edgesIgnoringSafeArea(.all)
        .navigationTitle("现在开始打交")
        .navigationBarTitleDisplayMode(.inline)
        .analyticsScreen(name: "easter_egg_screen")
    }
    
    func onTouchDown() {
        DispatchQueue.main.async {
            clickCount += 1
            withAnimation(.interactiveSpring()) {
                size = min(120, size * 1.01)
            }
            
            let currentInstant = Date().timeIntervalSince1970
            duration = clickCount <= 1 ? .infinity : currentInstant - previousInstant
            previousInstant = currentInstant
            
            if clickCount > 1 && duration > 5 {
                resetStats()
            } else {
                minimumDuration = min(duration, minimumDuration)
                
                if clickCount >= minimumClickToActivate {
                    maximumSpeed = max(getCurrentSpeed(), maximumSpeed)
                }
                if clickCount > 1 {
                    durations.append(duration)
                    avgDuration = durations.reduce(0) { $0 + $1 } / Double(durations.count)
                }
            }
        }
    }
    
    func getCurrentSpeed() -> Double {
        let slice = durations.suffix(minimumClickToActivate)
        return slice.count < minimumClickToActivate ? 0 : 15 / (slice.reduce(0) { $0 + $1 } / Double(slice.count))
    }
    
    func resetStats() {
        size = 40
        durations = []
        clickCount = 0
        duration = .infinity
        minimumDuration = .infinity
        maximumSpeed = 0
        avgDuration = .infinity
        previousInstant = 0
    }
}

struct ClickGameView_Previews: PreviewProvider {
    static var previews: some View {
        ClickGameView()
    }
}
