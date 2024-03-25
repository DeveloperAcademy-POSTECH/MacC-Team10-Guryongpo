//
//  SpeedChartOverview.swift
//  SoccerBeat
//
//  Created by Gucci on 11/16/23.
//

import SwiftUI
import Charts

struct SpeedChartOverview: View {
    let workouts: [WorkoutData]
    
    var body: some View {
        Chart {
            ForEach(0..<workouts.count, id: \.self) { index in
                let workout = workouts[index]
                let isLast = index == (workouts.count - 1)
                BarMark(
                    x: .value("Order", index),
                    yStart: .value("Velocity", 0.0),
                    yEnd: .value("Velocity", workout.velocity)
                )
                .foregroundStyle(isLast ? .speedMax : .chartDefault)
                .cornerRadius(300, style: .continuous)
            }
        }
        // MARK: - 가장 밑에 일자 표시
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
    }
}

#Preview {
    SpeedChartOverview(workouts: WorkoutData.exampleWorkouts)
}
