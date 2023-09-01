//
//  PerkSheetView.swift
//  chafenqi
//
//  Created by xinyue on 2023/6/26.
//

import SwiftUI

struct PerkSheetView: View {
    @State private var selection = ""
    @State private var title = ""
    @State private var description = ""
    
    let names = ["playerinfo", "delta", "history"]
    let altNames = ["alt_playerinfo", "alt_delta", ""]
    
    var body: some View {
        VStack {
            TabView(selection: $selection) {
                ForEach(Array(names.enumerated()), id: \.offset) { index, name in
                    PerkCardView(name: name, altName: altNames[index])
                        .tag(name)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .automatic))
            
            VStack(alignment: .center) {
                Text(title)
                    .bold()
                    .font(.system(size: 20))
                    .padding(.bottom)
                Text(description)
                    .multilineTextAlignment(.center)
                    .padding([.bottom, .horizontal])
                
            }
        }
        .onAppear {
            selection = "playerinfo"
        }
        .onChange(of: selection) { newValue in
            withAnimation {
                switch selection {
                case "delta":
                    title = perks_delta_title
                    description = perks_delta_description
                case "history":
                    title = perks_history_title
                    description = perks_history_description
                case "playerinfo":
                    title = perks_playerInfo_title
                    description = perks_playerInfo_description
                default:
                    break
                }
            }
        }
    }
}

struct PerkCardView: View {
    var name: String
    var altName: String
    
    @State private var flipped = false
    
    var body: some View {
        ZStack {
            Image(flipped ? altName : name)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .mask(RoundedRectangle(cornerRadius: 15))
                .shadow(radius: 5)
                .padding(30)
                .rotation3DEffect(flipped ? Angle(degrees: 180) : Angle(degrees: 0), axis: (x: CGFloat(0), y: CGFloat(-1), z: CGFloat(0)))
                .onTapGesture {
                    if !altName.isEmpty {
                        withAnimation {
                            flipped.toggle()
                        }
                    }
                }
        }
        .rotation3DEffect(flipped ? Angle(degrees: 180) : Angle(degrees: 0), axis: (x: CGFloat(0), y: CGFloat(-1), z: CGFloat(0)))
    }
}

struct PerkSheetView_Previews: PreviewProvider {
    static var previews: some View {
        PerkSheetView()
    }
}
