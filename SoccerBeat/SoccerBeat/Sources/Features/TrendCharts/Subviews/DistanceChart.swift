//
//  DistanceChart.swift
//  SoccerBeat
//
//  Created by Gucci on 11/12/23.
//

import SwiftUI
import Charts

// MARK: - Utilities

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.dateFormat = "yyyy.M.d"
    return formatter
}()

func generateDateRange(from start: Date, to end: Date) -> [Date] {
    var dates: [Date] = []
    var current = start
    while current <= end {
        dates.append(current)
        current = Calendar.current.date(byAdding: .day, value: 1, to: current)!
    }
    return dates
}

func date(year: Int, month: Int, day: Int = 1) -> Date {
    Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) ?? Date()
}

// MARK: - Main View

struct DistanceChartView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var rawSelectedDate: Date? = nil
    @State private var scrollPositionStart: Date

    let workouts: [WorkoutData]

    private var scrollPositionEnd: Date {
        scrollPositionStart.addingTimeInterval(3600 * 24 * Constant.chartVisibleDays)
    }
    private var scrollPositionString: String {
        dateFormatter.string(from: scrollPositionStart)
    }
    private var scrollPositionEndString: String {
        dateFormatter.string(from: scrollPositionEnd)
    }

    init(workouts: [WorkoutData]) {
        self.workouts = workouts
        self._scrollPositionStart = State(initialValue:
            workouts.first?.formattedDate.addingTimeInterval(-1 * 3600 * 24 * Constant.chartVisibleDays) ?? Date()
        )
    }

    var body: some View {
        let fastest = maximum(of: workouts)
        let slowest = minimum(of: workouts)

        VStack(alignment: .center) {
            HeaderView()
            DistanceChartSection(
                workouts: workouts,
                fastest: fastest,
                slowest: slowest,
                scrollPosition: $scrollPositionStart,
                rawSelectedDate: $rawSelectedDate,
                scrollPositionString: scrollPositionString,
                scrollPositionEndString: scrollPositionEndString
            )
        }
        .padding(.vertical)
        .background(
            Image("BackgroundPattern")
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .clipped()
                .opacity(0.5)
        )
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.backward")
                        .foregroundStyle(Color.white)
                }
            }
        }
    }
}

// MARK: - Header View

private struct HeaderView: View {
    var body: some View {
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
            Spacer()
        }
        .padding(.horizontal)
    }
}

// MARK: - Chart Section

private struct DistanceChartSection: View {
    let workouts: [WorkoutData]
    let fastest: WorkoutData
    let slowest: WorkoutData
    @Binding var scrollPosition: Date
    @Binding var rawSelectedDate: Date?
    let scrollPositionString: String
    let scrollPositionEndString: String

    var body: some View {
        if !workouts.isEmpty {
            List {
                VStack {
                    ChartInfoView(
                        average: average(of: workouts),
                        scrollPositionString: scrollPositionString,
                        scrollPositionEndString: scrollPositionEndString
                    )
                    DistanceChart(
                        workouts: workouts,
                        fastestWorkout: fastest,
                        slowestWorkout: slowest,
                        averageDistance: average(of: workouts),
                        scrollPosition: $scrollPosition,
                        rawSelectedDate: $rawSelectedDate
                    )
                    .frame(height: 240)
                    .padding(.top, 12)
                }
                .padding()
                .background(
                    LightRectangleView(
                        alpha: 0.6,
                        color: .black,
                        radius: 15
                    )
                )
            }
            .listStyle(.plain)
            .scrollDisabled(true)
        } else {
            EmptyChartView()
        }
    }

    func average(of workouts: [WorkoutData]) -> Double {
        let filtered = workouts.filter { $0.distance != 0 }
        guard !filtered.isEmpty else { return 0 }
        return filtered.map { $0.distance }.reduce(0, +) / Double(filtered.count)
    }
}

// MARK: - Chart Info View

private struct ChartInfoView: View {
    let average: Double
    let scrollPositionString: String
    let scrollPositionEndString: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text("평균 ")
                    .font(.sfProText(size: 14, weight: .light))
                + Text(average.rounded())
                    .font(.sfProText(size: 24, weight: .semiboldItalic))
                + Text(" km")
                    .font(.sfProText(size: 16, weight: .regularItalic))
                Spacer()
            }
            Text("\(scrollPositionString) - \(scrollPositionEndString)")
                .font(.sfProText(size: 10, weight: .light))
        }
        .foregroundStyle(Color(hex: 0xD4D4D4))
        .padding([.leading, .top], 20)
    }
}

// MARK: - Empty Chart View

private struct EmptyChartView: View {
    var body: some View {
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
    }
}

