//
//  BPMChart.swift
//  SoccerBeat
//
//  Created by Gucci on 11/12/23.
//

import SwiftUI
import Charts

struct BPMChartView: View {
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
                InformationButton(message: "최근 심박수의 변화입니다.")
                Spacer()
            }
            .padding(.top, 54)
            
            VStack(alignment: .leading) {
                Text("심박수")
                    .font(.navigationSportySubTitle)
                    .foregroundStyle(.navigationSportyHead)
                Text("The trends of")
                Text("Heartbeat")
                    .foregroundStyle(.navigationSportyBPMTitle)
                    .highlighter(activity: .heartrate, isDefault: false)
            }
            .font(.navigationSportyTitle)
            .padding(.top, 32)
            
            BPMChartView(fastest: fastest, slowest: slowest)
            
            Spacer()
                .frame(height: 30)
            
            averageMaximumBpmView
                .padding(.horizontal, 48)
            
            Spacer()
        }
        .padding()
    }
}

struct BPMChart: View {
    let workouts: [WorkoutData]
    let fastestWorkout: WorkoutData
    let slowestWorkout: WorkoutData
    let averageBPM: Double
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
                        yStart: .value("HeartRate", 0),
                        yEnd: .value("HeartRate", workout.maxHeartRate)
                    )
                    .foregroundStyle(isMax(workout) ? .bpmMax
                                     : (isMin(workout) ? .bpmMin : .chartDefault))
                    .cornerRadius(300, style: .continuous)
                    // MARK: - Bar Chart Data, value 표시
                    // MARK: - 가장 밑에 일자 표시, 실제 보이는 용
                    .annotation(position: .bottom, alignment: .center) {
                        let isMaxOrMin = isMin(workout) || isMax(workout)
                        VStack(spacing: 6) {
                            Text(workout.maxHeartRate.formatted() + "Bpm")
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
        LightRectangleView(color: .chartBoxBackground.opacity(0.4))
            .frame(height: 200)
            .overlay {
                VStack {
                    
                    Text("\(startDate) - \(endDate)")
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
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 24)
            }
    }
    
    @ViewBuilder
    private var averageMaximumBpmView: some View {
        LightRectangleView(color: .chartBoxBackground.opacity(0.4))
            .frame(height: 100)
            .overlay {
                VStack(spacing: 4) {
                    Text("해리 케인의 평소 심박수는 40bpm 입니다.")
                        .font(.playerComapareSaying)
                        .foregroundStyle(.playerCompareStyle)
                    Spacer()
                    Text("최근 경기 평균")
                        .font(.averageText)
                        .foregroundStyle(.averageTextStyle)
                    Group {
                        Text(average(of: workouts).rounded(at: 0))
                        + Text(" Bpm")
                    }
                    .font(.averageValue)
                    .foregroundStyle(.navigationSportyBPMTitle)
                }
                .padding()
            }
    }
}

#Preview {
    NavigationStack {
        BPMChartView(workouts: WorkoutData.exampleWorkouts)
    }
}
