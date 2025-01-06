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
                        .frame(width: 30, height: 30)
                }
                .foregroundStyle(.white)
                .padding([.top, .trailing], 10)
            }

            HStack {
                InformationButton(message: "지도를 움직여 공유할 위치를 선택하세요!")
                Spacer()
            }
            .padding(.leading, 39)

            // photo card, shareing image
            Color.white
                .frame(height: 560)
                .padding(.top, 16)
                .padding(.horizontal, 39)

            Spacer()

            // 스토리 공유
            // share image
            Button {
                // share story action
                
            } label: {
                HStack {
                    Image(systemName: "x.circle")

                    Spacer()
                        .frame(width: 32)

                    Text("스토리 공유하기")
                        .font(.shareButtonFont)

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

                    Spacer()
                        .frame(width: 32)

                    Text("이미지 저장하기")
                        .font(.shareButtonFont)
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
