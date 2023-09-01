//
//  GradeBadgeView.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/3/22.
//

import SwiftUI

struct GradeBadgeView: View {
    @State var grade: String = "SSS+"
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 5)
                .foregroundColor(backgroundColor)

            if (grade == "SSS+") {
                RoundedRectangle(cornerRadius: 5)
                    .stroke(AngularGradient(gradient: Gradient(colors: [.red, .yellow, .green, .blue, .purple, .red]), center: .center), lineWidth: 2)
                    .foregroundColor(.clear)
            }
            
            HStack(spacing: 0) {
                Group {
                    Text(grade.replacingOccurrences(of: "+", with: ""))
                        .bold()
                    if (grade.contains("+")) {
                        Text("+")
                            .bold()
                            .font(.system(size: 15))
                            .padding(.bottom, 6)
                    }
                }
                .foregroundColor(foregroundColor)
            }
        }
        .frame(width: 55, height: 24)
    }
    
    var backgroundColor: Color {
        switch (grade) {
        case "SSS+", "SSS", "SS+", "SS", "S+", "S":
            return .yellow
        case "AAA":
            return Color(red: 191, green: 155, blue: 48)
        default:
            return .gray
        }
    }
    
    var foregroundColor: Color {
        switch (grade) {
        case "SSS+":
            return .black
        case "SSS", "SS+", "SS", "S+", "S":
            return .black
        case "AAA":
            return .black
        default:
            return .white
        }
    }
    
}

struct GradeBadgeView_Previews: PreviewProvider {
    static var previews: some View {
        GradeBadgeView()
    }
}
