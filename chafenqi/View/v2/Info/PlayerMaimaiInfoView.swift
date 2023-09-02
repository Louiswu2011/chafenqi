//
//  PlayerMaimaiInfoView.swift
//  chafenqi
//
//  Created by xinyue on 2023/6/7.
//

import SwiftUI
import SwiftUICharts

let maiRankHex = [
    Color(hex: 0xf4d941),
    Color(hex: 0xf6ca3a),
    Color(hex: 0xf6bc35),
    Color(hex: 0xf5ad33),
    Color(hex: 0xf39f32),
    Color(hex: 0xf09033),
    Color(hex: 0xec8235),
    Color(hex: 0xBF682A)
]
let maiStatusHex = [
    Color(hex: 0x6eee87),
    Color(hex: 0x69e473),
    Color(hex: 0x65da5e),
    Color(hex: 0x62cf47),
    Color(hex: 0x5fc52e)
]
let maiRankDesc = ["SSS+", "SSS", "SS+", "SS", "S+", "S", "其他"]
let maiStatusDesc = ["AP+", "AP", "FC+", "FC", "Clear"]

struct PlayerMaimaiInfoView: View {
    @Environment(\.managedObjectContext) var context
    @ObservedObject var user: CFQNUser
    
    @State private var currentLoadout: [CFQMaimaiExtraEntry.CharacterEntry] = []
    @State private var charImg = UIImage()
    @State private var nameplateImg = UIImage()
    @State private var frameImg = UIImage()
    
