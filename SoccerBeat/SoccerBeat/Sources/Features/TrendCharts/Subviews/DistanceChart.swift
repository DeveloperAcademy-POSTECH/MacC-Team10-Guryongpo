//
//  DistanceChart.swift
//  SoccerBeat
//
//  Created by Gucci on 11/12/23.
//

import SwiftUI
import Charts

struct DistanceChartView: View {
    @Environment(\.dismiss) private var dismiss

    let workouts: [WorkoutData]

    @State var scrollPositionStart: Date
    var scrollPositionEnd: Date {
        scrollPositionStart.addingTimeInterval(3600 * 24 * Constant.chartVisibleDays)
    }

    var scrollPositionString: String {
        scrollPositionStart.formatted(.dateTime.month().day())
    }

    var scrollPositionEndString: String {
        scrollPositionEnd.formatted(.dateTime.month().day().year())
    }

    init(workouts: [WorkoutData]) {
        self.workouts = workouts
        self.scrollPositionStart  =
        workouts.first?.formattedDate.addingTimeInterval(-1 * 3600 * 24 * Constant.chartVisibleDays) ?? Date()
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
                        
                        Spacer()
                    }

                    distanceChartView(fastest: fastest, slowest: slowest)

                    averageDistanceView
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

func generateDateRange(startDate: Date, endDate: Date) -> [Date] {
    var dates: [Date] = []
    var currentDate = startDate

    while currentDate <= endDate {
        dates.append(currentDate)
        currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
    }

    return dates
}

func date(year: Int, month: Int, day: Int = 1) -> Date {
    Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) ?? Date()
}

struct DistanceChart: View {
    let workouts: [WorkoutData]
    let fastestWorkout: WorkoutData
    let slowestWorkout: WorkoutData
    let averageDistance: Double
    let betweenBarSpace = 45.0
    @Binding var scrollPosition: Date

    private var allDaysAndMatchData: [(day: Date, distance: Double)] {
        guard let latestWorkout = workouts.first,
              let oldestWorkout = workouts.last else {
            return []
        }

        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: oldestWorkout.formattedDate)
        let endDate = calendar.startOfDay(for: latestWorkout.formattedDate)

        guard startDate <= endDate else { return [] }

        let dates = generateDateRange(startDate: startDate, endDate: endDate)

        let workoutDict: [Date: Double] = workouts.reduce(into: [:]) { dict, workout in
            let normalizedDate = calendar.startOfDay(for: workout.formattedDate)
            dict[normalizedDate] = workout.distance
        }

        return dates.map { date in
            (day: date, distance: workoutDict[date] ?? 0.0)
        }

        // for test
        /**
         return stride(from: 0, to: 200, by: 1).compactMap {
         let startDay: Date = date(year: 2024, month: 6, day: 17)  // 200 days before WWDC
         let day: Date = Calendar.current.date(byAdding: .day, value: $0, to: startDay)!
         let distance = Double.random(in: 1...10)
         return (
         day: day,
         distance: distance
         )
         }
         */

    }
    
    var body: some View {
        Chart {
            ForEach(allDaysAndMatchData, id: \.day) {
                BarMark(
                    x: .value("Day", $0.day, unit: .day),
                    y: .value("Distance", $0.distance)
                )
                .cornerRadius(300, style: .continuous)
            }
        }
        .chartScrollableAxes(.horizontal)
        // 보이는 X 축의 너비: 1 시간 * 24 * 7 => 7일
        .chartXVisibleDomain(length: 3600 * 24 * Constant.chartVisibleDays)
        // 한번에 땡기는 스크롤의 양의 크기 => 1주일씩 당기기,
        .chartScrollTargetBehavior(
            .valueAligned(
                matching: .init(hour: 0),
                majorAlignment: .matching(.init(weekday: 1))))
        .chartScrollPosition(x: $scrollPosition)
        // 보여지는 X 축 좌표의 마크 기준: 1일씩 표기하는데 `Weekday`만 표기
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 1)) {
                AxisTick()
                AxisGridLine()
                AxisValueLabel(format: .dateTime.weekday())
            }
        }
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
        var zeroDistanceCounts = 0
        workouts.forEach { workout in
            if workout.distance != 0 {
                distanceSum += workout.distance
            } else {
                zeroDistanceCounts += 1
            }
        }
        // 0 미터를 뛴 경기는 계산하지 않습니다.
        if workouts.count - zeroDistanceCounts == 0 {
            return 0
        } else {
            return distanceSum / (Double(workouts.count) - Double(zeroDistanceCounts))
        }
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
                        ZStack {
                            Text("\(scrollPositionString) - \(scrollPositionEndString)")
                                .font(.durationStyle)
                                .foregroundStyle(.durationStyle)
                            
                            HStack {
                                Spacer()
                                Text("단위: km")
                            }
                            .font(.durationStyle)
                            .foregroundStyle(.defaultDayStyle)
                        }
                        Spacer()
                        DistanceChart(
                            workouts: workouts,
                            fastestWorkout: fastest,
                            slowestWorkout: slowest,
                            averageDistance: average(of: workouts),
                            scrollPosition: $scrollPositionStart
                        )
                        .padding(.horizontal)
                    }
                    .padding(.horizontal, 20)
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
        LightRectangleView(color: .chartBoxBackground.opacity(0.4))
            .frame(height: 120)
            .overlay {
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
            }
    }
}

#Preview {
    NavigationStack {
        DistanceChartView(workouts: WorkoutData.exampleWorkouts)
    }
}
