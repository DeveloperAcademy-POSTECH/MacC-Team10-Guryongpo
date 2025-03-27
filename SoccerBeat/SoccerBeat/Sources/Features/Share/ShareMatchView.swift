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
                InformationButton(message: "지도를 움직여 공유할 위치를 선택하세요!")
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
                // MARK: - MapView 저장
                let imageSaver = ImageSaver()
                /**
                 shootWithMap { image in
                 imageSaver.writeToPhotoAlbum(image: image)
                 showImageSavedAlert = true
                 }
                 */

                // MARK: - Screen Shot 저장
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

    @ViewBuilder
    private var pureHeatMap: HeatmapView {
        HeatmapView(workout: workout)
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
//                    pureHeatMap
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
        .offset(y: -23)
    }

    private func openInInstagram() {
        // MARK: - MapView 저장
        /**
         shootWithMap { image in
         guard let imageData = image.pngData() else { return }
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
        */

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

//    func shootWithMap(completion: @escaping (UIImage) -> Void) {
//        let center = CLLocationCoordinate2D(latitude: workout.center[0], longitude: workout.center[1])
//        let options = MKMapSnapshotter.Options()
//        options.size = UIScreen.main.bounds.size
//        options.mapType = .mutedStandard
//        options.showsBuildings = false
//        options.region = MKCoordinateRegion(center: center, latitudinalMeters: 150, longitudinalMeters: 150)
//
//        let snapshotter = MKMapSnapshotter(options: options)
//        snapshotter.start { snapshot, error in
//            guard let snapshot = snapshot?.image else { return }
//            
//            completion(snapshot)
//        }
//    }
}

extension View {
    func snapshot(of frame: CGRect? = nil) -> UIImage {
        let controller = UIHostingController(rootView: self)
        let view = controller.view!
        let targetSize = controller.view.intrinsicContentSize
        view.bounds = CGRect(origin: .zero, size: targetSize)
        view.backgroundColor = .clear

        // UIGraphicsImageRenderer의 사용
        let renderer = UIGraphicsImageRenderer(size: targetSize)

        // 렌더러에서 직접 컨트롤러 뷰를 그려서 스냅샷 찍기
        return renderer.image { context in
            // MapView가 있는 UIView 계층을 그리도록 한다.
            view.drawHierarchy(in: CGRect(origin: .zero, size: targetSize), afterScreenUpdates: true)
        }
    }
}

//extension View {
//    // 특정 뷰만 캡처하는 메서드
//    func snapshot() -> UIImage {
//        let controller = UIHostingController(rootView: self)
//        let view = controller.view
//        
//        // 뷰 설정
//        view?.backgroundColor = .clear
//        
//        // 레이아웃 처리를 위해 사이즈 계산
//        view?.frame = CGRect(origin: .zero, size: controller.sizeThatFits(in: UIScreen.main.bounds.size))
//        
//        // 레이아웃 업데이트
//        view?.layoutIfNeeded()
//        
//        // 실제 크기 확인
//        let targetSize = view?.bounds.size ?? .zero
//        
//        // 렌더러 생성 및 이미지 반환
//        let renderer = UIGraphicsImageRenderer(size: targetSize)
//        return renderer.image { _ in
//            view?.drawHierarchy(in: CGRect(origin: .zero, size: targetSize), afterScreenUpdates: true)
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
