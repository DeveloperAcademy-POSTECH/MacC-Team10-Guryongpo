//
//  FloatingCapsuleModifier.swift
//  SoccerBeat
//
//  Created by Gucci on 11/15/23.
//

import SwiftUI

struct FloatingCapsuleModifier: ViewModifier {
    var color: Color
    
    init(color: Color = Color(hex: 0x757575, alpha: 0.4)) {
        self.color = color
    }
    
    func body(content: Content) -> some View {
        content
            .font(.custom("NotoSans-Regular", size: 14))
            .padding(.horizontal, 14)
            .padding(.vertical, 4)
            .overlay {
                Capsule()
                    .strokeBorder(color, lineWidth: 0.8)
            }
    }
}

extension View {
    func floatingCapsuleStyle() -> some View {
        modifier(FloatingCapsuleModifier())
    }
    
    func floatingCapsuleStyle(color: Color) -> some View {
        modifier(FloatingCapsuleModifier(color: color))
    }
}

#Preview {
    Text("# Hello World")
        .floatingCapsuleStyle()
}
