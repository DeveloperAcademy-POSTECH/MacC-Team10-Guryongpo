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
                    yStart: .value("Velocity", 0.0),
                    yEnd: .value("Velocity", workout.velocity)
                )
                .foregroundStyle(isMax(workout) ? .speedMax 
                                 : (isMin(workout) ? .speedMin : .chartDefault))
                .cornerRadius(300, style: .continuous)
                // MARK: - Bar Chart Data, value 표시
                .annotation(position: .bottom, alignment: .center) {
                    let isMaxOrMin = isMin(workout) || isMax(workout)
                    if  isMaxOrMin {
                        Text(workout.velocity.rounded())
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
                
                Text("# 최근 경기에서 보인 최고 속도의 추세입니다")
                    .floatingCapsuleStyle()
                    .padding(.leading, 16)
                
                Group {
                    Text("최대 속도")
                        .font(.navigationSportySubTitle)
                        .foregroundStyle(.navigationSportyHead)

                    Text("The trends of")
                    Text("Maximum Speed")
                        .foregroundStyle(.navigationSportySpeedTitle)
                        .highlighter(activity: .speed, isDefault: false)
                        .padding(.top, -30)
                }
                .font(.navigationSportyTitle)
                .padding(.leading, 32)
                
                speedChartView(fastest: fastest, slowest: slowest)
                    .padding(.horizontal, 16)
                    .padding(.top, 34)
                
                averageSpeedView
                    .padding(.top, 30)
                
                Spacer()
            }
        }
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
                        Text("(km/h)")
                    }
                    .font(.durationStyle)
                    .foregroundStyle(.durationStyle)
                    
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
            .padding(.horizontal, 61)
            .overlay {
                VStack(spacing: 4) {
                    Text("음바페의 경기 최고 속도는 36Km/h입니다.")
                        .font(.playerComapareSaying)
                        .foregroundStyle(.playerCompareStyle)
                    Text("최근 \(workouts.count) 경기 평균")
                        .font(.averageText)
                        .foregroundStyle(.averageTextStyle)
                    Group {
                        Text(average(of: workouts).rounded(), format: .number)
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
