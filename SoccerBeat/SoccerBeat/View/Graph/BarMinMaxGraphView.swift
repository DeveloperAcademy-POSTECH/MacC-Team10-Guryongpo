//
//  BarMinMaxGraphView.swift
//  SoccerBeat
//
//  Created by jose Yun on 10/22/23.
//

import SwiftUI
import Charts

struct BarMinMaxGraphView: View {
    var body: some View {
            Chart {
                ForEach(HeartBeatlast12Months, id: \.month) {
                    BarMark(
                        x: .value("Month", $0.month, unit: .month),
                        yStart: .value("Min Sales", $0.dailyMin),
                        yEnd: .value("Max Sales", $0.dailyMax),
                        width: .ratio(0.6)
                    ).cornerRadius(16.5)
                        .opacity(0.6)
                    RectangleMark(
                        x: .value("Month", $0.month, unit: .month),
                        y: .value("Values", $0.dailyAverage),
                        width: .ratio(0.6),
                        height: .fixed(2)
                    )
                }
                .foregroundStyle(.pink)
                
            }
            .chartXAxis(.hidden)
        }
}

#Preview {
    BarMinMaxGraphView()
}
