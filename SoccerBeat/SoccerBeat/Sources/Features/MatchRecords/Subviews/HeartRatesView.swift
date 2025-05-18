//
//  HeartRatesView.swift
//  SoccerBeat
//
//  Created by jose Yun on 8/20/24.
//

import Charts
import SwiftUI

struct HeartRatesView: View {
    let symbolSize: CGFloat = 30
    var rates: [Int] = [120, 100, 180, 130, 150, 120, 100, 180, 130, 150, 120, 100, 180, 130, 150]
    
    var body: some View {
            Chart(0..<rates.count, id: \.self) { count in
                PointMark(
                    x: .value("Time", count),
                    y: .value("BPM", rates[count])
                )
                .foregroundStyle(.zone2Bpm)
                .symbolSize(symbolSize)
            }
            .chartSymbolScale([
                "BPM": Circle()
                    .strokeBorder(lineWidth: 20)
            ])
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { _ in
                    AxisTick()
                    AxisGridLine()
                    AxisValueLabel(format: .dateTime.weekday(.narrow), centered: true)
                }
            }
            .chartYScale(domain: ((rates.min() ?? 50) - 10)...((rates.max() ?? 200) + 10))
            .chartYScale(range: .plotDimension(endPadding: 8))
            .chartXScale(range: .plotDimension(startPadding: 10, endPadding: 10))
    }
}

#Preview {
    HeartRatesView(rates: [120, 100, 180, 130, 150, 120, 100, 180, 130, 150, 120, 100, 180, 130, 150])
}
