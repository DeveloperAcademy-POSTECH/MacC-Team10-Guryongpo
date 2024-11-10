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
    private var endDate: String {
        workouts.first?.yearMonthDay ?? "2023.10.10"
    }
    private var startDate: String {
        workouts.last?.yearMonthDay ?? "2023.10.10"
    }
    var body: some View {
        Image("BackgroundPattern")
            .resizable()
            .scaledToFill()
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            .clipped()
            .opacity(0.5)
            .overlay {
                let fastest = maximum(of: workouts)
                let slowest = minimum(of: workouts)
                
                return VStack(alignment: .center) {
                    HStack {
                        VStack(alignment: .leading) {
                            Spacer()
                                .frame(height: 50)
                            InformationButton(message: "최근 심박수의 변화입니다.")
                            Text("심박수")
                                .font(.navigationSportySubTitle)
                                .foregroundStyle(.navigationSportyHead)
                            Text("The trends of")
                            Text("Heartbeat")
                                .foregroundStyle(.navigationSportyBPMTitle)
                                .highlighter(activity: .heartrate, isDefault: false)
                        }
                        .font(.navigationSportyTitle)
                        
                        Spacer()
                    }
                    
                    BPMChartView(fastest: fastest, slowest: slowest)
                    
                    averageMaximumBpmView
                        .padding(.top, 30)
                    
                    Spacer()
                }
                .padding()
            }
    }
}

struct BPMChart: View {
    let workouts: [WorkoutData]
    let fastestWorkout: WorkoutData
    let slowestWorkout: WorkoutData
    let averageBPM: Double
    let betweenBarSpace = 45.0
    
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
                        x: .value("Order", workouts.count - index),
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
                            Text(workout.maxHeartRate.formatted())
                                .font(.maxValueUint)
                                .foregroundStyle(.maxValueStyle)
                                .opacity(isMaxOrMin ? 1.0 : 0.5)
                                .padding(.top, 8)
                            
                            Text(workout.monthDay)
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
        var zeroHeartCounts = 0
        workouts.forEach { workout in
            if workout.maxHeartRate != 0 {
                maximumHeartRateSum += workout.maxHeartRate
            } else {
                zeroHeartCounts += 1
            }
        }
        
        // 심장이 안 뛴 날은 없다는 가정입니다!
        if workouts.count - zeroHeartCounts == 0 {
            return 0
        } else {
            return Double(maximumHeartRateSum) / (Double(workouts.count) - Double(zeroHeartCounts))
        }
    }
}

// MARK: - UI
extension BPMChartView {
    
    private func BPMChartView(fastest: WorkoutData, slowest: WorkoutData) -> some View {
        LightRectangleView(color: .chartBoxBackground.opacity(0.4))
            .frame(height: 200)
            .overlay {
                if !workouts.isEmpty {
                    VStack {
                        ZStack {
                            Text("\(startDate) - \(endDate)")
                                .font(.durationStyle)
                                .foregroundStyle(.durationStyle)
                            
                            HStack {
                                Spacer()
                                Text("단위: Bpm")
                            }
                            .font(.durationStyle)
                            .foregroundStyle(.defaultDayStyle)
                        }
                        Spacer()
                        BPMChart(
                            workouts: workouts,
                            fastestWorkout: fastest,
                            slowestWorkout: slowest,
                            averageBPM: average(of: workouts)
                        )
                        .frame(height: 120)
                        .padding(.horizontal)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                } else {
                    ZStack {
                        Image("MyCardBack")
                            .resizable()
                            .frame(width: 107, height: 140)
                            .opacity(0.3)
                        VStack {
                            Text("저장된 경기 기록이 없습니다.")
                                .font(.matchRecapEmptyDataTop)
                            Group {
                                Text("애플워치를 차고 사커비트로")
                                Text("당신의 첫 번째 경기를 기록해 보세요!")
                            }
                            .font(.matchRecapEmptyDataBottom)
                            .foregroundStyle(.mainSubTitleColor)
                        }
                    }
                    Spacer()
                }
            }
    }
    
    @ViewBuilder
    private var averageMaximumBpmView: some View {
        let player = FileLoader.heartRate.randomElement()
        
        let heartRateMessage = String(
            format: "%@의 결승골 득점시 심박수는 %@입니다.".localized(),
            player?.name ?? "Lionel Messi",
            player?.heartRate.gameWinningGoal ?? "175"
        )
        
        LightRectangleView(color: .chartBoxBackground.opacity(0.4))
            .frame(height: 120)
            .overlay {
                VStack(spacing: 16) {
                    Text(heartRateMessage)
                        .font(.playerComapareSaying)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.playerCompareStyle)
                    
                    Text("최근 경기 평균")
                        .font(.averageText)
                        .foregroundStyle(.averageTextStyle)
                    Group {
                        if !workouts.isEmpty {
                            Text(average(of: workouts).rounded(at: 0))
                            + Text(" Bpm")
                        } else {
                            Text("--")
                            + Text(" Bpm")
                        }
                    }
                    .font(.averageValue)
                    .foregroundStyle(.navigationSportyBPMTitle)
                }
            }
    }
}

#Preview {
    NavigationStack {
        BPMChartView(workouts: WorkoutData.exampleWorkouts)
    }
}
