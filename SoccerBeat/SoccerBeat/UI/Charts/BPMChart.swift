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
                    x: .value("Day", workout.formattedDate, unit: .day),
                    yStart: .value("HeartRate", workout.minHeartRate),
                    yEnd: .value("HeartRate", workout.maxHeartRate),
                    width: .ratio(0.5)
                )
                .foregroundStyle(isMax(workout) ? .bpmMax
                                 : (isMin(workout) ? .bpmMin : .chartDefault))
                .cornerRadius(300, style: .continuous)
                // MARK: - Min, Max 표시
                .annotation(position: .top, alignment: .center) {
                    if isMax(workout) {
                        Text(workout.maxHeartRate, format: .number)
                            .font(.maxHighlight)
                    }
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
                Spacer(minLength: 50)
                
                Text("# 나의 최고 심박수를 알아볼까요?")
                    .floatingCapsuleStyle()
                    .padding(.leading, -10)
                
                Group {
                    Text("MY heart beat")
                        .font(.navigationSportySubTitle)
                        .foregroundStyle(.navigationSportyHead)
                    Text("The quality of  a")
                    Text("FW (Bpm)")
                        .foregroundStyle(.navigationSportyBPMTitle)
                }
                .font(.navigationSportyTitle)
                
                BPMChartView(fastest: fastest, slowest: slowest)
                
                averageMaximumBpmView
                
                Spacer(minLength: 300)
            }
        }
        .padding(.horizontal, 28)
    }
}

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
                    .foregroundStyle(.durationUnit)
                    
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
            .padding(.horizontal, 16)
            .overlay {
                VStack(alignment: .center, spacing: 4) {
                    Group {
                        Text("박지성 선수의 평균 심박은")
                        Text("1분당 38회에서 40회 내외입니다.")
                    }
                    .opacity(0.7)
                    Text("\(workouts.count) 경기 평균 최고 심박")
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
