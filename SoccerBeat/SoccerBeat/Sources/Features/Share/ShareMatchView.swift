//
//  ShareMatchView.swift
//  SoccerBeat
//
//  Created by Gucci on 12/26/24.
//

import SwiftUI
import PhotosUI

struct ShareMatchView: View {
    let matchData: WorkoutData
    @State private var currentLocation = "--:--"
    @Environment(\.dismiss) var dismiss

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
                .padding([.top, .trailing], 10)
            }

            // info button
            HStack {
                InformationButton(message: "지도를 움직여 공유할 위치를 선택하세요!")
                Spacer()
            }
            .padding(.leading, 39)

            // heatmap card, shareing image
            heatmapShareCard()

            Spacer()

            // 스토리 공유
            // share image
            Button {
                // share story action

            } label: {
                HStack {
                    Image(.instagramLogo)

                    Text("스토리 공유하기")
                        .font(.shareButtonFont)
                        .padding(.leading, 32)

                }
                .frame(maxWidth: .infinity)
                .padding(10)
                .foregroundStyle(.white)
                .background(
                    Capsule()
                        .stroke(.grayGradient, lineWidth: 1)  // 그라디언트 포인트 디테일 살릴 필요 있음
                        .fill(.shareButtonTint)
                )
                .padding(.horizontal, 18)
            }

            // 이미지 저장
            // store image
            Button {
                // store action

            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.down.fill")
                        .foregroundStyle(.navigationSportyBPMTitle)

                    Text("이미지 저장하기")
                        .font(.shareButtonFont)
                        .padding(.leading, 32)
                }
                .frame(maxWidth: .infinity)
                .padding(10)
                .foregroundStyle(.white)
                .background(
                    Capsule()
                        .stroke(.grayGradient, lineWidth: 1)
                        .fill(.shareButtonTint)
                )
                .padding(.horizontal, 18)
            }
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
    }

    @ViewBuilder
    private func heatmapShareCard() -> some View {
        ZStack {
            Color(hex: 0x141415)
                .frame(height: 560)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.top, 16)
                .padding(.horizontal, 39)

            VStack(spacing: 0) {
                HeatmapView(
                    centerCoordinate: CLLocationCoordinate2D(
                        latitude: matchData.center[0],
                        longitude: matchData.center[1]
                    ),
                    routes: matchData.route
                )
                .padding(.horizontal, 20)
                .padding(.top, 40)
                .frame(height: 275)
                .clipShape(RoundedRectangle(cornerRadius: 8))

                HStack {
                    Spacer()
                    Image(systemName: "location.fill")
                        .resizable()
                        .frame(width: 10, height: 10)

                    Text(currentLocation)
                        .font(.sfCompactText(size: 16, weight: .thin))
                        .task {
                            currentLocation = await matchData.location
                        }
                }
                .foregroundStyle(Color(hex: 0xD3D3D3, alpha: 0.8))
                .padding(.horizontal, 20)
                .padding(.top, 4)

                VStack(alignment: .leading) {
                    Text("GAMETIME")
                        .font(.sfProDisplay(size: 18, weight: .heavyItalic))
                        .foregroundStyle(Color(hex: 0xFFFFFF, alpha: 0.6))
                    Text(matchData.time)
                        .font(.sfProDisplay(size: 36, weight: .heavyItalic))
                        .foregroundStyle(.bpmMax)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding([.leading, .top], 20)

                HStack {
                    verticalDivider()
                    dashboardComponent(
                        section: "뛴거리",
                        value: matchData.distance.rounded(at: 1),
                        unit: " KM"
                    )
                    Spacer()

                    verticalDivider()
                    dashboardComponent(
                        section: "스프린트",
                        value: "\(matchData.sprint)",
                        unit: " TIMES"
                    )
                    Spacer()

                    verticalDivider()
                    dashboardComponent(
                        section: "최고속도",
                        value: matchData.velocity.rounded(at: 1),
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

                Spacer()
            }
            .padding(.horizontal, 39)
        }
    }
}

#Preview {
    @Previewable
    @State var showShareView = true

    return Button("show share view") {
        showShareView.toggle()
    }
    .sheet(isPresented: $showShareView) {
        ShareMatchView(matchData: .example)
    }
}