// MARK: - Distance Chart

struct DistanceChart: View {
    let workouts: [WorkoutData]
    let fastestWorkout: WorkoutData
    let slowestWorkout: WorkoutData
    let averageDistance: Double
    @Binding var scrollPosition: Date
    @Binding var rawSelectedDate: Date?
    @Environment(\.calendar) private var calendar

    private var allDaysAndMatchData: [(day: Date, distance: Double)] {
        guard let latest = workouts.first, let oldest = workouts.last else { return [] }
        let start = calendar.startOfDay(for: oldest.formattedDate)
        let end = calendar.startOfDay(for: latest.formattedDate)
        guard start <= end else { return [] }
        let dates = generateDateRange(from: start, to: end)
        let dict = workouts.reduce(into: [Date: Double]()) { dict, workout in
            let normalizedDate = calendar.startOfDay(for: workout.formattedDate)
            dict[normalizedDate, default: 0.0] += workout.distance
        }

        return dates.map { ($0, dict[$0] ?? 0.0) }
    }

    private func startOfDay(_ date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    private func endOfDay(_ date: Date) -> Date {
        calendar.date(bySettingHour: 23, minute: 59, second: 59, of: date)!
    }

    private var selectedDate: Date? {
        guard let selected = rawSelectedDate else { return nil }
        return workouts.first {
            let start = startOfDay($0.formattedDate)
            let end = endOfDay($0.formattedDate)
            return (start...end).contains(selected)
        }?.formattedDate
    }

    var body: some View {
        Chart {
            ForEach(allDaysAndMatchData, id: \.day) { entry in
                BarMark(
                    x: .value("Day", entry.day, unit: .day),
                    y: .value("Distance", entry.distance)
                )
                .foregroundStyle(.distanceMax)
                .cornerRadius(300, style: .continuous)
            }
            if let selectedDate {
                RuleMark(
                    x: .value("Selected", selectedDate, unit: .day)
                )
                .foregroundStyle(.clear)
                .offset(yStart: -10)
                .annotation(position: .top, overflowResolution: .init(x: .fit(to: .chart), y: .fit(to: .chart))) { _ in
                    if let distance = allDaysAndMatchData.first { tuple in
                        tuple.day == calendar.startOfDay(for: selectedDate)
                    }?.distance {
                        ValueSelectionPopover(
                            distance: distance,
                            selectedDate: selectedDate)
                    }
                }
            }
        }
        .chartScrollableAxes(.horizontal)
        .chartXVisibleDomain(length: 3600 * 24 * Constant.chartVisibleDays)
        .chartScrollTargetBehavior(
            .valueAligned(
                matching: .init(hour: 0),
                majorAlignment: .matching(.init(weekday: 1))
            )
        )
        .chartScrollPosition(x: $scrollPosition)
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 1)) {
                AxisTick()
                AxisGridLine()
                AxisValueLabel(format: .dateTime.weekday(.abbreviated), centered: true)
            }
        }
        .chartYAxis {
            AxisMarks(position: .trailing)
        }
        .chartLegend(.hidden)
        .chartXSelection(value: $rawSelectedDate)
    }
}

// MARK: - Value Selection Popover

private struct ValueSelectionPopover: View {
    let distance: Double
    let selectedDate: Date

    var body: some View {
        VStack(alignment: .leading) {
            Text(distance, format: .number)
                .font(.sfProText(size: 16, weight: .semiboldItalic))
            + Text(" km")
                .font(.sfProText(size: 14, weight: .regularItalic))
            Text(dateFormatter.string(from: selectedDate))
                .font(.sfProText(size: 9, weight: .light))
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 18)
        .background(Color(hex: 0x363636))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color(hex: 0x5B5555), lineWidth: 1)
        )
        .shadow(
            color: Color(hex: 0x7F7F7F, alpha: 0.25),
            radius: 10, x: 2, y: 3)
    }
}

// MARK: - Analyzable Extension

extension DistanceChartView: Analyzable {
    func maximum(of workouts: [WorkoutData]) -> WorkoutData {
        workouts.max(by: { $0.distance < $1.distance }) ?? WorkoutData.example
    }

    func minimum(of workouts: [WorkoutData]) -> WorkoutData {
        workouts.min(by: { $0.distance < $1.distance }) ?? WorkoutData.example
    }

    func average(of workouts: [WorkoutData]) -> Double {
        let filtered = workouts.filter { $0.distance != 0 }
        guard !filtered.isEmpty else { return 0 }
        return filtered.map { $0.distance }.reduce(0, +) / Double(filtered.count)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        DistanceChartView(workouts: WorkoutData.exampleWorkouts)
    }
}
