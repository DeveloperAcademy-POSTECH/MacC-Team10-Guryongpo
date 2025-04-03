//
//  ShareMatchView.swift
//  SoccerBeat
//
//  Created by Gucci on 12/26/24.
//

import SwiftUI
import PhotosUI
import MapKit
import UIKit

class ImageSaver: NSObject {
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }

    @objc func saveCompleted(
        _ image: UIImage,
        didFinishSavingWithError error: Error?,
        contextInfo: UnsafeRawPointer) {
        print("Save finished!")
    }
}

struct ShareMatchView: View {
    let workout: WorkoutData
    @State private var currentLocation = "--:--"
    @State private var showImageSavedAlert = false
    @Environment(\.dismiss) var dismiss
    @State private var heatmapImage: UIImage? = nil

    var body: some View {
        VStack {
            // dismiss button
            HStack {
                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "x.circle")
                        .resizable()
                        .frame(width: 17, height: 17)
                }
                .foregroundStyle(.white)
                .padding([.top, .trailing], 16)
            }

            // info button
            HStack {
                InformationButton(message: "이번 경기의 최고의 퍼포먼스를 친구들에게 자랑하세요!")
                Spacer()
            }
            .padding(.leading, 39)
            
            VStack {
                Spacer()
                    .frame(height: 16)
                HStack {
                    Spacer()
                        .frame(width: 39)
                    
                    // heatmap card, shareing image
                    heatmapShareCard
                        .onAppear {
                            //MARK: HeatmapView를 새로 로드해서 MapView 부분을 heatmapImage에 저장
                            HeatmapView(workout: workout).shootSnapshot { image in
                                if let capturedImage = image {
                                    heatmapImage = capturedImage
                                }
                            }
                        }
                    
                    Spacer()
                        .frame(width: 39)
                }
                Spacer()
                    .frame(height: 21)
            }
            
            Spacer()

            // 스토리 공유
            // share image
            Button {
                // share story action
                openInInstagram()
            } label: {
                ZStack {
                    LightRectangleView(
                        alpha: 0.15,
                        color: .seeAllMatch,
                        radius: 22
                    )
                    .frame(height: 38)

                    HStack {
                        Image(.instagramLogo)

                        Text("스토리 공유하기")
                            .font(.shareButtonFont)
                    }
                }
                .padding(.horizontal, 18)
                .foregroundStyle(.white)
            }

