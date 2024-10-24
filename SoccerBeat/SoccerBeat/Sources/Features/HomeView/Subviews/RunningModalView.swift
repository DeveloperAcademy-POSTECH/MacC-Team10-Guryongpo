//
//  SwiftUIView.swift
//  SoccerBeat
//
//  Created by jose Yun on 10/25/24.
//

import SwiftUI

struct RunningModalView: View {
    @State private var progress1: Double = 0.0
    @State private var progress2: Double = 0.0
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            VStack {
                Text("Running")
                    .foregroundStyle(.matchTotalSectionHeader)
                    .font(.beatPerMinute)
                    .padding()
                    .padding()
            }
            .overlay {
                CapsuleAnimateView(progress: progress1)
                CapsuleAnimateView(progress: progress2)
//                    .rotationEffect(.degrees(180.0))
            }
        }
        .onAppear {
            withAnimation(
                .linear(duration: 3.0)
                .repeatForever(autoreverses: false)
            ) {
                progress1 = 1.0
            }
            withAnimation(
                .linear(duration: 3.0)
                .repeatForever(autoreverses: false)
                .delay(1.5)
            ) {
                progress2 = 1.0
            }
        }

    }
}

#Preview {
    RunningModalView()
}
