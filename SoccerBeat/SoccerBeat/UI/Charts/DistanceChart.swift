//
//  DistanceChart.swift
//  SoccerBeat
//
//  Created by Gucci on 11/12/23.
//

import SwiftUI
import Charts

struct DistanceChart: View {
    let workouts: [WorkoutData]
    let fastestWorkout: WorkoutData
    let slowestWorkout: WorkoutData
    let averageDistance: Double
    
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
                    yStart: .value("Distance", 0.01),
                    yEnd: .value("Distance", workout.distance)
                )
                .foregroundStyle(isMax(workout) ? .distanceMax 
                                 : (isMin(workout) ? .distanceMin : .chartDefault))
                .cornerRadius(300, style: .continuous)
                // MARK: - Min, Max 표시
                .annotation(position: .top, alignment: .center) {
                    if isMax(workout) {
                        Text(workout.distance.rounded())
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

struct DistanceChartView: View {
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
                
                Text("# 나의 최고 뛴 거리를 알아볼까요?")
                    .floatingCapsuleStyle()
                    .padding(.leading, -10)
                
                Group {
                    Text("MY distance")
                        .font(.navigationSportySubTitle)
                        .foregroundStyle(.navigationSportyHead)
                    Text("The quality of  a")
                    Text("MF (Km)")
                        .foregroundStyle(.navigationSportyDistanceTitle)
                }
                .font(.navigationSportyTitle)
                
                distanceChartView(fastest: fastest, slowest: slowest)
                
                averageDistanceView
                
                Spacer(minLength: 300)
            }
        }
        .padding(.horizontal, 28)
    }
}

extension DistanceChartView: Analyzable {
    func maximum(of workouts: [WorkoutData]) -> WorkoutData {
        guard var maximumDistanceWorkout = workouts.first else { return WorkoutData.example }
        for workout in workouts where maximumDistanceWorkout.distance < workout.distance {
            maximumDistanceWorkout = workout
        }
        return maximumDistanceWorkout
    }
    
    func minimum(of workouts: [WorkoutData]) -> WorkoutData {
        guard var minimumDistanceWorkout = workouts.first else { return WorkoutData.example }
        for workout in workouts where minimumDistanceWorkout.distance > workout.distance {
            minimumDistanceWorkout = workout
        }
        return minimumDistanceWorkout
    }
    
    func average(of workouts: [WorkoutData]) -> Double {
        var distanceSum = 0.0
        workouts.forEach { workout in
            distanceSum += workout.distance
        }
        return distanceSum / Double(workouts.count)
    }
}

// MARK: - UI
extension DistanceChartView {
    
    private func distanceChartView(fastest: WorkoutData, slowest: WorkoutData) -> some View {
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
                    DistanceChart(
                        workouts: workouts,
                        fastestWorkout: fastest,
                        slowestWorkout: slowest,
                        averageDistance: average(of: workouts)
                    )
                    .frame(height: 120)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }
            }
    }
    
    @ViewBuilder
    private var averageDistanceView: some View {
        LightRectangleView()
            .frame(height: 100)
            .padding(.horizontal, 16)
            .overlay {
                VStack(spacing: 4) {
                    Text("이강인의 평균 뛴 거리는 11Km입니다.")
                        .opacity(0.7)
                    Text("\(workouts.count) 경기 평균")
                    Group {
                        Text(average(of: workouts).rounded())
                        + Text("Km")
                    }
                    .font(.averageValue)
                    .foregroundStyle(.navigationSportyDistanceTitle)
                }
            }
    }
}

#Preview {
    NavigationStack {
        DistanceChartView(workouts: fakeWorkoutData)
    }
}
