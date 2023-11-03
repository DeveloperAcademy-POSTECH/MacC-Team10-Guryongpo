//
//  BarMinMaxGraphView.swift
//  SoccerBeat
//
//  Created by jose Yun on 10/22/23.
//

import SwiftUI
import Charts

struct BarMinMaxGraphView: View {
    @Binding var userWorkouts: [WorkoutData]?
    
    var graphType: GraphEnum
    
    private var mainColor: LinearGradient {
        switch graphType {
        case .distance:
            return .zone2Bpm
        case .sprint:
            return .zone3Bpm
        case .speed:
            return .zone1Bpm
        case .heartrate:
            return .zone4Bpm
        }
    }

    private func foo(_ workout: WorkoutData) -> Double {
        switch graphType {
        case .distance: return workout.distance
        case .heartrate: return Double(workout.heartRate["max", default: 0])
        case .speed: return workout.velocity
        case .sprint: return Double(workout.sprint)
        }
    }
    
    var body: some View {
            Chart {
                ForEach(userWorkouts ?? [], id: \.id) { workout in
                    BarMark(
                        x: .value("Month", workout.dataId ),
//                        yStart: .value("", graphType == .heartrate ?
//                                       workout.heartRate["min", default: 0] : 0),
//                        yEnd: .value("Max Sales", foo(workout)),
                        yStart: graphType == .heartrate ? CGFloat(workout.heartRate["min", default: 0]) : 0,
                        yEnd: foo(workout),
                        width: .ratio(0.6)
                    ).cornerRadius(16.5)
                        .opacity(0.6)
                }
                .foregroundStyle(mainColor)
            }
//            .chartYAxis {
//                AxisMarks() { _ in
//                    AxisGridLine().foregroundStyle(.clear)
//                    AxisTick().foregroundStyle(.clear)
//                }
//            }
//            .chartXAxis {
//                AxisMarks() { _ in
//                     AxisGridLine().foregroundStyle(.clear)
//                     AxisTick().foregroundStyle(.clear)
//                }
//            }
        }
}

//#Preview {
//    BarMinMaxGraphView(graphType: GraphEnum.distance)
//}
