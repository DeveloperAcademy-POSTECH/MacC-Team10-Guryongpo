//
//  SprintChartOverview.swift
//  SoccerBeat
//
//  Created by Gucci on 11/17/23.
//

import SwiftUI
import Charts

struct SprintChartOverview: View {
    let workouts: [WorkoutData]
    
    var body: some View {
        Chart {
            ForEach(0..<workouts.count, id: \.self) { index in
                let workout = workouts[index]
                let isLast = index == (workouts.count - 1)
                BarMark(
                    x: .value("Order", index),
                    yStart: .value("Sprint", 0),
                    yEnd: .value("Sprint", workout.sprint)
                )
                .foregroundStyle(isLast ? .sprintMax : .chartDefault)
                .cornerRadius(300, style: .continuous)
            }
        }
        // MARK: - 가장 밑에 일자 표시
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
    }
}

#Preview {
    SprintChartOverview(workouts: fakeWorkoutData)
}