            // 이미지 저장
            // store image
            Button {
                // MARK: - Screen Shot 저장
                let imageSaver = ImageSaver()
                let inputImage = heatmapShareCard.snapshot()
                imageSaver.writeToPhotoAlbum(image: inputImage)
                showImageSavedAlert = true
            } label: {
                ZStack {
                    LightRectangleView(
                        alpha: 0.15,
                        color: .seeAllMatch,
                        radius: 22
                    )
                    .frame(height: 38)

                    HStack {
                        Image(systemName: "square.and.arrow.down.fill")
                            .foregroundStyle(.navigationSportyBPMTitle)

                        Text("이미지 저장하기")
                            .font(.shareButtonFont)
                    }
                }
                .padding(.top, 8)
                .padding(.horizontal, 18)
                .foregroundStyle(.white)
            }
            .alert("사진이 저장되었습니다.", isPresented: $showImageSavedAlert) { }
        }
    }

    @ViewBuilder
    private func verticalDivider() -> some View {
        LinearGradient(
            colors: [
                Color(hex: 0xFFFFFF, alpha: 0.0),
                Color(hex: 0xFFFFFF, alpha: 0.6),
                Color(hex: 0xFFFFFF, alpha: 0.0)
            ],
            startPoint: .top, endPoint: .bottom
        )
        .frame(width: 2, height: 30)
    }

    @ViewBuilder
    private func dashboardComponent(
        section: String,
        value: String,
        unit: String
    ) -> some View {
        VStack(alignment: .leading) {
            Text(section)
                .font(.notoSans(size: 12))
            Text(value)
                .font(.sfCompactText(size: 18, weight: .semiboldItalic))
            + Text(unit)
                .font(.sfCompactText(size: 12, weight: .semiboldItalic))

        }
        .padding(.leading, 8)
        .foregroundStyle(.white)
    }

    // 이 화면이 공유되는 오브젝트
    /// 사진, 혹은 인스타에서 활용 가능
    @ViewBuilder
    private var heatmapShareCard: some View {
        ZStack {
            Color(hex: 0x141415)
                .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 20)
                if let heatmapImage = heatmapImage {
                    Image(uiImage: heatmapImage)
                        .resizable()
                        .scaledToFill()
                        .padding(.horizontal, 20)
                        .frame(height: 275)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .padding(.horizontal, 20)
                        .frame(height: 275)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                HStack {
                    Spacer()
                    Image(systemName: "location.fill")
                        .resizable()
                        .frame(width: 10, height: 10)

                    Text(currentLocation)
                        .font(.sfCompactText(size: 12, weight: .thin))
                        .task {
                            currentLocation = await workout.location
                        }
                }
                .foregroundStyle(Color(hex: 0xD3D3D3, alpha: 0.8))
                .padding(.horizontal, 20)
                .padding(.top, 4)

                VStack(alignment: .leading) {
                    Text("GAMETIME")
                        .font(.sfProDisplay(size: 18, weight: .heavyItalic))
                        .foregroundStyle(Color(hex: 0xFFFFFF, alpha: 0.6))
                    Text(workout.time)
                        .font(.sfProDisplay(size: 36, weight: .heavyItalic))
                        .foregroundStyle(.bpmMax)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.leading, .top], 20)

                HStack {
                    verticalDivider()
                    dashboardComponent(
                        section: "뛴거리",
                        value: workout.distance.rounded(at: 1),
                        unit: " KM"
                    )
                    Spacer()

                    verticalDivider()
                    dashboardComponent(
                        section: "스프린트",
                        value: "\(workout.sprint)",
                        unit: " TIMES"
                    )
                    Spacer()

                    verticalDivider()
                    dashboardComponent(
                        section: "최고속도",
                        value: workout.velocity.rounded(at: 1),
                        unit: " KM/H"
                    )
                    Spacer()
                }
                .padding(.top, 32)
                .padding(.horizontal, 20)

                HStack {
                    Image(.soccerbeatHeart)
                        .resizable()
                        .frame(maxWidth: 15, maxHeight: 12.31)

                    Text("SOCCERBEAT")
                        .font(.turretRoad(size: 16))
                        .foregroundStyle(Color(hex: 0x0AA17D))
                }
                .frame(maxWidth: .infinity, maxHeight: 35, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 32)
            }
        }
    }

    private func openInInstagram() {

        // MARK: - ScreenShot 저장
        guard let imageData = heatmapShareCard.snapshot().pngData() else { return }
        let instagramAppID = "2438142073191207"
        let instagramURL = URL(string: "instagram-stories://share?source_application=\(instagramAppID)")!
        let pasteboardItems = [
            "com.instagram.sharedSticker.backgroundImage": imageData
        ]

        UIPasteboard.general.setItems([pasteboardItems])

        if UIApplication.shared.canOpenURL(instagramURL) {
            UIApplication.shared.open(instagramURL)
        }
    }
}

// MARK: 기존 코드
//extension View {
//    func snapshot(of frame: CGRect? = nil) -> UIImage {
//        let controller = UIHostingController(rootView: self)
//        let view = controller.view!
//        let targetSize = controller.view.intrinsicContentSize
//        view.bounds = CGRect(origin: .zero, size: targetSize)
//        view.backgroundColor = .clear
//
//        // UIGraphicsImageRenderer의 사용
//        let renderer = UIGraphicsImageRenderer(size: targetSize)
//
//        // 렌더러에서 직접 컨트롤러 뷰를 그려서 스냅샷 찍기
//        return renderer.image { context in
//            // MapView가 있는 UIView 계층을 그리도록 한다.
//            view.drawHierarchy(in: CGRect(origin: .zero, size: targetSize), afterScreenUpdates: true)
//        }
//    }
//}

// MARK: 성공 1. 하지만 비율 문제.
extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view!
        
        // 뷰의 레이아웃 크기 설정
        view.frame = UIScreen.main.bounds
        view.bounds = UIScreen.main.bounds
        
        // 뷰의 스케일 설정
        view.contentScaleFactor = UIScreen.main.scale
        
        // 렌더러 초기화
        let renderer = UIGraphicsImageRenderer(bounds: view.bounds)
        
        // 이미지 렌더링
        return renderer.image { context in
            // 뷰의 계층 구조를 그리기
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }
    }
}

// MARK: 성공 2. 하지만 비율 문제.
//extension View {
//    func snapshot(scale: CGFloat = UIScreen.main.scale) -> UIImage {
//        let window = UIApplication.shared.windows.first { $0.isKeyWindow }
//        let rootViewController = window?.rootViewController
//        
//        // 현재 뷰를 포함하는 호스팅 컨트롤러 생성
//        let hostingController = UIHostingController(rootView: self)
//        hostingController.view.frame = rootViewController?.view.bounds ?? .zero
//        
//        // 뷰 계층에 추가
//        rootViewController?.view.addSubview(hostingController.view)
//        
//        // 렌더러 생성
//        let renderer = UIGraphicsImageRenderer(bounds: hostingController.view.bounds)
//        
//        // 이미지 캡처
//        let image = renderer.image { context in
//            hostingController.view.drawHierarchy(in: hostingController.view.bounds, afterScreenUpdates: true)
//        }
//        
//        // 임시로 추가한 뷰 제거
//        hostingController.view.removeFromSuperview()
//        
//        return image
//    }
//}

