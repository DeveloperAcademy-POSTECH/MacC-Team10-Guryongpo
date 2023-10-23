//
//  Color+extension.swift
//  SoccerBeat Watch App
//
//  Created by Gucci on 10/22/23.
//

import SwiftUI

extension ShapeStyle where Self == Color {
    
    // MARK: - Color init
    
    init(hex: UInt, alpha: Double = 1.0) {
            let red = Double((hex >> 16) & 0xff) / 255.0
            let green = Double((hex >> 8) & 0xff) / 255.0
            let blue = Double(hex & 0xff) / 255.0
            self.init(red: red, green: green, blue: blue, opacity: alpha)
    }
    
    // MARK: - Sprint Progress
    
    static var gaugeBackground: Self { Self(hex: 0xD9D9D9, alpha: 0.6) }
    
    // MARK: - HeartRate Tint
    
    static var zone1Tint: Self { .init(hex: 0xFFE603) }
    static var zone2Tint: Self { .init(hex: 0x03B3FF) }
    static var zone3Tint: Self { .init(hex: 0x03FFC3) }
    static var zone4Tint: Self { .init(hex: 0xFF00B8) }
    static var zone5Tint: Self { .init(hex: 0xFF4003) }
    
    static var zone3MiddleTint: Self { .init(hex: 0x03BBF9, alpha: 0.4109) }
    
    static var zone1StartTint: Self { .init(hex: 0xFFE603, alpha: 0.35) }
    static var zone2StartTint: Self { .init(hex: 0x03B3FF, alpha: 0.35) }
    static var zone3StartTint: Self { .init(hex: 0x03B3FF, alpha: 0.35) }
    static var zone4StartTint: Self { .init(hex: 0xFF00B8, alpha: 0.35) }
    static var zone5StartTint: Self { .init(hex: 0xFF4003, alpha: 0.35) }
    
    // MARK: - GameProgressView
    
    static var ongoingText: Self { .init(hex: 0xDFDFDF) }
    static var ongoingNumber: Self { .white }
    static var inactiveZone: Self { .init(hex: 0x757575)}
    static var currentZoneStroke: Self { .init(hex: 0xB1B1B1) }
    static var currentZoneText: Self { .init(hex: 0xCACACA) }
    
<<<<<<< HEAD
    // MARK: - SummaryView
    static var columnTitle: Self { .init(hex: 0x474747) }
    static var columnContent: Self { .init(hex: 0x242424) }
=======
    // MARK: - SplitControlsView
    
    static var circleBackground: Self { .init(hex: 0xD9D9D9, alpha: 0.2) }
>>>>>>> 8b8397e (feat: [#22] 버튼이 둘로 나뉘는 SplitControlsView 생성)
}

extension ShapeStyle where Self == LinearGradient {
    
    // MARK: - SummaryView
    
    static var summaryGradient: Self {
        return .linearGradient(colors: [.white, .zone2Tint],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    // MARK: - HeartRate BPM
    
    static var zone1Bpm: Self {
        return .linearGradient(colors: [.zone1Tint, .white],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    static var zone2Bpm: Self {
        return .linearGradient(colors: [.zone2Tint, .white],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    static var zone3Bpm: Self {
        return .linearGradient(colors: [.zone3Tint, .white],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    static var zone4Bpm: Self {
        return .linearGradient(colors: [.zone4Tint, .white],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    static var zone5Bpm: Self {
        return .linearGradient(colors: [.zone5Tint, .white],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    // MARK: - HeartRate Current Zone Bar
    
    static var zone1CurrentZoneBar: Self {
        LinearGradient(stops: [
            .init(color: .zone1StartTint, location: 0.2),
            .init(color: .zone1Tint, location: 0.9)
        ], startPoint: .leading, endPoint: .trailing)
    }
    
    static var zone2CurrentZoneBar: Self {
        LinearGradient(stops: [
            .init(color: .zone2StartTint, location: 0.2),
            .init(color: .zone2Tint, location: 0.9)
        ], startPoint: .leading, endPoint: .trailing)
    }
    
    static var zone3CurrentZoneBar: Self {
        LinearGradient(stops: [
            .init(color: .zone3StartTint, location: 0.2),
            .init(color: .zone3MiddleTint, location: 0.25),
            .init(color: .zone3Tint, location: 0.95)
        ], startPoint: .leading, endPoint: .trailing)
    }
    
    static var zone4CurrentZoneBar: Self {
        LinearGradient(stops: [
            .init(color: .zone4StartTint, location: 0.2),
            .init(color: .zone4Tint, location: 0.9)
        ], startPoint: .leading, endPoint: .trailing)
    }
    
    static var zone5CurrentZoneBar: Self {
        LinearGradient(stops: [
            .init(color: .zone5StartTint, location: 0.2),
            .init(color: .zone5Tint, location: 0.9)
        ], startPoint: .leading, endPoint: .trailing)
    }
}
