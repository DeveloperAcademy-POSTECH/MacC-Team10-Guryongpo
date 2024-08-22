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
        
        return VStack(alignment: .center) {
            HStack {
                VStack(alignment: .leading) {
                    InformationButton(message: "최근 뛴 거리의 변화입니다.")

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

                Spacer()
            }

            
            distanceChartView(fastest: fastest, slowest: slowest)
            
            averageDistanceView
                .padding(.horizontal, 48)
                .padding(.top, 30)

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
                if !workouts.isEmpty {
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
                }  else {
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
    private var averageDistanceView: some View {
        let player = FileLoader.distance.randomElement()

        let distanceMessage = String(
            format: "%@의 평균 활동량은 %@km입니다.".localized(),
            player?.name ?? "Lionel Messi",
            player?.distancePer90min ?? "7.2"
        )

        VStack(spacing: 16) {
            Text(distanceMessage)
                .multilineTextAlignment(.center)
                .font(.playerComapareSaying)
                .foregroundStyle(.playerCompareStyle)

            Text("최근 경기 평균")
                .font(.averageText)
                .foregroundStyle(.averageTextStyle)
            Group {
                if !workouts.isEmpty {
                    Text(average(of: workouts).rounded())
                    + Text(" km")
                } else {
                    Text("--")
                    + Text(" km")
                }
            }
            .font(.averageValue)
            .foregroundStyle(.navigationSportyDistanceTitle)
        }
        .padding()
        .overlay {
            LightRectangleView(color: .chartBoxBackground.opacity(0.4))
        }
    }
}

#Preview {
    NavigationStack {
        DistanceChartView(workouts: WorkoutData.exampleWorkouts)
    }
}
