//
//  SprintChart.swift
//  SoccerBeat
//
//  Created by Gucci on 11/12/23.
//

import SwiftUI
import Charts

struct SprintChartView: View {
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
                InformationButton(message: "최근 스프린트 횟수의 변화입니다.")
                Spacer()
            }
            .padding(.top, 54)
            
            VStack(alignment: .leading) {
                Text("스프린트")
                    .font(.navigationSportySubTitle)
                    .foregroundStyle(.navigationSportyHead)
                Text("The trends of")
                Text("Sprint")
                    .foregroundStyle(.navigationSportySprintTitle)
                    .highlighter(activity: .sprint, isDefault: false)
            }
            .font(.navigationSportyTitle)
            .padding(.top, 32)
            
            sprintChartView(fastest: fastest, slowest: slowest)
            
            Spacer()
                .frame(height: 30)
            
            averageSprintView
                .padding(.horizontal, 48)
            
            Spacer()
        }
        .padding()
    }
}

struct SprintChart: View {
    let workouts: [WorkoutData]
    let fastestWorkout: WorkoutData
    let slowestWorkout: WorkoutData
    let averageSprint: Double
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
                        yStart: .value("Sprint", 0),
                        yEnd: .value("Sprint", workout.sprint)
                    )
                    .foregroundStyle(isMax(workout) ? .sprintMax
                                     : (isMin(workout) ? .sprintMin : .chartDefault))
                    .cornerRadius(300, style: .continuous)
                    // MARK: - Bar Chart Data, value 표시
                    // MARK: - 가장 밑에 일자 표시, 실제 보이는 용
                    .annotation(position: .bottom, alignment: .center) {
                        let isMaxOrMin = isMin(workout) || isMax(workout)
                        VStack(spacing: 6) {
                            HStack(spacing: 0) {
                                Text(workout.sprint.formatted())
                                Text("회")
                            }
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
        LightRectangleView(color: .chartBoxBackground.opacity(0.4))
            .frame(height: 200)
            .overlay {
                VStack {
                    
                    Text("\(startDate) - \(endDate)")
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
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 24)
            }
    }
    
    @ViewBuilder
    private var averageSprintView: some View {
        LightRectangleView(color: .chartBoxBackground.opacity(0.4))
            .frame(height: 100)
            .overlay {
                VStack(alignment: .center, spacing: 4) {
                    Text("음바페의 평균 스프린트 횟수는 21회 입니다.")
                        .font(.playerComapareSaying)
                        .foregroundStyle(.playerCompareStyle)
                    Spacer()
                    Text("최근 경기 평균")
                        .font(.averageText)
                        .foregroundStyle(.averageTextStyle)
                    Group {
                        Text(average(of: workouts).rounded(at: 0))
                        + Text(" 회")
                    }
                    .font(.averageValue)
                    .foregroundStyle(.navigationSportySprintTitle)
                }
                .padding()
            }
    }
}

#Preview {
    NavigationStack {
        SprintChartView(workouts: WorkoutData.exampleWorkouts)
    }
}
