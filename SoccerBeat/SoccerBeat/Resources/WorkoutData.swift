//
//  WorkoutData.swift
//  SoccerBeat
//
//  Created by daaan on 11/1/23.
//

import Foundation
import CoreLocation

struct WorkoutData: Hashable, Equatable, Identifiable {
    var id: UUID = UUID()
//    static func == (lhs: WorkoutData, rhs: WorkoutData) -> Bool {
//        lhs.dataId == rhs.dataId
//    }
//    var id: UUID = UUID()
    var dataId: Int // id
    let date: String
    let time: String
    let distance: Double // total distance
    let location: String
    let sprint: Int // sprint counter
    let calorie: Double // sprint counter
    let velocity: Double // maximum velocity
    var heartRate: [String: Int] // min, max of heartRate
//    var route: [CLLocationCoordinate2D] // whole route
//    var center: (Double, Double) // center of heatmap
}
