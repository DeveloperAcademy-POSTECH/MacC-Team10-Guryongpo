//
//  DistanceChart.swift
//  SoccerBeat
//
//  Created by Gucci on 11/12/23.
//

import SwiftUI
import Charts

struct DistanceChartView: View {
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
                InformationButton(message: "최근 뛴 거리의 변화입니다.")
                
                Spacer()
            }
            .padding(.top, 54)
            
            VStack(alignment: .leading) {
                Text("뛴 거리")
                    .font(.navigationSportySubTitle)
                    .foregroundStyle(.navigationSportyHead)
                Text("The trends of")
                Text("Distance")
                    .foregroundStyle(.navigationSportyDistanceTitle)
                    .highlighter(activity: .distance, isDefault: false)
            }
            .font(.navigationSportyTitle)
            .padding(.top, 32)
            
            distanceChartView(fastest: fastest, slowest: slowest)
            
            Spacer()
                .frame(height: 30)
            
            averageDistanceView
                .padding(.horizontal, 48)
            
            Spacer()
        }
        .padding()
    }
}

struct DistanceChart: View {
    let workouts: [WorkoutData]
    let fastestWorkout: WorkoutData
    let slowestWorkout: WorkoutData
    let averageDistance: Double
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
                        yStart: .value("Distance", 0.0),
                        yEnd: .value("Distance", workout.distance)
                    )
                    .foregroundStyle(isMax(workout) ? .distanceMax
                                     : (isMin(workout) ? .distanceMin : .chartDefault))
                    .cornerRadius(300, style: .continuous)
                    // MARK: - Bar Chart Data, value 표시
                    // MARK: - 가장 밑에 일자 표시, 실제 보이는 용
                    .annotation(position: .bottom, alignment: .center) {
                        let isMaxOrMin = isMin(workout) || isMax(workout)
                        VStack(spacing: 6) {
                            Text(workout.distance.rounded() + "km")
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
        LightRectangleView(color: .chartBoxBackground.opacity(0.4))
            .frame(height: 200)
            .overlay {
                VStack {
                    
                    Text("\(startDate) - \(endDate)")
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
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 24)
            }
    }
    
    @ViewBuilder
    private var averageDistanceView: some View {
        LightRectangleView(color: .chartBoxBackground.opacity(0.4))
            .frame(height: 100)
            .overlay {
                VStack(spacing: 4) {
                    Text("음바페의 경기 평균 뛴 거리는 12km 입니다.")
                        .font(.playerComapareSaying)
                        .foregroundStyle(.playerCompareStyle)
                    Spacer()
                    Text("최근 경기 평균")
                        .font(.averageText)
                        .foregroundStyle(.averageTextStyle)
                    Group {
                        Text(average(of: workouts).rounded())
                        + Text(" km")
                    }
                    .font(.averageValue)
                    .foregroundStyle(.navigationSportyDistanceTitle)
                }
                .padding()
            }
    }
}

#Preview {
    NavigationStack {
        DistanceChartView(workouts: WorkoutData.exampleWorkouts)
    }
}

