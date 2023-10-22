//
//  BarGraphView.swift
//  SoccerBeat
//
//  Created by jose Yun on 10/22/23.
//

import SwiftUI
import Charts

struct BarGraphView: View {
    var body: some View {
            Chart(SprintDatalast30Days, id: \.day) {
                BarMark(
                    x: .value("Day", $0.day, unit: .day),
                    y: .value("Values", $0.values)
                ).foregroundStyle(Gradient(colors: [.cyan, .cyan, .white]))
                    .cornerRadius(8.0)
            }
            .chartYAxis(.hidden)
        }
}

#Preview {
    BarGraphView()
}