// MARK: 실패 1. 기존 코드와 같은 현상. 비율은 같으나 heatmapShareCard의 비율이 핸드폰 화면과 맞지 않아 잘리는 듯.
//extension View {
//    func snapshot() -> UIImage {
//        let controller = UIHostingController(rootView: self)
//        
//        // 뷰의 고유 크기를 정확히 계산
//        let targetSize = controller.view.intrinsicContentSize
//        
//        // 컨트롤러의 뷰 크기를 정확히 설정
//        controller.view.frame = CGRect(origin: .zero, size: targetSize)
//        controller.view.bounds = CGRect(origin: .zero, size: targetSize)
//        
//        // 렌더러 생성 - 정확한 크기로
//        let renderer = UIGraphicsImageRenderer(size: targetSize)
//        
//        // 이미지 렌더링
//        return renderer.image { context in
//            controller.view.drawHierarchy(in: CGRect(origin: .zero, size: targetSize), afterScreenUpdates: true)
//        }
//    }
//}
// MARK: 실패 2. 기존 코드와 같은 현상. 비율은 같으나 heatmapShareCard의 비율이 핸드폰 화면과 맞지 않아 잘리는 듯.

//extension View {
//    func snapshot(fixedWidth: CGFloat? = nil) -> UIImage {
//        let controller = UIHostingController(rootView: self)
//        
//        // 사이즈 계산 로직 개선
//        var targetSize: CGSize
//        
//        if let width = fixedWidth {
//            // 고정 너비가 주어진 경우
//            targetSize = controller.view.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
//        } else {
//            // 기본적으로 뷰의 고유 크기 사용
//            targetSize = controller.view.intrinsicContentSize
//        }
//        
//        // 렌더러 생성
//        let renderer = UIGraphicsImageRenderer(size: targetSize)
//        
//        // 컨트롤러 뷰 설정
//        controller.view.frame = CGRect(origin: .zero, size: targetSize)
//        controller.view.bounds = CGRect(origin: .zero, size: targetSize)
//        
//        // 이미지 렌더링
//        return renderer.image { context in
//            controller.view.drawHierarchy(in: CGRect(origin: .zero, size: targetSize), afterScreenUpdates: true)
//        }
//    }
//}


// MARK: 택도 없음
//extension View {
//    func snapshotWithGeometry() -> UIImage? {
//        // GeometryReader를 통해 실제 뷰 크기 캡처
//        let view = GeometryReader { geometry in
//            self
//                .frame(width: geometry.size.width, height: geometry.size.height)
//        }
//        
//        let controller = UIHostingController(rootView: view)
//        
//        // 뷰의 정확한 크기 계산
//        controller.view.sizeToFit()
//        
//        let targetSize = controller.view.intrinsicContentSize
//        
//        // 렌더러 생성
//        let renderer = UIGraphicsImageRenderer(size: targetSize)
//        
//        // 이미지 렌더링
//        return renderer.image { context in
//            controller.view.drawHierarchy(in: CGRect(origin: .zero, size: targetSize), afterScreenUpdates: true)
//        }
//    }
//}

// MARK: 여기도 비율 문제로 실패.
//extension View {
//    func preciseSnapshot(width: CGFloat? = nil) -> UIImage? {
//        let controller = UIHostingController(rootView: self)
//        
//        // 특정 너비 또는 고유 크기 사용
//        let targetWidth = width ?? UIScreen.main.bounds.width
//        let targetSize = controller.view.sizeThatFits(CGSize(width: targetWidth, height: .greatestFiniteMagnitude))
//        
//        controller.view.frame = CGRect(origin: .zero, size: targetSize)
//        
//        let renderer = UIGraphicsImageRenderer(size: targetSize)
//        
//        return renderer.image { context in
//            controller.view.drawHierarchy(in: CGRect(origin: .zero, size: targetSize), afterScreenUpdates: true)
//        }
//    }
//}


#Preview {
    @Previewable
    @State var showShareView = true

    return Button("show share view") {
        showShareView.toggle()
    }
    .sheet(isPresented: $showShareView) {
        ShareMatchView(workout: .example)
    }
}
