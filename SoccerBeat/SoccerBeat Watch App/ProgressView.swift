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
            .foregroundStyle(.linearGradient(colors: [Color.init(hex: 0x03B3FF), .white],
                                             startPoint: .topLeading, endPoint: .bottomTrailing))
            
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
        
        HStack {
            ForEach(1...5, id: \.self) { index in
                if zone.rawValue == index {
                    currentZone
                        .frame(width: currentZoneWidth, height: circleHeight)
                } else {
                    Circle()
                        .frame(width: circleHeight, height: circleHeight)
                }
            }
            .foregroundStyle(Color(hex: 0x757575))
        }
    }
    
    @ViewBuilder
    private var currentZone: some View {
        let circleHeight = CGFloat(16.0)
        let start = Color(hex: 0x03B3FF, alpha: 0.35)
        let end = Color(hex: 0xFF00B8)
        let gradient = LinearGradient(stops: [
            .init(color: start, location: 0.2), .init(color: end, location: 0.9)
        ],
                                      startPoint: .leading, endPoint: .trailing)
        let roundedRectangle = RoundedRectangle(cornerRadius: circleHeight / 2)
        
        if #available(watchOS 10.0, *) {
            roundedRectangle
                .stroke(Color.init(hex: 0xB1B1B1), lineWidth: 0.6)
                .fill(gradient)
                .overlay {
                    Text(zone.text)
                        .font(.footnote)
                        .foregroundStyle(Color.init(hex: 0xCACACA))
                }
        } else { // current watch version(9.0)
            roundedRectangle
                .strokeBorder(Color.init(hex: 0xB1B1B1), lineWidth: 0.6)
                .background(roundedRectangle.foregroundStyle(gradient))
                .overlay {
                    Text(zone.text)
                        .font(.footnote)
                        .foregroundStyle(Color.init(hex: 0xCACACA))
                }
        }
    }
}
