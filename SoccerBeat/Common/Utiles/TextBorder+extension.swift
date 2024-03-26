//
//  TextBorder+extension.swift
//  SoccerBeat
//
//  Created by Gucci on 11/12/23.
//

import SwiftUI

extension View {
    @ViewBuilder
    func viewBorder(color: Color = .black, radius: CGFloat = 0.4, outline: Bool = false) -> some View {
        if outline {
            self
                .shadow(color: color, radius: radius)
                .shadow(color: color, radius: radius)
                .shadow(color: color, radius: radius)
                .shadow(color: color, radius: radius)
                .shadow(color: color, radius: radius)
                .shadow(color: color, radius: radius)
                .shadow(color: color, radius: radius)
                .shadow(color: color, radius: radius)
                .invertedMask(
                    self
                )
        } else {
            self
                .shadow(color: color, radius: radius)
                .shadow(color: color, radius: radius)
                .shadow(color: color, radius: radius)
                .shadow(color: color, radius: radius)
                .shadow(color: color, radius: radius)
                .shadow(color: color, radius: radius)
                .shadow(color: color, radius: radius)
                .shadow(color: color, radius: radius)
        }
    }
}

extension View {
    private func invertedMask<Content : View>(_ content: Content) -> some View {
        self
            .mask(
                ZStack {
                    self
                        .brightness(1)
                    content
                        .brightness(-1)
                }.compositingGroup()
                    .luminanceToAlpha()
            )
    }
}

#Preview {
    Text("Hello World")
        .viewBorder(color: .white, radius: 0.15, outline: true)
}
