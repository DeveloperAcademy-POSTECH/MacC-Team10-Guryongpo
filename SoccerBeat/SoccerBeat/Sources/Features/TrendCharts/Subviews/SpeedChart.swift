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
                            InformationButton(message: "최근 최고 속도의 변화입니다.")
                            Text("최고 속도")
                                .font(.navigationSportySubTitle)
                                .foregroundStyle(.navigationSportyHead)
                            Text("The trends of")
                            Text("Maximum Speed")
                                .foregroundStyle(.navigationSportySpeedTitle)
                                .highlighter(activity: .speed, isDefault: false)
                        }
                        .font(.navigationSportyTitle)
                        
                        Spacer()
                    }
                    
                    
                    speedChartView(fastest: fastest, slowest: slowest)
                    
                    averageSpeedView
                        .padding(.top, 30)
                    
                    Spacer()
                }
                .padding()
            }
    }
}

struct SpeedChart: View {
    let workouts: [WorkoutData]
    let fastestWorkout: WorkoutData
    let slowestWorkout: WorkoutData
    let averageSpeed: Double
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
                            Text(workout.velocity.rounded())
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
        var zeroVelocityCount = 0
        workouts.forEach { workout in
            if workout.velocity != 0 {
                velocitySum += workout.velocity
            } else {
                zeroVelocityCount += 1
            }
        }
        
        // 속도가 0이었던 경기는 계산하지 않습니다.
        if workouts.count - zeroVelocityCount == 0 {
            return 0
        } else {
            return velocitySum / (Double(workouts.count) - Double(zeroVelocityCount))
        }
        
    }
}

// MARK: - UI
extension SpeedChartView {
    
    private func speedChartView(fastest: WorkoutData, slowest: WorkoutData) -> some View {
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
                                Text("단위: km/h")
                            }
                            .font(.durationStyle)
                            .foregroundStyle(.defaultDayStyle)
                        }
                        
                        Spacer()
                        SpeedChart(
                            workouts: workouts,
                            fastestWorkout: fastest,
                            slowestWorkout: slowest,
                            averageSpeed: average(of: workouts)
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
    private var averageSpeedView: some View {
        let player = FileLoader.topSpeed.randomElement()
        
        let topSpeedMessage = String(
            format: "%@의 최고 속도는 %@km/h입니다.".localized(),
            player?.name ?? "Lionel Messi",
            player?.topSpeed ?? "33.2"
        )
        
        LightRectangleView(color: .chartBoxBackground.opacity(0.4))
            .frame(height: 120)
            .overlay {
                VStack(spacing: 16) {
                    Text(topSpeedMessage)
                        .font(.playerComapareSaying)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.playerCompareStyle)
                    
                    Text("최근 경기 평균")
                        .font(.averageText)
                        .foregroundStyle(.averageTextStyle)
                    Group {
                        if !workouts.isEmpty {
                            Text(average(of: workouts).rounded(at: 1))
                            + Text(" km/h")
                        } else {
                            Text("--")
                            + Text(" km/h")
                        }
                    }
                    .font(.averageValue)
                    .foregroundStyle(.navigationSportySpeedTitle)
                }
            }
    }
}

#Preview {
    NavigationStack {
        SpeedChartView(workouts: WorkoutData.exampleWorkouts)
    }
}
