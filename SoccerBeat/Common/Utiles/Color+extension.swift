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
    
    static var brightmint: Self { Self(hex: 0x03FFC3) }
    
    // MARK: - Capsule
    static var floatingCapsuleGray: Self { Self(hex: 0x757575, alpha: 0.4) }
    
    // MARK: - Sprint Progress
    
    static var gaugeBackground: Self { Self(hex: 0xD9D9D9, alpha: 0.3) }
    static var precountTint: Self { Self(hex: 0x0EB7FF, alpha: 0.95) }
    
    static var pauseTint: Self { Self(hex: 0x1CBBFF)}
    static var stopTint: Self { Self(hex: 0x4C67F4)}
    
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
    
    // MARK: - MainView
    
    static var mainDateTime: Self { .init(hex: 0xD4D4D4)}
    static var mainMatchTime: Self { .init(hex: 0xE3E3E3)}
    static var seeAllMatch: Self { .init(hex: 0x565656)}
    static var mainSubTitleColor: Self { .init(hex: 0xB4B4B4) }
    
    // MARK: - EmptyDataView
    static var subInfomational: Self { .init(hex: 0xC0C0C1) }
    
    // MARK: - SummaryView
    
    static var columnTitle: Self { .init(hex: 0x474747) }
    static var columnContent: Self { .init(hex: 0x242424) }
    static var columnFoot: Self { .init(hex: 0xAEB4BF) }

    // MARK: - SplitControlsView
    
    static var circleBackground: Self { .init(hex: 0xD9D9D9, alpha: 0.2) }
    
    // MARK: - Navigation Title Style
    
    static var navigationSportyHead: Self { .init(hex: 0xB4B4B4) }
    static var navigationSportySpeedTitle: Self { .init(hex: 0xFFE603) }
    static var navigationSportyDistanceTitle: Self { .init(hex: 0x00B3FF) }
    static var navigationSportyBPMTitle: Self { .init(hex: 0x03FFC3) }
    static var navigationSportySprintTitle: Self { .init(hex: 0xFF007A) }
    
    // MARK: - In Chart Style
    
    static var durationStyle: Self { .init(hex: 0xD4D4D4) }
    static var maxValueStyle: Self { .init(hex: 0xFFFFFF) }
    static var defaultValueStyle: Self { .init(hex: 0xFFFFFF, alpha: 0.7) }
    static var maxDayStyle: Self { .init(hex: 0xFFFFFF) }
    static var defaultDayStyle: Self { .init(hex: 0xFFFFFF, alpha: 0.7) }
    static var playerCompareStyle: Self { .init(hex: 0xFFFFFF, alpha: 0.7) }
    static var averageTextStyle: Self { .init(hex: 0xFFFFFF) }
    static var chartBoxBackground: Self { .init(hex: 0x4A4A4A) }
        
    // MARK: - ShareView
    
    static var shareViewTitleTint: Self { .init(hex: 0x03FFC3)}
    static var shareViewSubTitleTint: Self { .init(hex: 0xB4B4B4)}
    static var shareViewCapsuleStroke: Self { .init(hex: 0x757575, alpha: 0.4) }
    
    // MARK: - SprintView
    
    static var SprintLeftColor: Self { .init(hex: 0x1A5AFF) }
    static var SprintOnRightColor: Self { .init(hex: 0xFF259B) }
    
    // MARK: - MatchDetailView
    
    static var matchDetailViewTitleColor: Self { .init(hex: 0xFF077E) }
    static var matchDetailViewSubTitleColor: Self { .init(hex: 0xB4B4B4) }
    static var matchDetailViewAverageStatColor: Self { .init(hex: 0x00FFE0) }
    
    static var raderMaximumColor: Self { .init(hex: 0x369EFF) }
    
    // MARK: - ToolTipView
    static var tooltipTextColor: Self { .init(hex: 0xABFFE6) }
    static var tooltipBackgroundColor: Self { .init(hex: 0x191919)}
    
}

extension ShapeStyle where Self == LinearGradient {
    
    // MARK: - PreCountView
    
