//
//  FlareRectangleView.swift
//  SoccerBeat
//
//  Created by jose Yun on 10/22/23.
//

import SwiftUI

struct LightRectangleView: View {
    var backgroundColor: Color = .gray.opacity(0.2)
    var intensity: CGFloat = 0.5
    var gradient = Gradient(colors: [
        Color.white,
        Color.white,
        Color.white.opacity(0.2),
        Color.white
    ])
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20.0)
                .fill(backgroundColor)
                .frame(maxWidth: .infinity)
                .overlay(
                    ZStack(alignment: .topLeading) {
                        LinearGradient(gradient: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                            .mask(
                                RoundedRectangle(cornerRadius: 20.0)
                            )
                            .opacity(0.12)
                        
                        LinearGradient(gradient: gradient, startPoint: .leading, endPoint: .trailing)
                            .mask(
                                RoundedRectangle(cornerRadius: 20.0)
                                    .strokeBorder(lineWidth: 1)
                            )
                    }
                        .opacity(0.5)
                )
        }
    }
}

#Preview {
    LightRectangleView()
}
