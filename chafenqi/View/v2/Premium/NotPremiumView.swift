//
//  NotPremiumView.swift
//  chafenqi
//
//  Created by xinyue on 2023/7/7.
//

import SwiftUI

struct NotPremiumView: View {
    
    var body: some View {
        VStack {
            // Placeholder image for premium icon
            Image("Icon")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.blue)
                .frame(width: 60)
                .mask(RoundedRectangle(cornerRadius: 10))
                .padding(.top)
            Text("查分器PRO")
                .bold()
                .font(.title)
                .padding(.bottom, 5)
            Text("订阅即可解锁以下功能")
                .font(.title2)
                .padding(.bottom, 25)
            
            ScrollView {
                VStack(spacing: 17) {
                    PremiumInfoBlock(
                        imageSystemName: "person.crop.square",
                        title: "详细个人信息",
                        message: "全面查看各难度等级完成度、已获得的收藏品和人物立绘")
                    
                    PremiumInfoBlock(
                        imageSystemName: "chart.bar.xaxis",
                        title: "单曲历史成绩图表",
                        message: "查询和比较单曲的游玩成绩信息")
                    
                    PremiumInfoBlock(
                        imageSystemName: "clock.arrow.circlepath",
                        title: "出勤记录",
                        message: "精确到每日的出勤详细记录、数据变化和趋势分析")
                    
                    PremiumInfoBlock(
                        imageSystemName: "wrench.and.screwdriver.fill",
                        title: "小组件自定义",
                        message: "用已获得的角色、称号、底板等装饰桌面小组件")
                    
                    PremiumInfoBlock(
                        imageSystemName: "ellipsis",
                        title: "更多功能",
                        message: "不定期加入的PRO限定功能")
                }
            }
            .padding(.horizontal, 50)
            
            Spacer()

            Link(destination: URL(string: "https://afdian.net/a/chafenqi")!) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        
                    Text("前往订阅")
                        .font(.system(size: 18))
                        .foregroundColor(.white)
                }
            }
            .frame(height: 50)
            .padding([.horizontal, .bottom])
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .analyticsScreen(name: "promotion_screen")
    }
}

struct PremiumInfoBlock: View {
    var imageSystemName: String
    var title: String
    var message: String
    var foregroundColor: Color = .blue
    
    var body: some View {
        HStack {
            Image(systemName: imageSystemName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 40)
                .foregroundColor(.blue)
                .padding(.trailing, 8)
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.title3)
                    .bold()
                Text(message)
            }
            Spacer()
        }
    }
}

struct NotPremiumView_Previews: PreviewProvider {
    static var previews: some View {
        NotPremiumView()
    }
}