    var body: some View {
        ScrollView {
            if user.isPremium && !user.maimai.extra.nameplates.isEmpty {
//                AsyncImage(url: URL(string: user.maimai.extra.frames.first { $0.selected  == 1 }!.image)!, context: context, placeholder: {
//                    ProgressView()
//                }, image: { img in
//                    let _ = DispatchQueue.main.async {
//                        frameImg = img
//                    }
//                    Image(uiImage: img)
//                        .resizable()
//                })
//                .aspectRatio(contentMode: .fit)
//                .mask(RoundedRectangle(cornerRadius: 15))
                VStack(spacing: 5) {
                    ZStack {
                        VStack(alignment: .trailing) {
                            AsyncImage(url: URL(string: user.maimai.extra.nameplates.first { $0.selected == 1 }!.image)!, context: context, placeholder: {
                                ProgressView()
                            }, image: { img in
                                let _ = DispatchQueue.main.async {
                                    nameplateImg = img
                                }
                                Image(uiImage: img)
                                    .resizable()
                            })
                            .aspectRatio(contentMode: .fit)
                            .frame(maxHeight: 60)
                            .contextMenu {
                                Button {
                                    UIImageWriteToSavedPhotosAlbum(nameplateImg, nil, nil, nil)
                                } label: {
                                    Label("保存到相册", systemImage: "square.and.arrow.down")
                                }
                            }
                            Spacer()
                            HStack {
                                Spacer()
                                VStack(alignment: .trailing) {
                                    HStack {
                                        Text("Rating")
                                        Text("\(user.maimai.info.rating)")
                                            .bold()
                                    }
                                    HStack {
                                        Text("游玩次数")
                                        Text("\(user.maimai.info.playCount)")
                                            .bold()
                                    }
                                }
                                .padding(5)
                                .background(
                                    RoundedRectangle(cornerRadius: 5)
                                        .foregroundColor(.white.opacity(0.8))
                                )
                                .padding(5)
                            }
                        }
                        
                        HStack {
                            if let charUrl = URL(string: user.maimai.info.charUrl) {
                                AsyncImage(url: URL(string: user.maimai.info.charUrl)!, context: context, placeholder: {
                                    ProgressView()
                                }, image: { img in
                                    let _ = DispatchQueue.main.async {
                                        charImg = img
                                    }
                                    Image(uiImage: img)
                                        .resizable()
                                })
                                .aspectRatio(contentMode: .fill)
                                .shadow(color: .gray.opacity(0.8), radius: 5, x: 5, y: -5)
                                .frame(maxWidth: 175)
                                .contextMenu {
                                    Button {
                                        UIImageWriteToSavedPhotosAlbum(charImg, nil, nil, nil)
                                    } label: {
                                        Label("保存到相册", systemImage: "square.and.arrow.down")
                                    }
                                }
                            } else {
                                Image("nameplate_salt")
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .shadow(color: .gray.opacity(0.8), radius: 5, x: 5, y: -5)
                                    .frame(maxWidth: 175)
                            }
                            
                            Spacer()
                        }
                    }
                    .padding(.bottom, 25)
                    
                    if !currentLoadout.isEmpty {
                        HStack() {
                            ForEach(currentLoadout, id: \.name) { char in
                                CharacterCapsule(imageURL: char.image, level: char.level)
                            }
                        }
                        .padding(.bottom, 25)
                    }
                    
                    VStack {
                        HStack {
                            NavigationLink {
                                InfoMaimaiTrophyList(list: user.maimai.extra.trophies)
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5)
                                        .foregroundColor(.green)
                                    Label("称号一览", systemImage: "checkmark.seal.fill")
                                        .font(.system(size: 18, weight: .heavy))
                                        .foregroundColor(.white)
                                        .padding(5)
                                }
                            }
                            NavigationLink {
                                InfoMaimaiCharacterList(list: user.maimai.extra.characters)
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5)
                                        .foregroundColor(.red)
                                    Label("角色一览", systemImage: "person.2.fill")
                                        .font(.system(size: 18, weight: .heavy))
                                        .foregroundColor(.white)
                                        .padding(5)
                                }
                            }
                        }
                        .frame(maxHeight: 40)
                        HStack {
                            NavigationLink {
                                InfoMaimaiNameplateList(list: user.maimai.extra.nameplates)
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5)
                                        .foregroundColor(.orange)
                                    Label("姓名框一览", systemImage: "photo.on.rectangle.angled")
                                        .font(.system(size: 18, weight: .heavy))
                                        .foregroundColor(.white)
                                        .padding(5)
                                }
                            }
                            NavigationLink {
                                InfoMaimaiFrameList(list: user.maimai.extra.frames)
                            } label: {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 5)
                                        .foregroundColor(.blue)
                                    Label("底板一览", systemImage: "rectangle.stack.fill")
                                        .font(.system(size: 18, weight: .heavy))
                                        .foregroundColor(.white)
                                        .padding(5)
                                }
                            }
                        }
                        .frame(maxHeight: 40)
                        NavigationLink {
                            InfoMaimaiClearList(user: user)
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 5)
                                    .foregroundColor(.pink)
                                Label("歌曲完成度", systemImage: "chart.pie.fill")
                                    .font(.system(size: 18, weight: .heavy))
                                    .foregroundColor(.white)
                                    .padding(5)
                            }
                        }
                        .frame(maxHeight: 40)
                    }
                    
                }
                .padding()
                .onAppear {
                    currentLoadout = user.maimai.extra.characters.filter {
                        $0.selected == 1 && $0.image != user.maimai.info.charUrl
                    }
                }
                
                HStack(alignment: .top) {
                    let rankData = makeRankData()
                    let statusData = makeStatusData()
                    VStack {
                        PieChart(chartData: rankData)
                            .touchOverlay(chartData: rankData)
                            .headerBox(chartData: rankData)
                            .frame(width: 150, height: 150)
                            .id(rankData.id)
                            .padding(.bottom)
                        
                        ForEach(rankData.dataSets.dataPoints, id: \.id) { point in
                            HStack {
                                Text(point.description ?? "")
                                Spacer()
                                Text("\(point.value, specifier: "%.0f")")
                            }
                        }
                    }
                    VStack {
                        PieChart(chartData: statusData)
                            .touchOverlay(chartData: statusData)
                            .headerBox(chartData: statusData)
                            .frame(width: 150, height: 150)
                            .id(statusData.id)
                            .padding(.bottom)
                        
                        ForEach(statusData.dataSets.dataPoints, id: \.id) { point in
                            HStack {
                                Text(point.description ?? "")
                                Spacer()
                                Text("\(point.value, specifier: "%.0f")")
                            }
                        }
                    }
                }
                .padding()
            } else {
                Text("用户数据不完整，请尝试重新上传数据。")
                    .padding()
            }
        }
        .navigationTitle("玩家信息")
        .navigationBarTitleDisplayMode(.large)
    }
    
    func makeRankData() -> PieChartData {
        var dataPoints = [PieChartDataPoint]()
        let array = user.maimai.custom.rankCounter
        for v in array.indices {
            dataPoints.append(PieChartDataPoint(value: Double(array[v]), description: maiRankDesc[v], colour: maiRankHex[v]))
        }
        return PieChartData(dataSets: PieDataSet(dataPoints: dataPoints, legendTitle: "评级"), metadata: ChartMetadata(title: "评级", subtitle: "所有难度"), chartStyle: PieChartStyle(infoBoxPlacement: .header))
    }
    
    func makeStatusData() -> PieChartData {
        var dataPoints = [PieChartDataPoint]()
        let array = user.maimai.custom.statusCounter
        for v in array.indices {
            dataPoints.append(PieChartDataPoint(value: Double(array[v]), description: maiStatusDesc[v], colour: maiStatusHex[v]))
        }
        return PieChartData(dataSets: PieDataSet(dataPoints: dataPoints, legendTitle: "状态"), metadata: ChartMetadata(title: "状态", subtitle: "所有难度"), chartStyle: PieChartStyle(infoBoxPlacement: .header))
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}
