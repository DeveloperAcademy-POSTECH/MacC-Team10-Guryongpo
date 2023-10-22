//
//  LineGraphView.swift
//  SoccerBeat
//
//  Created by jose Yun on 10/22/23.
//

import SwiftUI
import Charts

struct LineGraphView: View {
    var color: Color = Color.pink
    var data: [Series] = SpeedDummyData
    var body: some View {
            Chart {
                ForEach(data) { series in
                    ForEach(series.values, id: \.day) { element in
                        LineMark(
                            x: .value("Day", element.day, unit: .day),
                            y: .value("Values", element.values)
                        )
                    }
                    .foregroundStyle(color)
                    .symbol() { 
                        Circle()
                            .fill(color)
                            .frame(width: 6, height: 6)
                    }
                }
                .symbolSize(80)
                .lineStyle(StrokeStyle(lineWidth: 1))
            }
            .chartXAxis(.hidden)
            .chartLegend(.hidden)
    }
}

#Preview {
    LineGraphView()
}
