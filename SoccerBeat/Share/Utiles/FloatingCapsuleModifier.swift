//
//  FloatingCapsuleModifier.swift
//  SoccerBeat
//
//  Created by Gucci on 11/15/23.
//

import SwiftUI

struct FloatingCapsuleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .overlay {
                Capsule()
                    .strokeBorder(Color(hex: 0x757575, alpha: 0.4), lineWidth: 3.0)
            }
    }
}

extension View {
    func floatingCapsuleStyle() -> some View {
        modifier(FloatingCapsuleModifier())
    }
}

#Preview {
    Text("# Hello World")
        .floatingCapsuleStyle()
}
