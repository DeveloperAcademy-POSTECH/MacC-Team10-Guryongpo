//
//  BarMinMaxGraphView.swift
//  SoccerBeat
//
//  Created by jose Yun on 10/22/23.
//

import SwiftUI
import Charts

struct BarMinMaxGraphView: View {
    var color: Gradient = Gradient(colors: [Color.pink])
    var data = HeartBeatlast12Months
    var body: some View {
            Chart {
                ForEach(data, id: \.month) {
                    BarMark(
                        x: .value("Month", $0.month, unit: .month),
                        yStart: .value("Min Sales", $0.dailyMin),
                        yEnd: .value("Max Sales", $0.dailyMax),
                        width: .ratio(0.6)
                    ).cornerRadius(16.5)
                        .opacity(0.6)
//                    RectangleMark(
//                        x: .value("Month", $0.month, unit: .month),
//                        y: .value("Values", $0.dailyAverage),
//                        width: .ratio(0.6),
//                        height: .fixed(2)
//                    )
                }
                .foregroundStyle(color)
            }
            .chartXAxis(.hidden)
        }
}

#Preview {
    BarMinMaxGraphView()
}
