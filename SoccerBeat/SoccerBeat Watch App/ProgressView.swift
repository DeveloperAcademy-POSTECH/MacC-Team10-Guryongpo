//
//  ProgressView.swift
//  SoccerBeat Watch App
//
//  Created by Gucci on 10/22/23.
//

import SwiftUI

struct ProgressView: View {
    enum HeartRateZone: Int {
        case one = 1, two, three, four, five
        
        var text: String {
            return "zone".uppercased() + "\(self.rawValue)"
        }
        
        private var tintColor: Color {
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
    // MARK: - Data
    let heartRate: Int
    private let runningDistance = "2.1KM"
    private let elapsedTime = "45 : 23"
    
    private var accentColor: Color {
        Color.blue
    }
    
    private var zone: HeartRateZone {
        switch heartRate {
        case ...80: return .one
        case ...100: return .two
        case ...120: return .three
        case ...140: return .four
        default: return .five
        }
    }
    
    var body: some View {
        VStack {
            // Zone Bar
            zoneBar
            
            // Heart Rate
            Group {
                Text(heartRate, format: .number)
                    .font(.system(size: 56).bold().italic())
                + Text(" bpm")
                    .font(.system(size: 28).bold().italic())
            }
            .foregroundStyle(zone.heartRateGradient)
            
            HStack(spacing: 30) {
                VStack {
                    Text(runningDistance)
                        .font(.caption.bold().italic())
                    Text("뛴 거리")
                        .foregroundStyle(Color(hex: 0xDFDFDF))
                }
                VStack {
                    Text(elapsedTime)
                        .font(.caption.bold().italic())
                    Text("경기 시간")
                        .foregroundStyle(Color(hex: 0xDFDFDF))
                }
            }
            Spacer()
        }
        .padding(.horizontal)
    }
}

#Preview {
    ProgressView(heartRate: 120)
}

// MARK: - Zone Bar

extension ProgressView {
    @ViewBuilder
    private var zoneBar: some View {
        let circleHeight = CGFloat(16.0)
        let currentZoneWidth = CGFloat(51.0)
        let circleColor = Color(hex: 0x757575)
        
        HStack {
            ForEach(1...5, id: \.self) { index in
                if zone.rawValue == index {
                    currentZone
                        .frame(width: currentZoneWidth, height: circleHeight)
                } else {
                    Circle()
                        .frame(width: circleHeight, height: circleHeight)
                        .foregroundStyle(circleColor)
                }
            }
        }
    }
    
    @ViewBuilder
    private var currentZone: some View {
        let circleHeight = CGFloat(16.0)
        let numberTextColor = Color(hex: 0xCACACA)
        let strokeColor = Color(hex: 0xB1B1B1)
        let strokeWidth = CGFloat(0.6)
        let roundedRectangle = RoundedRectangle(cornerRadius: circleHeight / 2)
        
        if #available(watchOS 10.0, *) {
            roundedRectangle
                .stroke(strokeColor, lineWidth: strokeWidth)
                .fill(zone.zoneGradient)
                .overlay {
                    Text(zone.text)
                        .font(.footnote)
                        .foregroundStyle(numberTextColor)
                }
        } else { // current watch version(9.0)
            roundedRectangle
                .strokeBorder(strokeColor, lineWidth: strokeWidth)
                .background(roundedRectangle.foregroundStyle(zone.zoneGradient))
                .overlay {
                    Text(zone.text)
                        .font(.footnote)
                        .foregroundStyle(numberTextColor)
                }
        }
    }
}
