//
//  ShareView.swift
//  SoccerBeat
//
//  Created by Hyungmin Kim on 11/12/23.
//

import SwiftUI

struct ShareView: View {
    
    @EnvironmentObject var healthInteractor: HealthInteractor
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
    ShareView(viewModel: ProfileModel())
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
    @EnvironmentObject var healthInteractor: HealthInteractor

    var body: some View {
        ZStack(alignment: .top) {
            Image("BackgroundPattern")
                .frame(maxHeight: UIScreen.screenHeight)
            Image("FlameEffect")
                .frame(maxHeight: UIScreen.screenHeight)
            VStack {
                HStack(alignment: .bottom) {
                    CardFront(width: 100, height: 140, degree: $degree, viewModel: viewModel)
                    VStack(alignment: .leading, spacing: 0) {
                        Text("# Soccer Beat")
                            .floatingCapsuleStyle()
                        
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
                
                currentBadge
                
                Spacer()
            }
            .padding()
        }
    }
    private func floatingBadgeInfo(at sort: Int) -> some View {
        var message = ""
        switch sort {
        case 0:
            message = "# 경기 중 뛴 거리에 따라 획득하는 트로피입니다."
        case 1:
            message = "# 경기 중 스프린트 횟수에 따라 획득하는 트로피입니다."
        default: // 2
            message = "# 경기 중 최고 속도에 따라 획득하는 트로피입니다."
        }
        
        return Text(message)
                .padding(.horizontal, 8)
                .floatingCapsuleStyle()
    }
}

extension TargetImageView {
    @ViewBuilder
    var currentBadge: some View {
        VStack(spacing: 31) {
            ForEach(0..<healthInteractor.allBadges.count, id: \.self) { sortIndex in
                VStack(alignment: .leading, spacing: 10) {
                    floatingBadgeInfo(at: sortIndex)
                    HStack {
                        ForEach(0..<healthInteractor.allBadges[sortIndex].count, id: \.self) { levelIndex in
                            let isOpened = healthInteractor.allBadges[sortIndex][levelIndex]
                            
                            if isOpened {
                                TrophyView(sort: sortIndex, level: levelIndex, isOpened: isOpened)
                            }
                        }
                    }
                }
            }
        }
    }
}
