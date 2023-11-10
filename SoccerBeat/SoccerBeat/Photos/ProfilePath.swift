//
//  File.swift
//  SoccerBeat
//
//  Created by jose Yun on 11/10/23.
//

import SwiftUI
struct ProfilePath: View {
    var body: some View {
        VStack {
            Path { path in
                // 1. 커서 이동
                path.move(to: CGPoint(x: 200, y: 0))
                // 2.
                path.addLine(to: CGPoint(x: 200, y: 200))
                // 3.
                path.addLine(to: CGPoint(x: 0, y: 200))
            }
            .stroke()
        }
    }
}

#Preview {
    ProfilePath()
}
