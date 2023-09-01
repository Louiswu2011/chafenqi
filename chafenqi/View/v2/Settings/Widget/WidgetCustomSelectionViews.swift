//
//  WidgetCustomSelectionViews.swift
//  chafenqi
//
//  Created by 刘易斯 on 2023/7/31.
//

import SwiftUI

struct WidgetBgCustomSelectionView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.presentationMode) var presentationMode
    
    var availableChuBgs: [CFQData.Chunithm.ExtraEntry.NameplateEntry]? = nil
    var availableMaiBgs: [CFQData.Maimai.ExtraEntry.FrameEntry]? = nil
    
    @Binding var selectedChuBg: CFQData.Chunithm.ExtraEntry.NameplateEntry?
    @Binding var selectedMaiBg: CFQData.Maimai.ExtraEntry.FrameEntry?
    
    var body: some View {
        Form {
            if let entries = availableChuBgs {
                ForEach(entries, id: \.url) { nameplate in
                    HStack {
                        Spacer()
                        VStack(alignment: .center) {
                            AsyncImage(url: URL(string: nameplate.url)!, context: context, placeholder: {
                                ProgressView()
                            }, image: { img in
                                Image(uiImage: img)
                                    .resizable()
                            })
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 60)
                            Text(nameplate.name)
                                .bold()
                        }
                        Spacer()
                    }
                    .onTapGesture {
                        selectedChuBg = nameplate
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            } else if let entries = availableMaiBgs {
                ForEach(entries, id: \.image) { frame in
                    VStack {
                        AsyncImage(url: URL(string: frame.image)!, context: context, placeholder: {
                            ProgressView()
                        }, image: { img in
                            Image(uiImage: img)
                                .resizable()
                        })
                        .aspectRatio(contentMode: .fit)
                        Text(frame.name)
                            .bold()
                        Text(frame.description)
                    }
                    .onTapGesture {
                        selectedMaiBg = frame
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct WidgetCharCustomSelectionView: View {
    @Environment(\.managedObjectContext) var context
    @Environment(\.presentationMode) var presentationMode
    
    var availableChuChars: [CFQData.Chunithm.ExtraEntry.CharacterEntry]?
    var availableMaiChars: [CFQData.Maimai.ExtraEntry.CharacterEntry]?
    
    @Binding var selectedChuChar: CFQData.Chunithm.ExtraEntry.CharacterEntry?
    @Binding var selectedMaiChar: CFQData.Maimai.ExtraEntry.CharacterEntry?
    
    var body: some View {
        Form {
            if let entries = availableChuChars {
                ForEach(entries, id: \.name) { character in
                    HStack {
                        AsyncImage(url: URL(string: character.url)!, context: context, placeholder: {
                            ProgressView()
                        }, image: { img in
                            Image(uiImage: img)
                                .resizable()
                        })
                        .aspectRatio(1 ,contentMode: .fit)
                        .mask(RoundedRectangle(cornerRadius: 5))
                        .frame(width: 50)
                        
                        VStack {
                            HStack {
                                Text(character.name)
                                    .lineLimit(1)
                                Spacer()
                                if character.current == 1 {
                                    Text("当前角色")
                                        .bold()
                                }
                                Text("LV \(character.rank)")
                            }
                            Spacer()
                            ProgressView(value: character.exp)
                        }
                        .padding(.vertical, 5)
                    }
                    .frame(height: 60)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedChuChar = character
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            } else if let entries = availableMaiChars {
                ForEach(entries, id: \.image) { char in
                    HStack {
                        AsyncImage(url: URL(string: char.image)!, context: context, placeholder: {
                            ProgressView()
                        }, image: { img in
                            Image(uiImage: img)
                                .resizable()
                        })
                        .aspectRatio(contentMode: .fit)
                        .mask(RoundedRectangle(cornerRadius: 5))
                        .frame(width: 60, height: 60)
                        VStack {
                            HStack {
                                Text(char.name)
                                    .bold()
                                Spacer()
                                Text(char.level)
                            }
                        }
                    }
                    .onTapGesture {
                        selectedMaiChar = char
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}
