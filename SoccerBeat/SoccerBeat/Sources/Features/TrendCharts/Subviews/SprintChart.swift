//
//  SprintChart.swift
//  SoccerBeat
//
//  Created by Gucci on 11/12/23.
//

import SwiftUI
import Charts

struct SprintChartView: View {
    @Environment(\.dismiss) private var dismiss

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
                                .frame(height: 60)
                            InformationButton(message: "최근 스프린트 횟수의 변화입니다.")
                            Text("스프린트")
                                .font(.navigationSportySubTitle)
                                .foregroundStyle(.navigationSportyHead)
                            Text("The trends of")
                            Text("Sprint")
                                .foregroundStyle(.navigationSportySprintTitle)
                                .highlighter(activity: .sprint, isDefault: false)
                        }
                        .font(.navigationSportyTitle)
                        
                        Spacer()
                    }
                    
                    sprintChartView(fastest: fastest, slowest: slowest)
                    
                    averageSprintView
                        .padding(.top, 30)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "chevron.backward")
                            .foregroundStyle(Color.white)
                    }
                }
            }
    }
}

struct SprintChart: View {
    let workouts: [WorkoutData]
    let fastestWorkout: WorkoutData
    let slowestWorkout: WorkoutData
    let averageSprint: Double
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
                            }
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
        var errorCount = 0
        workouts.forEach { workout in
            // 스프린트는 0번일 수 있으니, 에러가 없는 데이터만을 계산합니다.
            if !workout.error {
                maximumHeartRateSum += workout.sprint
            } else {
                errorCount += 1
            }
        }
        
        if workouts.count - errorCount == 0 {
            return 0
        } else {
            return Double(maximumHeartRateSum) / (Double(workouts.count) - Double(errorCount))
        }
    }
}

// MARK: - UI
extension SprintChartView {
    
    private func sprintChartView(fastest: WorkoutData, slowest: WorkoutData) -> some View {
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
                                Text("단위: 회")
                            }
                            .font(.durationStyle)
                            .foregroundStyle(.defaultDayStyle)
                        }
                        
                        Spacer()
                        SprintChart(
                            workouts: workouts,
                            fastestWorkout: fastest,
                            slowestWorkout: slowest,
                            averageSprint: average(of: workouts)
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
    private var averageSprintView: some View {
        let player = FileLoader.sprints.randomElement()
        
        let sprintsMessage = String(
            format: "%@의 평균 스프린트 횟수는 %@입니다.".localized(),
            player?.name ?? "Lionel Messi",
            player?.sprintCount ?? "13"
        )
        
        LightRectangleView(color: .chartBoxBackground.opacity(0.4))
            .frame(height: 120)
            .overlay {
                VStack(alignment: .center, spacing: 16) {
                    Text(sprintsMessage)
                        .font(.playerComapareSaying)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.playerCompareStyle)
                    
                    Text("최근 경기 평균")
                        .font(.averageText)
                        .foregroundStyle(.averageTextStyle)
                    Group {
                        if !workouts.isEmpty {
                            Text(average(of: workouts).rounded(at: 0))
                            + Text(" 회")
                        } else {
                            Text("--")
                            + Text(" 회")
                        }
                    }
                    .font(.averageValue)
                    .foregroundStyle(.navigationSportySprintTitle)
                }
            }
    }
}

#Preview {
    NavigationStack {
        SprintChartView(workouts: WorkoutData.exampleWorkouts)
    }
}
