//
//  SprintView.swift
//  SoccerBeat Watch App
//
//  Created by jose Yun on 10/30/23.
//

import SwiftUI
import HealthKit

struct SprintView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
    let accentGradient: LinearGradient
    var progress: Double
    var body: some View {
        
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 15.0)
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, maxHeight: 18)
                    .overlay {
                        ZStack {
                            ProgressView(value: progress, total: 22)
                                .progressViewStyle(GucciBarProgressStyle(accentGradient: accentGradient))
                                .padding(.horizontal, 5)
                            
                            HStack {
                                Text(Measurement(value: workoutManager.speed, unit: UnitSpeed.kilometersPerHour).formatted(.measurement(width: .narrow, usage: .general)))
                                    .padding(.horizontal)
                                    .bold()
                                    .italic()
                                Spacer()
                            }
                            .padding(.horizontal)
                            .foregroundStyle(.black)
                        }
                    }
            }
            Text(workoutManager.sprint.formatted(.number))
                .italic()
                .padding()
        }
        .padding(.horizontal)
    }
}

#Preview {
    SprintView(accentGradient: .zone1Bpm, progress: 3)
}

struct GucciBarProgressStyle: ProgressViewStyle {
    
    let accentGradient: LinearGradient
    private let cornerRadius = CGFloat(10.0)
    private let height: Double = 15.0
    
    func makeBody(configuration: Configuration) -> some View {
        
        let progress = configuration.fractionCompleted ?? .zero
        
        GeometryReader { geometry in
            ZStack {
                Color.clear
                RoundedRectangle(cornerRadius: 10.0)
                    .fill(.clear)
                    .overlay(alignment: .leading) {
                        let cornerRaddi =  RectangleCornerRadii(topLeading: cornerRadius,
                                                                bottomLeading: cornerRadius,
                                                                bottomTrailing: cornerRadius,
                                                                topTrailing: cornerRadius)
                        
                        UnevenRoundedRectangle(cornerRadii: cornerRaddi)
                            .fill(accentGradient)
                            .frame(width: geometry.size.width * progress)
                    }
                    .frame(maxWidth: .infinity, maxHeight: height)
            }
        }
    }
}
