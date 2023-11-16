//
//  BPMChartOverview.swift
//  SoccerBeat
//
//  Created by Gucci on 11/17/23.
//

import SwiftUI
import Charts

struct BPMChartOverview: View {
    let workouts: [WorkoutData]
    
    var body: some View {
        Chart {
            ForEach(0..<workouts.count, id: \.self) { index in
                let workout = workouts[index]
                let isLast = index == (workouts.count - 1)
                BarMark(
                    x: .value("Order", index),
                    yStart: .value("HeartRate", workout.minHeartRate),
                    yEnd: .value("HeartRate", workout.maxHeartRate)
                )
                .foregroundStyle(isLast ? .bpmMax : .chartDefault)
                .cornerRadius(300, style: .continuous)
            }
        }
        // MARK: - 가장 밑에 일자 표시
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
    }
}

#Preview {
    BPMChartOverview(workouts: fakeWorkoutData)
}
