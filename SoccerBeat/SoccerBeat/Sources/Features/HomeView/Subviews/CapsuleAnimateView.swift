//
//  CapsuleAnimateView.swift
//  SoccerBeat
//
//  Created by jose Yun on 10/25/24.
//

import SwiftUI

struct CapsuleAnimateView: View, Animatable {
    var progress: Double = 0.9
      private let delay = 0.2

      var animatableData: Double {
        get { progress }
        set { progress = newValue }
      }

      var body: some View {
        Capsule()
          .trim(
            from: {
              if progress > 1 - delay {
                2 * progress - 1.0
              } else if progress > delay {
                progress - delay
              } else {
                .zero
              }
            }(),
            to: progress
          )
          .glow(
            fill: .palette,
            lineWidth: 4.0
          )
      }
    }

#Preview {
    CapsuleAnimateView()
}
