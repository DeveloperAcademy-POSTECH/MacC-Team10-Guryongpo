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
                // MARK: - Bar Chart Data, value 표시
                .annotation(position: .bottom, alignment: .center) {
                    let isMaxOrMin = isMin(workout) || isMax(workout)
                    if  isMaxOrMin {
                        Text(workout.sprint, format: .number)
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
                
                Text("# 최근 경기에서 보인 스프린트 횟수의 추세입니다")
                    .floatingCapsuleStyle()
                    .padding(.leading, 16)
                
                Group {

                    Text("스프린트")
                        .font(.navigationSportySubTitle)
                        .foregroundStyle(.navigationSportyHead)
                    Text("The trends of")
                    Text("Sprint")
                        .foregroundStyle(.navigationSportySprintTitle)
                        .highlighter(activity: .sprint, isDefault: false)
                        .padding(.top, -30)
                }
                .font(.navigationSportyTitle)
                .padding(.leading, 32)
                
                sprintChartView(fastest: fastest, slowest: slowest)
                    .padding(.horizontal, 16)
                    .padding(.top, 34)
                
                averageSprintView
                    .padding(.top, 30)
                
                Spacer()
            }
        }
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
                    .foregroundStyle(.durationStyle)
                    
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
                        Text("음바페의 평균 스프린트 횟수는 21회 입니다.")
                    }
                    .font(.playerComapareSaying)
                    .foregroundStyle(.playerCompareStyle)
                    Text("최근 \(workouts.count) 경기 평균 스프린트")
                        .font(.averageText)
                        .foregroundStyle(.averageTextStyle)
                    Group {
                        Text(average(of: workouts).rounded())
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
