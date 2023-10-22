//
//  GameProgressView.swift
//  SoccerBeat Watch App
//
//  Created by Gucci on 10/22/23.
//

import SwiftUI

struct GameProgressView: View {
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
    // MARK: - Body
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
            
            // Game Progress Information
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
            
            // Sprint Count Gague
            SprintStatusView(accentGradient: zone.heartRateGradient,
                             sprintableCount: 5,
                             restSprint: 4)
        }
        .padding(.horizontal)
    }
}

#Preview {
    GameProgressView(heartRate: 120)
}

// MARK: - Zone Bar

extension GameProgressView {
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
