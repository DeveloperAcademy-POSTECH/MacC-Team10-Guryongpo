//
//  ShareView.swift
//  SoccerBeat
//
//  Created by Hyungmin Kim on 11/12/23.
//

import SwiftUI

struct ShareView: View {
    
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
        .toolbar {
            Button {
                renderImage = TargetImageView(cgSize: self.geoSize, viewModel: viewModel).asImage(size: self.geoSize)
                share()
            } label: {
                Text("공유하기")
                    .foregroundStyle(.shareViewTitleTint)
            }
        }
    }
    func share() {
        let activityVC = UIActivityViewController(activityItems: [renderImage], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
    }
}

#Preview {
    ShareView(viewModel: ProfileModel.init())
}

extension UIScreen {
    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
    static let screenSize = UIScreen.main.bounds.size
}

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
        ZStack(alignment: .top) {
            Image("BackgroundPattern")
                .frame(maxHeight: UIScreen.screenHeight - 100)
            Image("FlameEffect")
                .frame(maxHeight: UIScreen.screenHeight - 100)
            VStack {
                HStack(alignment: .bottom) {
                    CardFront(width: 100, height: 140, degree: $degree, viewModel: viewModel)
                    VStack(alignment: .leading, spacing: 0) {
                        Text("# Soccer Beat")
                            .padding(.horizontal)
                            .padding(.vertical, 5)
                            .overlay {
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.shareViewCapsuleStroke, lineWidth: 1)
                                }
                        Spacer()
                            .frame(height: 20)
                        
                        Text("SBeat Card")
                            .font(.shareViewSubTitle)
                            .foregroundStyle(.shareViewSubTitleTint)
                        VStack(alignment: .leading, spacing: -10) {
                            HStack {
                                Text("I'm, ")
                                Text("Son").foregroundStyle(.shareViewTitleTint)
                            }
                            HStack {
                                Text("Good ")
                                Text("player").foregroundStyle(.shareViewTitleTint)
                            }
                        }
                        .font(.shareViewTitle)
                    }
                    .padding()
                }
                .padding(.top)
                
                Spacer(minLength: 30)
                
                VStack(alignment: .leading) {
                    Text("#두 개의 심장 #체력")
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .overlay {
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.shareViewCapsuleStroke, lineWidth: 1)
                        }
                    
                    HStack(spacing: 25) {
                        Spacer()
                        Rectangle()
                            .frame(width: 52, height: 70)
                        Rectangle()
                            .frame(width: 52, height: 70)
                        Rectangle()
                            .frame(width: 52, height: 70)
                        Rectangle()
                            .frame(width: 52, height: 70)
                        Spacer()
                    }
                    .padding()
                    
                    
                    Text("#필드 위 치타 #스프린트")
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .overlay {
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.shareViewCapsuleStroke, lineWidth: 1)
                        }
                    
                    HStack(spacing: 25) {
                        Spacer()
                        Rectangle()
                            .frame(width: 52, height: 70)
                        Rectangle()
                            .frame(width: 52, height: 70)
                        Rectangle()
                            .frame(width: 52, height: 70)
                        Rectangle()
                            .frame(width: 52, height: 70)
                        Spacer()
                    }
                    .padding()
                    
                    Text("#필드 위 야생마 #최고 속도")
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .overlay {
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.shareViewCapsuleStroke, lineWidth: 1)
                        }
                    
                    HStack(spacing: 25) {
                        Spacer()
                        Rectangle()
                            .frame(width: 52, height: 70)
                        Rectangle()
                            .frame(width: 52, height: 70)
                        Rectangle()
                            .frame(width: 52, height: 70)
                        Rectangle()
                            .frame(width: 52, height: 70)
                        Spacer()
                    }
                }
                Spacer()
            }
            .padding()
        }
    }
}
