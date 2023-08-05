//
//  UpdaterQRCodeView.swift
//  chafenqi
//
//  Created by xinyue on 2023/6/20.
//

import SwiftUI
import AlertToast
import CoreData

struct UpdaterQRCodeView: View {
    @State private var toastModel = AlertToastModel.shared
    @State private var selectedMode = 1
    
    var nameplateChuniColorBottom = Color(red: 243, green: 200, blue: 48)
    var nameplateMaiColorBottom = Color(red: 93, green: 166, blue: 247)
    
    var maiStr = ""
    var chuStr = ""
    
    var body: some View {
        VStack {
            TabView(selection: $selectedMode) {
                VStack {
                    QRCode(string: maiStr, overlayImage: "Icon")
                        .padding(.bottom)
                    Text("舞萌DX")
                        .foregroundColor(nameplateMaiColorBottom)
                        .bold()
                }
                .tag(1)
                
                VStack {
                    QRCode(string: chuStr, overlayImage: "Icon")
                        .padding(.bottom)
                    Text("中二节奏")
                        .foregroundColor(nameplateChuniColorBottom)
                        .bold()
                }
                .tag(0)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            Spacer()
            Link("打开微信扫一扫", destination: URL(string: "weixin://scanqrcode")!)
                .padding(.bottom, 10)
            Button {
                snapshotThenSave()
            } label: {
                HStack {
                    Image(systemName: "photo.on.rectangle.angled")
                        .foregroundColor(.white)
                    Text("保存至相册")
                        .bold()
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            .background(Color.blue)
            .mask(RoundedRectangle(cornerRadius: 10))
            
        }
        .padding()
        .toast(isPresenting: $toastModel.show) {
            toastModel.toast
        }
    }
    
    func snapshotThenSave() {
        let snapshotView = selectedMode == 0 ? QRCodeSnapshot(chuStr: chuStr) : QRCodeSnapshot(maiStr: maiStr)
        let image = snapshotView.snapshotSelf()
        
        let imageSaver = ImageSaver()
        imageSaver.successHandler = {
            print("[Updater] Successfully saved snapshot.")
            toastModel.toast = AlertToast(displayMode: .hud, type: .complete(.green), title: "保存成功")
        }
        
        imageSaver.errorHandler = { error in
            print("[Updater] Failed to save snapshot. \(error.localizedDescription)")
            toastModel.toast = AlertToast(displayMode: .hud, type: .error(.red), title: "保存失败", subTitle: "请检查存储空间或权限")
        }
        
        imageSaver.writeToPhotoAlbum(image: image)
    }
}

// MARK: Single QR Code
struct QRCode: View {
    var string: String
    var overlayImage: String
    
    var body: some View {
        ZStack {
            if !string.isEmpty {
                Image(uiImage: string.makeQRCode())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                Image(overlayImage)
                    .resizable()
                    .scaledToFit()
                    .mask(RoundedRectangle(cornerRadius: 5))
                    .frame(width: 50, height: 50)
            }
        }
    }
}

// MARK: Snapshot View
struct QRCodeSnapshot: View {
    var maiStr: String = ""
    var chuStr: String = ""
    
    var nameplateChuniColorBottom = Color(red: 243, green: 200, blue: 48)
    var nameplateMaiColorBottom = Color(red: 93, green: 166, blue: 247)
    
    var body: some View {
        VStack {
            if !maiStr.isEmpty {
                VStack {
                    QRCode(string: maiStr, overlayImage: "Icon")
                    Text("舞萌DX")
                        .foregroundColor(nameplateMaiColorBottom)
                        .bold()
                    
                }
            }
            
            if !chuStr.isEmpty {
                VStack {
                    QRCode(string: chuStr, overlayImage: "Icon")
                    Text("中二节奏")
                        .foregroundColor(nameplateChuniColorBottom)
                        .bold()
                }
            }
        }
        .padding(20)
        .edgesIgnoringSafeArea(.all)
    }
}

struct UpdaterQRCode_Previews: PreviewProvider {
    static var previews: some View {
        UpdaterQRCodeView(maiStr: "testString1testString1testString1testString1testString1testString1", chuStr: "testString2testString2testString2testString2testString2testString2testString2")
    }
}

// MARK: ImageSaver
class ImageSaver: NSObject {
    var successHandler: (() -> Void)?
    var errorHandler: ((Error) -> Void)?
    
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }
    
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            errorHandler?(error)
        } else {
            successHandler?()
        }
    }
}