    static var precountGradient: Self {
        return .linearGradient(colors: [.precountTint, .white], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    // MARK: - GameProgressView
    
    static var gameTimeGradient: Self {
        return .linearGradient(colors: [.zone2Tint, .SprintOnRightColor],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing
        )
    }
    
    // MARK: - SprintView
    
    static var sprintOffGradient: Self {
        return .linearGradient(colors: [.SprintLeftColor, .zone3Tint], startPoint: .leading, endPoint: .trailing)
    }
    
    static var sprintOnGradient: Self {
        return .linearGradient(colors: [.SprintLeftColor, .SprintOnRightColor], startPoint: .leading, endPoint: .trailing)
    }
    
    // MARK: - SummaryView
    
    static var summaryGradient: Self {
        return .linearGradient(colors: [.white, .zone2Tint],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    // MARK: - HeartRate BPM
    
    static var zone1Bpm: Self {
        .linearGradient(colors: [.zone1Tint, .white],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    static var zone2Bpm: Self {
        .linearGradient(colors: [.zone2Tint, .white],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    static var zone3Bpm: Self {
        .linearGradient(colors: [.zone3Tint, .white],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    static var zone4Bpm: Self {
        .linearGradient(colors: [.zone4Tint, .white],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    static var zone5Bpm: Self {
        .linearGradient(colors: [.zone5Tint, .white],
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
    
    // MARK: - Stop State
    
    static var stopCurrentZoneBar: Self {
        let start = Color(hex: 0x000000, alpha: 0.35)
        let end = Color(hex: 0x838383)
        return LinearGradient(stops: [
            .init(color: start, location: 0.2),
            .init(color: end, location: 0.9)
        ], startPoint: .leading, endPoint: .trailing)
    }
    
    static var stopBpm: Self {
        let start = Color(hex: 0x333333)
        return .linearGradient(colors: [start, .white],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    // MARK: - MatchTotalView
    
    static var matchTotalTitle: Self {
        let start = Color(hex: 0xFF00B8)
        return .linearGradient(colors: [start, .white],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    static var matchTotalSectionHeader: Self {
        let start = Color(hex: 0xFFFFFF)
        let end = Color(hex: 0xFFFFFF).opacity(0.5)
        return .linearGradient(colors: [start, end],
                               startPoint: .leading, endPoint: .trailing)
    }
    
    // MARK: - MatchDetailView
    
    static var matchDetailTitle: Self {
        let start = Color(hex: 0xFF007A)
        return .linearGradient(colors: [start, .white],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    // MARK: - GameProgressView
    static var playTimeNumber: Self {
        let start = Color(hex: 0x03FFC3)
        let end = Color(hex: 0xFFFFFF)
        return .linearGradient(colors: [start, end], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    // MARK: - Chart Default
    
    static var chartDefault: Self {
        let start = Color(hex: 0xFFFFFF)
        let end = Color(hex: 0xFFFFFF, alpha: 0.3)
        return .linearGradient(colors: [start, end], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    // MARK: - Speed Chart
    static var speedMax: Self {
        let start = Color(hex: 0xFFE603)
        let end = Color(hex: 0xFCFEFF, alpha: 0.3)
        return .linearGradient(colors: [start, end], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    static var speedMin: Self {
        let start = Color(hex: 0xFFFFFF, alpha: 0.3)
        let end = Color(hex: 0xFFE603)
        return .linearGradient(colors: [start, end], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    // MARK: - Distance Chart
    static var distanceMax: Self {
        let start = Color(hex: 0x00B3FF)
        let end = Color(hex: 0xFCFEFF, alpha: 0.8)
        return .linearGradient(colors: [start, end], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    static var distanceMin: Self {
        let start = Color(hex: 0xFFFFFF, alpha: 0.0)
        let end = Color(hex: 0x0EB7FF)
        return .linearGradient(colors: [start, end], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    // MARK: - BPM Chart
    static var bpmMax: Self {
        let start = Color(hex: 0x03FFC3)
        let end = Color(hex: 0xFCFEFF)
        return .linearGradient(colors: [start, end], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    static var bpmMin: Self {
        let start = Color(hex: 0xFFFFFF, alpha: 0.3)
        let end = Color(hex: 0x03FFC3)
        return .linearGradient(colors: [start, end], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    // MARK: - Sprint Chart
    static var sprintMax: Self {
        let start = Color.navigationSportySprintTitle
        let end = Color(hex: 0xFCFEFF, alpha: 0.8)
        return .linearGradient(colors: [start, end], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    
    static var sprintMin: Self {
        let start = Color(hex: 0xFF007A, alpha: 0.0)
        let end = Color(hex: 0xFF007A)
        return .linearGradient(colors: [start, end], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}
