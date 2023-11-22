//
//  BPMChart.swift
//  SoccerBeat
//
//  Created by Gucci on 11/12/23.
//

import SwiftUI
import Charts

struct BPMChart: View {
    let workouts: [WorkoutData]
    let fastestWorkout: WorkoutData
    let slowestWorkout: WorkoutData
    let averageBPM: Double
    
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
                    yStart: .value("HeartRate", workout.minHeartRate),
                    yEnd: .value("HeartRate", workout.maxHeartRate)
                )
                .foregroundStyle(isMax(workout) ? .bpmMax
                                 : (isMin(workout) ? .bpmMin : .chartDefault))
                .cornerRadius(300, style: .continuous)
                // MARK: - Bar Chart Data, value 표시
                .annotation(position: .bottom, alignment: .center) {
                    let isMaxOrMin = isMin(workout) || isMax(workout)

                    if  isMaxOrMin {
                        Text(workout.maxHeartRate, format: .number)
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

struct BPMChartView: View {
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
                
                Text("# 최근 경기에서 보인 심박수의 추세입니다")
                    .floatingCapsuleStyle()
                    .padding(.leading, 16)
                
                Group {
                    Text("심박수")
                        .font(.navigationSportySubTitle)
                        .foregroundStyle(.navigationSportyHead)
                    Text("The trends of")
                    Text("Heartbeat")
                        .foregroundStyle(.navigationSportyBPMTitle)
                        .highlighter(activity: .heartrate, isDefault: false)
                        .padding(.top, -30)
                }
                .font(.navigationSportyTitle)
                .padding(.leading, 32)
                
                BPMChartView(fastest: fastest, slowest: slowest)
                    .padding(.horizontal, 16)
                    .padding(.top, 34)
                
                averageMaximumBpmView
                    .padding(.top, 30)

                Spacer()
            }
        }
    }
}

// MARK: - Data Analyze Protocol
extension BPMChartView: Analyzable {
    func maximum(of workouts: [WorkoutData]) -> WorkoutData {
        guard var maximumBPMWorkout = workouts.first else { return WorkoutData.example }
        for workout in workouts
        where maximumBPMWorkout.maxHeartRate < workout.maxHeartRate {
            maximumBPMWorkout = workout
        }
        return maximumBPMWorkout
    }
    
    func minimum(of workouts: [WorkoutData]) -> WorkoutData {
        guard var minimumBPMWorkout = workouts.first else { return WorkoutData.example }
        for workout in workouts
        where minimumBPMWorkout.maxHeartRate  > workout.maxHeartRate  {
            minimumBPMWorkout = workout
        }
        return minimumBPMWorkout
    }
    
    func average(of workouts: [WorkoutData]) -> Double {
        var maximumHeartRateSum = 0
        workouts.forEach { workout in
            maximumHeartRateSum += workout.maxHeartRate
        }
        return Double(maximumHeartRateSum) / Double(workouts.count)
    }
}

// MARK: - UI
extension BPMChartView {
    
    private func BPMChartView(fastest: WorkoutData, slowest: WorkoutData) -> some View {
        LightRectangleView()
            .frame(height: 200)
            .overlay {
                VStack {
                    Group {
                        Text("\(startDate)-\(endDate)")
                            .padding(.top, 14)
                        Text("(BPM)")
                    }
                    .font(.durationStyle)
                    .foregroundStyle(.durationStyle)
                    
                    Spacer()
                    BPMChart(
                        workouts: workouts,
                        fastestWorkout: fastest,
                        slowestWorkout: slowest,
                        averageBPM: average(of: workouts)
                    )
                    .frame(height: 120)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 8)
                }
            }
    }
    
    @ViewBuilder
    private var averageMaximumBpmView: some View {
        LightRectangleView()
            .frame(height: 100)
            .padding(.horizontal, 61)
            .overlay {
                VStack(alignment: .center, spacing: 4) {
                    Group {
                        Text("해리 케인의 평소 심박수는 40bpm 입니다.")
                    }
                    .font(.playerComapareSaying)
                    .foregroundStyle(.playerCompareStyle)
                    
                    Text("최근 \(workouts.count) 경기 평균 최고 심박")
                        .font(.averageText)
                        .foregroundStyle(.averageTextStyle)
                    Group {
                        Text(average(of: workouts).rounded(at: 0))
                        + Text("Bpm")
                    }
                    .font(.averageValue)
                    .foregroundStyle(.navigationSportyBPMTitle)
                }
            }
    }
}

#Preview {
    NavigationStack {
        BPMChartView(workouts: fakeWorkoutData)
    }
}
