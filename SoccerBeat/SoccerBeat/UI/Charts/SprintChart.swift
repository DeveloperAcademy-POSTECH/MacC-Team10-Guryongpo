//
//  SprintChart.swift
//  SoccerBeat
//
//  Created by Gucci on 11/12/23.
//

import SwiftUI
import Charts

struct SprintChart: View {
    var data: [Series] = sprintCountDummyData
    var body: some View {
        Chart {
            ForEach(data) { series in
                ForEach(0..<series.values.count, id: \.self) { index in
                    let element = series.values[index]
                    BarMark(
                        x: .value("Day", element.day, unit: .day),
                        yStart: .value("Values", 0.001),
                        yEnd: .value("Values", element.values),
                        width: .ratio(0.5)
                    )
                    .foregroundStyle(.zone1Bpm) // TODO: - max 면 틴트, 아니면 흰색
                    .cornerRadius(300, style: .continuous)
                    // MARK: - 데이터 표시
                    .annotation(position: .bottom, alignment: .center) {
                        if index.isMultiple(of: 2) {
                            Text("\(String(format: "%.0f", element.values))회")
                                .font(.caption2)
                        }
                    }
                }
            }
        }
        // MARK: - 가장 밑에 일자 표시
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { xValue in
                if xValue.index.isMultiple(of: 2) {
                    AxisValueLabel(format: .dateTime.day(), centered: true)
                }
            }
        }
        .chartYAxis(.hidden)
    }
}

struct SprintChartView: View {
    var body: some View {
        VStack(alignment: .leading) {
            Text("스프린트 횟수")
                .padding(.leading, 14)
            ZStack {
                LightRectangleView()
                    .frame(height: 200)
                    .overlay {
                        VStack {
                            Text("2023.10.02-2023.10.10")
                                .padding(.top, 14)
                            Spacer()
                            SprintChart()
                                .frame(height: 120)
                                .padding(.horizontal, 16)
                        }
                    }
            }
            
            LightRectangleView()
                .frame(height: 100)
                .overlay {
                    HStack {
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("최고 기록")
                            Text("2023.10.08")
                            Text("9회")
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            Text("최저 기록")
                            Text("2023.10.02")
                            Text("1회")
                        }
                        Spacer()
                    }
                }
        }
    }
}

#Preview {
    SprintChartView()
}
