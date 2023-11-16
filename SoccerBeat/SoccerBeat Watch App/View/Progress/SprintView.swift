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
    var body: some View {
        
        HStack {
            ZStack {
                RoundedRectangle(cornerRadius: 15.0)
                    .foregroundStyle(.gray)
                    .frame(height: 21)
                    .frame(maxWidth: .infinity)
                    .overlay {
                        ZStack {
                            ProgressView(value: workoutManager.speed, total: 22)
                                .progressViewStyle(GucciBarProgressStyle(accentGradient: workoutManager.isSprint ? .sprintOnGradient : .sprintOffGradient))
                                .padding(.horizontal, 2)
                            
                            HStack {
                                Spacer()
                                
                                if workoutManager.isSprint {
                                    Text("SPRINT!")
                                        .font(.sprintText)
                                        .padding(.horizontal)
                                } else {
                                    Text("LAST " + Measurement(value: workoutManager.recentSprintSpeed, unit: UnitSpeed.kilometersPerHour).formatted(.measurement(width: .narrow, usage: .general)))
                                        .font(.sprintText)
                                        .padding(.horizontal)
                                }
                            }
                            .padding(.horizontal)
                            .foregroundStyle(.black)
                        }
                    }
                    
            }
        }
        .padding(.vertical)
    }
}

struct GucciBarProgressStyle: ProgressViewStyle {
    
    let accentGradient: LinearGradient
    private let cornerRadius = CGFloat(10.0)
    private let height: Double = 16.0
    
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
