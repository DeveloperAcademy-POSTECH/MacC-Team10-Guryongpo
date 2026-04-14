//
//  DistanceChartOverview.swift
//  SoccerBeat
//
//  Created by Gucci on 11/17/23.
//

import SwiftUI
import Charts

struct DistanceChartOverview: View {
    let workouts: [WorkoutData]
    
    var body: some View {
        Chart {
            ForEach(0..<workouts.count, id: \.self) { index in
                let workout = workouts[index]
                let isLast = index == (workouts.count - 1)
                BarMark(
                    x: .value("Order", index),
                    yStart: .value("Distance", 0.0),
                    yEnd: .value("Distance", workout.distance)
                )
                .foregroundStyle(isLast ? .distanceMax : .chartDefault)
                .cornerRadius(300, style: .continuous)
            }
        }
        // MARK: - 가장 밑에 일자 표시
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
    }
}

#Preview {
    DistanceChartOverview(workouts: WorkoutData.exampleWorkouts)
}
