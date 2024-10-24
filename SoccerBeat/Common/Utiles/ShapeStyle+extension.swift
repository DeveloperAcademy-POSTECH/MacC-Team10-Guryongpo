//
//  ShapeStyle+extension.swift
//  SoccerBeat
//
//  Created by jose Yun on 10/25/24.
//

import Foundation
import SwiftUI

extension ShapeStyle where Self == AngularGradient {
  static var palette: some ShapeStyle {
    .angularGradient(
      stops: [
        .init(color: .zone1Tint, location: 0.0),
        .init(color: .zone2Tint, location: 0.2),
        .init(color: .zone3Tint, location: 0.4),
        .init(color: .zone2Tint, location: 0.5),
        .init(color: .zone1Tint, location: 0.7),
        .init(color: .zone2Tint, location: 0.9),
        .init(color: .zone3Tint, location: 1.0),
      ],
      center: .center,
      startAngle: Angle(radians: .zero),
      endAngle: Angle(radians: .pi * 2)
    )
  }
}
