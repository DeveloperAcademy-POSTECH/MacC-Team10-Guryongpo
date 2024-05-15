//
//  SpeedChart.swift
//  SoccerBeat
//
//  Created by jose Yun on 10/22/23.
//

import Charts
import SwiftUI

struct SpeedChartView: View {
    let workouts: [WorkoutData]
    private var startDate: String {
        workouts.first?.yearMonthDay ?? "2023.10.10"
    }
    private var endDate: String {
        workouts.last?.yearMonthDay ?? "2023.10.10"
    }
    
    var body: some View {
        let fastest = maximum(of: workouts)
        let slowest = minimum(of: workouts)
        
        return VStack(alignment: .leading) {
            HStack {
                InformationButton(message: "최근 최고 속도의 변화입니다.")
                
                Spacer()
            }
            .padding(.top, 54)
            
            VStack(alignment: .leading) {
                Text("최대 속도")
                    .font(.navigationSportySubTitle)
                    .foregroundStyle(.navigationSportyHead)
                Text("The trends of")
                Text("Maximum Speed")
                    .foregroundStyle(.navigationSportySpeedTitle)
                    .highlighter(activity: .speed, isDefault: false)
            }
            .font(.navigationSportyTitle)
            .padding(.top, 32)
            
            speedChartView(fastest: fastest, slowest: slowest)
            
            Spacer()
                .frame(height: 30)
            
            averageSpeedView
                .padding(.horizontal, 48)
            
            Spacer()
        }
        .padding()
    }
}

struct SpeedChart: View {
    let workouts: [WorkoutData]
    let fastestWorkout: WorkoutData
    let slowestWorkout: WorkoutData
    let averageSpeed: Double
    let betweenBarSpace = 70.0
    
    
    private func isMax(_ workout: WorkoutData) -> Bool {
        workout == fastestWorkout
    }
    
    private func isMin(_ workout: WorkoutData) -> Bool {
        workout == slowestWorkout
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
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
                    // MARK: - 가장 밑에 일자 표시, 실제 보이는 용
                    .annotation(position: .bottom, alignment: .center) {
                        let isMaxOrMin = isMin(workout) || isMax(workout)
                        VStack(spacing: 6) {
                            Text(workout.velocity.rounded() + " km/h")
                                .font(.maxValueUint)
                                .foregroundStyle(.maxValueStyle)
                                .opacity(isMaxOrMin ? 1.0 : 0.5)
                                .padding(.top, 8)
                            
                            HStack(spacing: 0) {
                                Text("\(workout.day)")
                                Text("일")
                            }
                                .font(isMaxOrMin ? .maxDayUnit : .defaultDayUnit)
                                .foregroundStyle(.defaultDayStyle)
                        }
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
            .frame(width: CGFloat(workouts.count) * betweenBarSpace)
        }
        .backport.defaultScrollAnchor(.trailing)
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
        LightRectangleView(color: .chartBoxBackground.opacity(0.4))
            .frame(height: 200)
            .overlay {
                VStack {
                    
                    Text("\(startDate) - \(endDate)")
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
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 24)
            }
    }
    
    @ViewBuilder
    private var averageSpeedView: some View {
        LightRectangleView(color: .chartBoxBackground.opacity(0.4))
            .frame(height: 100)
            .overlay {
                VStack(spacing: 4) {
                    Text("음바페의 경기 최고 속도는 36km/h 입니다.")
                        .font(.playerComapareSaying)
                        .foregroundStyle(.playerCompareStyle)
                    Spacer()
                    Text("최근 경기 평균")
                        .font(.averageText)
                        .foregroundStyle(.averageTextStyle)
                    Group {
                        Text(average(of: workouts).rounded(at: 1))
                        + Text(" km/h")
                    }
                    .font(.averageValue)
                    .foregroundStyle(.navigationSportySpeedTitle)
                }
                .padding()
            }
    }
}

#Preview {
    NavigationStack {
        SpeedChartView(workouts: WorkoutData.exampleWorkouts)
    }
}
