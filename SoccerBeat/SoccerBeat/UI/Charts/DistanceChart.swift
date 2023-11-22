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
                    yStart: .value("Distance", 0.0),
                    yEnd: .value("Distance", workout.distance)
                )
                .foregroundStyle(isMax(workout) ? .distanceMax 
                                 : (isMin(workout) ? .distanceMin : .chartDefault))
                .cornerRadius(300, style: .continuous)
                // MARK: - Bar Chart Data, value 표시
                .annotation(position: .bottom, alignment: .center) {
                    let isMaxOrMin = isMin(workout) || isMax(workout)
                    if isMaxOrMin {
                        Text(workout.distance.rounded())
                            .font(isMaxOrMin ? .maxValueUint : .defaultValueUnit)
                            .foregroundStyle(isMaxOrMin ? .maxValueStyle : .defaultValueStyle)
                            .offset(y: -7)
                    }
                }
                // MARK: - 가장 밑에 일자 표시, 실제 보이는 용
                .annotation(position: .bottom, alignment: .center) {
                    let isMaxOrMin = isMin(workout) || isMax(workout)
                    Text(workout.monthDay)
                        .font(isMaxOrMin ? .maxDayUnit : .defaultDayUnit)
                        .foregroundStyle(isMaxOrMin ? .maxDayStyle : .defaultDayStyle)
                        .offset(y: 7)
                }
            }
        }
        // MARK: - 가장 밑에 일자 표시, 자리잡기용
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { _ in
                AxisValueLabel(format: .dateTime.day(), centered: true)
                    .font(.defaultDayUnit)
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
                
                Text("# 최근 경기에서 보인 뛴 거리의 추세입니다")
                    .floatingCapsuleStyle()
                    .padding(.leading, 16)
                
                Group {

                    Text("활동량")
                        .font(.navigationSportySubTitle)
                        .foregroundStyle(.navigationSportyHead)
                    Text("The trends of")
                    Text("Distance")
                        .foregroundStyle(.navigationSportyDistanceTitle)
                        .highlighter(activity: .distance, isDefault: false)
                        .padding(.top, -30)
                }
                .font(.navigationSportyTitle)
                .padding(.leading, 32)
                
                distanceChartView(fastest: fastest, slowest: slowest)
                    .padding(.horizontal, 16)
                    .padding(.top, 34)
                
                averageDistanceView
                    .padding(.top, 30)

                Spacer()
            }
        }
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
                    .foregroundStyle(.durationStyle)
                    
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
            .padding(.horizontal, 61)
            .overlay {
                VStack(spacing: 4) {
                    Text("음바페의 경기 평균 활동량은 12km 입니다.")
                        .font(.playerComapareSaying)
                        .foregroundStyle(.playerCompareStyle)
                    Text("최근 \(workouts.count) 경기 평균")
                        .font(.averageText)
                        .foregroundStyle(.averageTextStyle)
                    Group {
                        Text(average(of: workouts).rounded())
                        + Text("km")
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
