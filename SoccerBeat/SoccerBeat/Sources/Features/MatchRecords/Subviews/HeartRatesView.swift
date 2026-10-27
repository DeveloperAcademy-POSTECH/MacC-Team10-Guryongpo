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
    var rates: [Int]
    var dates: [Date] = []
    
    var body: some View {
            Chart(0..<rates.count, id: \.self) { count in
                if dates.count == rates.count {
                    PointMark(x: .value("Time", dates[count]), y: .value("BPM", rates[count]))
                        .foregroundStyle(.zone2Bpm)
                        .symbolSize(symbolSize)
                } else {
                    // Legacy metadata has values but no sample timestamps.
                    PointMark(x: .value("Sample", count), y: .value("BPM", rates[count]))
                        .foregroundStyle(.zone2Bpm)
                        .symbolSize(symbolSize)
                }
            }
            .chartSymbolScale([
                "BPM": Circle()
                    .strokeBorder(lineWidth: 20)
            ])
            .chartXAxis {
                AxisMarks(values: .automatic(desiredCount: 3)) { _ in
                    AxisTick()
                    AxisGridLine()
                    if dates.count == rates.count {
                        AxisValueLabel(format: .dateTime.hour().minute())
                    } else {
                        AxisValueLabel()
                    }
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
