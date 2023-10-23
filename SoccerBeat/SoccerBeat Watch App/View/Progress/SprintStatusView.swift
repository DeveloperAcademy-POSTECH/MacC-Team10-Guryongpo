//
//  SprintStatusView.swift
//  SoccerBeat Watch App
//
//  Created by Gucci on 10/22/23.
//

import SwiftUI

// MARK: - Sprint 정도를 표시하는 커스텀 프로그레스 뷰

struct SprintStatusView: View {
    let accentGradient: LinearGradient
    let sprintableCount: Int
    let restSprint: Int
    var progress: Double {
        Double(restSprint) / Double(sprintableCount)
    }
    
    var body: some View {
        ProgressView(value: progress, total: 1.0)
            .progressViewStyle(BarProgressStyle(accentGradient: accentGradient,
                                                maxAvailable: sprintableCount,
                                                restSprint: restSprint))
    }
}

#Preview {
    SprintStatusView(accentGradient: .zone1Bpm,
                     sprintableCount: 5,
                     restSprint: 3)
}

// MARK: - 커스텀 프로그레스 뷰 설정을 위한 코드

struct BarProgressStyle: ProgressViewStyle {
    
    let accentGradient: LinearGradient
    let maxAvailable: Int
    let restSprint: Int
    private let height: Double = 20.0
    private var isFull: Bool { maxAvailable == restSprint }
    
    func makeBody(configuration: Configuration) -> some View {
        
        let progress = configuration.fractionCompleted ?? 0.0
        
        GeometryReader { geometry in
            RoundedRectangle(cornerRadius: 10.0)
                .fill(.gaugeBackground)
                .frame(height: height)
                .overlay(alignment: .leading) {
                    if isFull {
                        RoundedRectangle(cornerRadius: 7.0)
                            .fill(accentGradient)
                            .padding(2)
                    } else {
                        UnevenRoundedRectangle(cornerRadii: .init(topLeading: 7.0,
                                                                  bottomLeading: 7.0,
                                                                  bottomTrailing: isFull ? 7.0 : 0.0,
                                                                  topTrailing: isFull ? 7.0 : 0.0))
                        .fill(accentGradient)
                        .frame(width: geometry.size.width * progress, height: height-5)
                        .padding(2)
                    }
                }
                .overlay {
                    HStack {
                        ForEach(0..<maxAvailable, id: \.self) { index in
                            Rectangle()
                                .fill(.white)
                                .frame(width: 1)
                                .opacity(index == 0 ? 0.0 : 1.0)
                            Spacer()
                        }
                    }
                }
        }
    }
}
