//
//  SprintChart.swift
//  SoccerBeat
//
//  Created by Gucci on 11/12/23.
//

import SwiftUI
import Charts

struct SprintChart: View {
    let workouts: [WorkoutData]
    let fastestWorkout: WorkoutData
    let slowestWorkout: WorkoutData
    let averageSprint: Double
    
    private func isMax(_ workout: WorkoutData) -> Bool {
        workout == fastestWorkout
    }
    
    private func isMin(_ workout: WorkoutData) -> Bool {
        workout == slowestWorkout
    }
    
    var body: some View {
        Chart {
            ForEach(0..<workouts.count, id: \.self) { index in
                let workout = workouts[index]
                
                BarMark(
                    x: .value("Order", index),
                    yStart: .value("Sprint", 0),
                    yEnd: .value("Sprint", workout.sprint)
                )
                .foregroundStyle(isMax(workout) ? .sprintMax
                                 : (isMin(workout) ? .sprintMin : .chartDefault))
                .cornerRadius(300, style: .continuous)
                // MARK: - Min, Max 표시
                .annotation(position: .top, alignment: .center) {
                    if isMax(workout) {
                        Text(workout.sprint, format: .number)
                            .font(.maxHighlight)
                    }
                }
                .annotation(position: .bottom, alignment: .center) {
                    Text(workout.monthDay)
                        .font(.system(size: 12))
                }
            }
        }
        // MARK: - 가장 밑에 일자 표시
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { _ in
                AxisValueLabel(format: .dateTime.day(), centered: true)
                    .font(.dayUnit)
            }
        }
        .chartYAxis(.hidden)
    }
}

struct SprintChartView: View {
    let workouts: [WorkoutData]
    private var startDate: String {
        workouts.first?.date ?? "2023.10.10"
    }
    private var endDate: String {
        workouts.last?.date ?? "2023.10.10"
    }
    var body: some View {
        let fastest = maximum(of: workouts)
        let slowest = minimum(of: workouts)
        
        return ZStack {
            BackgroundImageView()

            VStack(alignment: .leading) {
                Spacer(minLength: 50)
                
                Text("# 경기당 스프린트 횟수를 확인해볼까요?")
                    .floatingCapsuleStyle()
                    .padding(.leading, -10)
                
                Group {
                    Text("MY Sprint")
                        .font(.navigationSportySubTitle)
                        .foregroundStyle(.navigationSportyHead)
                    Text("The quality of  a")
                    Text("FW (Times)")
                        .foregroundStyle(.navigationSportySprintTitle)
                }
                .font(.navigationSportyTitle)
                
                sprintChartView(fastest: fastest, slowest: slowest)
                
                averageSprintView
                
                Spacer(minLength: 300)
            }
        }
        .padding(.horizontal, 28)
    }
}

extension SprintChartView: Analyzable {
    func maximum(of workouts: [WorkoutData]) -> WorkoutData {
        guard var maximumBPMWorkout = workouts.first else { return WorkoutData.example }
        for workout in workouts
        where maximumBPMWorkout.sprint < workout.sprint {
            maximumBPMWorkout = workout
        }
        return maximumBPMWorkout
    }
    
    func minimum(of workouts: [WorkoutData]) -> WorkoutData {
        guard var minimumBPMWorkout = workouts.first else { return WorkoutData.example }
        for workout in workouts
        where minimumBPMWorkout.sprint  > workout.sprint  {
            minimumBPMWorkout = workout
        }
        return minimumBPMWorkout
    }
    
    func average(of workouts: [WorkoutData]) -> Double {
        var maximumHeartRateSum = 0
        workouts.forEach { workout in
            maximumHeartRateSum += workout.sprint
        }
        return Double(maximumHeartRateSum) / Double(workouts.count)
    }
}

// MARK: - UI
extension SprintChartView {
    
    private func sprintChartView(fastest: WorkoutData, slowest: WorkoutData) -> some View {
        LightRectangleView()
            .frame(height: 200)
            .overlay {
                VStack {
                    Group {
                        Text("\(startDate)-\(endDate)")
                            .padding(.top, 14)
                        Text("(회)")
                    }
                    .font(.durationStyle)
                    .foregroundStyle(.durationUnit)
                    
                    Spacer()
                    SprintChart(
                        workouts: workouts,
                        fastestWorkout: fastest,
                        slowestWorkout: slowest,
                        averageSprint: average(of: workouts)
                    )
                    .frame(height: 120)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }
            }
    }
    
    @ViewBuilder
    private var averageSprintView: some View {
        LightRectangleView()
            .frame(height: 100)
            .padding(.horizontal, 16)
            .overlay {
                VStack(alignment: .center, spacing: 4) {
                    Group {
                        Text("음바페의 평균 스프린트 횟수는")
                        Text("21회입니다.")
                    }
                    .opacity(0.7)
                    Text("\(workouts.count) 경기 평균 스프린트")
                    Group {
                        Text(average(of: workouts).rounded(at: 0))
                        + Text("회")
                    }
                    .font(.averageValue)
                    .foregroundStyle(.navigationSportySprintTitle)
                }
            }
    }
}

#Preview {
    NavigationStack {
        SprintChartView(workouts: fakeWorkoutData)
    }
}
