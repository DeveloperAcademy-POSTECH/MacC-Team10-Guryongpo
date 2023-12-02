//
//  InformationButton.swift
//  SoccerBeat
//
//  Created by Gucci on 11/27/23.
//
import SwiftUI

struct InformationButton: View {
    let message: String
    @State private var isInfoOpen = false

    var body: some View {
        Button {
            isInfoOpen.toggle()
        } label: {
            HStack(spacing: 0) {
                Text(" ")
                Image(.infoIcon)
                    .resizable()
                    .frame(width: 11, height: 15)
                if isInfoOpen {
                    Text(" \(message)")
                        .foregroundStyle(.white)
                }
                Text(" ")
            }
            .floatingCapsuleStyle(color: isInfoOpen ? .floatingCapsuleGray : .white.opacity(0.8))
        }
    }
}

#Preview {
    InformationButton(message: "나만의 선수를 만나보세요.")
}
