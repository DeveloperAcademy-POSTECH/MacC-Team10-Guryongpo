//
//  SpeedChart.swift
//  SoccerBeat
//
//  Created by jose Yun on 10/22/23.
//

import SwiftUI
import Charts

struct SpeedChart: View {
    let workouts: [WorkoutData]
    let fastestWorkout: WorkoutData
    let slowestWorkout: WorkoutData
    let averageSpeed: Double
    
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
                    yStart: .value("Velocity", 0.1),
                    yEnd: .value("Velocity", workout.velocity)
                )
                .foregroundStyle(isMax(workout) ? .speedMax 
                                 : (isMin(workout) ? .speedMin : .chartDefault))
                .cornerRadius(300, style: .continuous)
                // MARK: - Min, Max 표시
                .annotation(position: .top, alignment: .center) {
                    if isMax(workout) {
                        Text(workout.velocity.rounded())
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

struct SpeedChartView: View {
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
                
                Text("# 나의 최고 속도를 찾아볼까요?")
                    .floatingCapsuleStyle()
                    .padding(.leading, -10)
                
                Group {
                    Text("MY speed")
                        .font(.navigationSportySubTitle)
                        .foregroundStyle(.navigationSportyHead)
                    Text("The quality of  a")
                    Text("FW (Km/h)")
                        .foregroundStyle(.navigationSportySpeedTitle)
                }
                .font(.navigationSportyTitle)
                
                speedChartView(fastest: fastest, slowest: slowest)
                
                averageSpeedView
                
                Spacer(minLength: 300)
            }
        }
        .padding(.horizontal, 28)
    }
}

// MARK: - Data Analyze Protocol
extension SpeedChartView: Analyzable {
    func maximum(of workouts: [WorkoutData]) -> WorkoutData {
        guard var maximumSpeedWorkout = workouts.first else { return WorkoutData.example }
        for workout in workouts where maximumSpeedWorkout.velocity < workout.velocity {
            maximumSpeedWorkout = workout
        }
        return maximumSpeedWorkout
    }
    
    func minimum(of workouts: [WorkoutData]) -> WorkoutData {
        guard var minimumSpeedWorkout = workouts.first else { return WorkoutData.example }
        for workout in workouts where minimumSpeedWorkout.velocity > workout.velocity {
            minimumSpeedWorkout = workout
        }
        return minimumSpeedWorkout
    }
    
    func average(of workouts: [WorkoutData]) -> Double {
        var velocitySum = 0.0
        workouts.forEach { workout in
            velocitySum += workout.velocity
        }
        return velocitySum / Double(workouts.count)
    }
}

// MARK: - UI
extension SpeedChartView {
    
    private func speedChartView(fastest: WorkoutData, slowest: WorkoutData) -> some View {
        LightRectangleView()
            .frame(height: 200)
            .overlay {
                VStack {
                    Group {
                        Text("\(startDate)-\(endDate)")
                            .padding(.top, 14)
                        Text("(KM)")
                    }
                    .font(.durationStyle)
                    .foregroundStyle(.durationUnit)
                    
                    Spacer()
                    SpeedChart(
                        workouts: workouts,
                        fastestWorkout: fastest,
                        slowestWorkout: slowest,
                        averageSpeed: average(of: workouts)
                    )
                    .frame(height: 120)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }
            }
    }
    
    @ViewBuilder
    private var averageSpeedView: some View {
        LightRectangleView()
            .frame(height: 100)
            .padding(.horizontal, 16)
            .overlay {
                VStack(spacing: 4) {
                    Text("해리케인의 평균 속도는 21 Km/h입니다.")
                        .opacity(0.7)
                    Text("\(workouts.count) 경기 평균")
                    Group {
                        Text(average(of: workouts), format: .number)
                        + Text("Km/h")
                    }
                    .font(.averageValue)
                    .foregroundStyle(.navigationSportySpeedTitle)
                }
            }
    }
}

#Preview {
    NavigationStack {
        SpeedChartView(workouts: fakeWorkoutData)
    }
}
