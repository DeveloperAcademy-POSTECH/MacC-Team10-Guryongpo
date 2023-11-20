//
//  FlareRectangleView.swift
//  SoccerBeat
//
//  Created by jose Yun on 10/22/23.
//

import SwiftUI

struct LightRectangleView: View {
    let backgroundAlpha: Double
    let backgroundColor: Color
    let radius: Double
    var intensity: CGFloat = 0.5
    var gradient = Gradient(colors: [
        Color.white,
        Color.white,
        Color.white.opacity(0.2),
        Color.white
    ])
    
    init(alpha: Double = 1.0, color: Color = .black, radius: Double = 15.0) {
        self.backgroundAlpha = alpha
        self.backgroundColor = color
        self.radius = radius
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: radius)
            .fill(backgroundColor)
            .opacity(backgroundAlpha)
            .overlay(
                ZStack(alignment: .topLeading) {
                    LinearGradient(gradient: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                        .mask(
                            RoundedRectangle(cornerRadius: radius)
                        )
                        .opacity(0.12)
                    
                    LinearGradient(gradient: gradient, startPoint: .leading, endPoint: .trailing)
                        .mask(
                            RoundedRectangle(cornerRadius: radius)
                                .strokeBorder(lineWidth: 2)
                        )
                }
                    .opacity(0.5)
            )
    }
}

#Preview {
    LightRectangleView(alpha: 1.0, color: .black, radius: 15.0)
}
