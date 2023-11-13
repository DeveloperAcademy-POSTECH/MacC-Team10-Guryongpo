//
//  ShareInstagramView.swift
//  SoccerBeat
//
//  Created by Hyungmin Kim on 11/12/23.
//

import SwiftUI

struct ShareInstagramView: View {
    
    @State var geoSize: CGSize = .init(width: 0, height: 0)
    @State var highresImage: UIImage = UIImage()
    @State var renderImage: UIImage?
    @ObservedObject var viewModel: ProfileModel
    
    var body: some View {
        VStack {
            GeometryReader { geo in
                TargetImageView(cgSize: geo.size, degree: 0, viewModel: viewModel)
                    .onAppear {
                        self.geoSize = CGSize(width: geo.size.width, height: geo.size.height)
                    }
            }
            
        }
        .padding()
        .toolbar {
            Button {
                renderImage = TargetImageView(cgSize: self.geoSize, viewModel: viewModel).asImage(size: self.geoSize)
                
//                onClick()
                share()
            } label: {
                Text("공유하기")
                    .frame(height: 200)
            }
        }
    }
    func share() {
        let activityVC = UIActivityViewController(activityItems: [renderImage], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
    }
//    private func onClick() {
//        guard let url = URL(string: "instagram-stories://share?source_application=com.SoccerBeat.Guryongpo"),
//                 let image = renderImage,
//                 let imageData = image.pngData() else { return }
//
//       let pasteboardItems: [String: Any] = ["com.instagram.sharedSticker.stickerImage": imageData]
//       let pasteboardOptions = [UIPasteboard.OptionsKey.expirationDate: Date().addingTimeInterval(300)]
//
//       UIPasteboard.general.setItems([pasteboardItems], options: pasteboardOptions)
//
//       if UIApplication.shared.canOpenURL(url) {
//           UIApplication.shared.open(url)
//       } else {
//           print("인스타그램이 설치되어 있지 않습니다.")
//       }
//    }
}

//#Preview {
//    ShareInstagramView()
//}

extension UIView {
    func asImage(size: CGSize) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: size, format: format).image { context in
            self.drawHierarchy(in: self.layer.bounds, afterScreenUpdates: true)
        }
    }
}

extension View {
    func asImage(size: CGSize) -> UIImage {
        let controller = UIHostingController(rootView: self)
        controller.view.bounds = CGRect(origin: .zero, size: size)
        let image = controller.view.asImage(size: size)
        return image
    }
}

struct TargetImageView: View {
    @State var cgSize: CGSize
    @State var degree: Double = 0
    @ObservedObject var viewModel: ProfileModel

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                VStack(alignment: .leading) {
                    Text("Super Son")
                    Text("The best player")
                }
                .font(.shareInstagramTitle)
                .foregroundStyle(.shareInstagramTitle)
                Spacer()
            }
            
            CardFront(width: 280, height: 405, degree: $degree, viewModel: viewModel)
            
            Image("PlayerAbilities")
                .resizable()
                .frame(width: 250, height: 240)
        }
    }
}
