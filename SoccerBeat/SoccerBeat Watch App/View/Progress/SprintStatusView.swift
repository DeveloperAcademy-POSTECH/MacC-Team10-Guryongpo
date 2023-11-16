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
    private let cornerRadius = CGFloat(7.0)
    private let height: Double = 15.0
    private var isFull: Bool { maxAvailable == restSprint }
    
    func makeBody(configuration: Configuration) -> some View {
        
        let progress = configuration.fractionCompleted ?? .zero
        
        GeometryReader { geometry in
            RoundedRectangle(cornerRadius: 10.0)
                .fill(.gaugeBackground)
                .overlay(alignment: .leading) {
                    if isFull {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(accentGradient)
                            .padding(2)
                    } else {
                        let cornerRaddi =  RectangleCornerRadii(topLeading: cornerRadius,
                                                                bottomLeading: cornerRadius,
                                                                bottomTrailing: isFull ? cornerRadius : .zero,
                                                                topTrailing: isFull ? cornerRadius : .zero)
                        UnevenRoundedRectangle(cornerRadii: cornerRaddi)
                            .fill(accentGradient)
                            .frame(width: geometry.size.width * progress)
                    }
                }
                .overlay {
                    HStack {
                        ForEach(0..<maxAvailable, id: \.self) { index in
                            Rectangle()
                                .fill(.black)
                                .frame(width: 3)
                                .opacity(index == 0 ? .zero : .infinity)
                            Spacer()
                        }
                    }
                }
                .frame(height: height)
        }
    }
}
