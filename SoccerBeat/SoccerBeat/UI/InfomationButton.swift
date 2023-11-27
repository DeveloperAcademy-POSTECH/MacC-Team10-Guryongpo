//
//  InfomationButton.swift
//  SoccerBeat
//
//  Created by Gucci on 11/27/23.
//

import SwiftUI

struct InfomationButton: View {
    let message: String
    @State private var isInfoOpen = false
    
    var body: some View {
        Button {
            isInfoOpen.toggle()
        } label: {
            HStack(spacing: 0) {
                Image(.infoIcon)
                    .resizable()
                    .frame(width: 11, height: 15)
                if isInfoOpen {
                    Text(" \(message)")
                        .foregroundStyle(.white)
                }
            }
            .floatingCapsuleStyle(color: isInfoOpen ? .floatingCapsuleGray : .white.opacity(0.8))
        }
    }
}

#Preview {
    InfomationButton(message: "나만의 선수를 만나보세요.")
}
