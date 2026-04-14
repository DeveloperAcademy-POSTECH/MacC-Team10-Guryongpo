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
    @State private var isProcessing = false // 처리 중 상태 표시 (선택 사항)

    // 카드 너비를 계산하는 helper 프로퍼티
    private var cardWidth: CGFloat {
        UIScreen.main.bounds.width - (39 * 2) // 양쪽 패딩 39pt 제외
    }

    // 맵 이미지 크기를 계산하는 helper 프로퍼티
    private var mapImageSize: CGSize {
        let width = cardWidth - (20 * 2) // 카드 내부 패딩 20pt 제외
        let height: CGFloat = 275 // 고정 높이
        return CGSize(width: width, height: height)
    }

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
                InformationButton(message: "최고의 퍼포먼스를 자랑하세요!")
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
                            HeatmapView(workout: workout).shootSnapshot(targetSize: mapImageSize) { image in
                                if let capturedImage = image {
                                    heatmapImage = capturedImage
                                } else {
                                    print("❌ Failed to load heatmap image.")
                                    // 에러 처리 (예: 기본 이미지 표시)
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

            // 스토리 공유 버튼
            Button {
                guard !isProcessing, heatmapImage != nil else { return } // 처리 중이거나 이미지 없으면 비활성화
                isProcessing = true
                // targetWidth를 전달하여 스냅샷 생성
                let finalImage = heatmapShareCard.snapshot(targetWidth: cardWidth)
                openInInstagram(image: finalImage)
                isProcessing = false
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
            .disabled(isProcessing || heatmapImage == nil) // 이미지 로딩/처리 중 비활성화
            .opacity((isProcessing || heatmapImage == nil) ? 0.5 : 1.0) // 비활성화 시 시각적 피드백

            // 이미지 저장 버튼
            Button {
                guard !isProcessing, heatmapImage != nil else { return }
                isProcessing = true
                let imageSaver = ImageSaver()
                // targetWidth를 전달하여 스냅샷 생성
                let finalImage = heatmapShareCard.snapshot(targetWidth: cardWidth)
                imageSaver.writeToPhotoAlbum(image: finalImage)
                showImageSavedAlert = true
                isProcessing = false
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
            .disabled(isProcessing || heatmapImage == nil)
            .opacity((isProcessing || heatmapImage == nil) ? 0.5 : 1.0)
            .alert("사진이 저장되었습니다.", isPresented: $showImageSavedAlert) { }

            // 로딩 인디케이터
            if isProcessing {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                ProgressView("처리 중...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .foregroundColor(.white)
            }
        }
        .disabled(isProcessing) // 전체 뷰 비활성화
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
            Text(LocalizedStringKey(section))
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
                        .aspectRatio(contentMode: .fill)
                        .padding(.horizontal, 20)
                        .frame(width: mapImageSize.width, height: mapImageSize.height)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: mapImageSize.width, height: mapImageSize.height)
                        .overlay(ProgressView())
                        .padding(.horizontal, 20)
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
                        section: "뛴 거리",
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
                        section: "최고 속도",
                        value: workout.velocity.rounded(at: 1),
                        unit: " KM/H"
                    )
                    Spacer()
                }
                .padding(.top, 32)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)

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
                .padding(.bottom, 20)
            }
        }
    }

    private func openInInstagram(image: UIImage) {
        guard let imageData = image.pngData() else {
            print("❌ Failed to get PNG data from snapshot.")
            // 사용자에게 오류 알림 등
            return
        }
        let instagramAppID = "2438142073191207" // 앱 ID 확인 필요
        guard let instagramURL = URL(string: "instagram-stories://share?source_application=\(instagramAppID)") else {
            print("❌ Invalid Instagram URL.")
            return
        }

        let pasteboardItems = [
            "com.instagram.sharedSticker.backgroundImage": imageData
        ]

        // 메인 스레드에서 Pasteboard 업데이트 및 URL 열기
        DispatchQueue.main.async {
            UIPasteboard.general.setItems([pasteboardItems], options: [.expirationDate: Date().addingTimeInterval(300)]) // 만료 시간 설정 권장

            if UIApplication.shared.canOpenURL(instagramURL) {
                UIApplication.shared.open(instagramURL) { success in
                    if !success {
                        print("❌ Failed to open Instagram.")
                        // 필요 시 사용자에게 알림 (예: 인스타그램 앱 설치 유도)
                    }
                }
            } else {
                print("❌ Cannot open Instagram URL. App might not be installed.")
                // 사용자에게 인스타그램 설치 안내 등
            }
        }
    }
}

// MARK: Gemini - 수정된 snapshot 함수
extension View {
    /// 주어진 너비를 기준으로 뷰의 스냅샷을 생성합니다.
    /// - Parameter targetWidth: 스냅샷을 생성할 뷰의 목표 너비. nil이면 화면 너비를 사용합니다.
    /// - Returns: 생성된 UIImage. 크기 계산 실패 시 빈 UIImage 반환.
    func snapshot(targetWidth: CGFloat) -> UIImage {
        // UIHostingController를 사용하여 SwiftUI 뷰를 래핑합니다.
        // .ignoresSafeArea()를 추가하여 SafeArea로 인한 예기치 않은 인셋을 방지할 수 있습니다. (선택 사항)
        let controller = UIHostingController(rootView: self.ignoresSafeArea())
        let view = controller.view!

        // sizeThatFits를 호출하여 주어진 너비에 필요한 크기를 계산합니다.
        // 높이는 무한대(.greatestFiniteMagnitude)로 설정하여 내용에 맞게 계산되도록 합니다.
        let targetSize = view.sizeThatFits(CGSize(width: targetWidth, height: CGFloat.greatestFiniteMagnitude))

        // 계산된 크기가 유효한지 확인합니다.
        guard targetSize.width > 0, targetSize.height > 0 else {
            print("⚠️ snapshot: 계산된 targetSize가 유효하지 않습니다: \(targetSize)")
            // 크기가 0이면 빈 이미지를 반환하거나 에러 처리를 할 수 있습니다.
            return UIImage()
        }

        // 뷰의 bounds와 frame을 계산된 크기로 설정합니다.
        view.bounds = CGRect(origin: .zero, size: targetSize)
        view.frame = CGRect(origin: .zero, size: targetSize) // frame 설정도 명시적으로 추가

        // 배경을 투명하게 설정 (뷰 자체에 배경이 없다면)
        view.backgroundColor = .clear

        // UIGraphicsImageRenderer를 사용하여 스냅샷을 생성합니다.
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let image = renderer.image { _ in
            // drawHierarchy를 사용하여 뷰 계층을 그립니다.
            // afterScreenUpdates: true로 설정하여 렌더링 업데이트가 완료된 후 그리도록 합니다.
            view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        }

        print("✅ snapshot: 스냅샷 생성 완료 (Size: \(targetSize))")
        return image
    }
}

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
