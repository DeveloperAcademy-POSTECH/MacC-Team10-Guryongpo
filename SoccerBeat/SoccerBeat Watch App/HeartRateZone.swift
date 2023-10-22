//
//  HeartRateZone.swift
//  SoccerBeat Watch App
//
//  Created by Gucci on 10/22/23.
//

import SwiftUI

enum HeartRateZone: Int {
    case one = 1, two, three, four, five
    
    var text: String {
        return "zone".uppercased() + "\(self.rawValue)"
    }
}

extension HeartRateZone {
    var zoneGradient: LinearGradient {
        var start: Color = .black
        
        switch self {
        case .one:
            start = .init(hex: 0xFFE603, alpha: 0.35)
        case .two:
            start = .init(hex: 0x03B3FF, alpha: 0.35)
        case .three:
            start = .init(hex: 0x03B3FF, alpha: 0.35)
        case .four:
            start = .init(hex: 0xFF00B8, alpha: 0.35)
        case .five:
            start = .init(hex: 0xFF4003, alpha: 0.35)
        }
        
        var gradient = LinearGradient(stops: [
            .init(color: start, location: 0.2),
            .init(color: tintColor, location: 0.9)
        ], startPoint: .leading, endPoint: .trailing)
        if self == .three {
            start = Color(hex: 0x03B3FF, alpha: 0.35)
            let middle = Color(hex: 0x03BBF9, alpha: 0.4109)
            let end = tintColor
            gradient = LinearGradient(stops: [
                .init(color: start, location: 0.2),
                .init(color: middle, location: 0.25),
                .init(color: end, location: 0.95)
            ], startPoint: .leading, endPoint: .trailing)
        }
        return gradient
    }
    
    var heartRateGradient: LinearGradient {
        return .linearGradient(colors: [tintColor, .white],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

private extension HeartRateZone {
    var tintColor: Color {
        var tintHexacode: UInt = 0xFFFFFF
        switch self {
        case .one:
            tintHexacode = 0xFFE603
        case .two:
            tintHexacode = 0x03B3FF
        case .three:
            tintHexacode = 0x03FFC3
        case .four:
            tintHexacode = 0xFF00B8
        case .five:
            tintHexacode = 0xFF4003
        }
        return .init(hex: tintHexacode)
    }
}
