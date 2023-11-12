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
    var dataID: Int
    let date: String
    let time: String
    let distance: Double // total distance
    let sprint: Int // sprint counter
    let velocity: Double // maximum velocity. km/h
    var heartRate: [String: Int] // min, max of heartRate. ex) ["max": 00, "min": 00]
    var route: [CLLocationCoordinate2D] // whole route
    var center: [Double] // center of heatmap
}

extension CLLocationCoordinate2D: Hashable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.latitude) 
    }
}

// MARK: - 현재 위치 받아오는 코드
extension WorkoutData {
    var location: String {
        get async {
            let centerLocation = CLLocation(latitude: center[0], longitude: center[1]).coordinate
            let loadedAddress =  await showCurrentAddress(centerLocation)
            return loadedAddress
        }
    }
    
    private func showCurrentAddress(_ location: CLLocationCoordinate2D?) async -> String {
        guard let position = location else { return "" }
        let locale = Locale(identifier: "Ko-kr")
        let geoCoder = CLGeocoder()
        
        let location : CLLocation = CLLocation(latitude: position.latitude, longitude: position.longitude)
        
        var currentAddress = ""
        guard let marker = try? await geoCoder.reverseGeocodeLocation(location, preferredLocale: locale).first
            else { return "" }
        
        if let locality = marker.locality {
            currentAddress += locality + " "
        }
        if let subLocality = marker.subLocality {
            currentAddress += subLocality + " "
        }
        return currentAddress
    }
}

let fakeWorkoutData: [WorkoutData] = [
    WorkoutData(dataID: 1, date: "1999-10-28", time: "60:10", distance: 8.5, location: "지곡동", sprint: 3, velocity: 8.5, heartRate: ["max": 83, "min": 81], route: [], center: [0, 0]),
    WorkoutData(dataID: 2, date: "2000-10-28", time: "60:10", distance: 8.5, location: "지곡동", sprint: 3, velocity: 8.5, heartRate: ["max": 83, "min": 81], route: [], center: [0, 0]),
    WorkoutData(dataID: 3, date: "2359-10-28", time: "60:10", distance: 8.5, location: "지곡동", sprint: 3, velocity: 8.5, heartRate: ["max": 83, "min": 81], route: [], center: [0, 0]),
    WorkoutData(dataID: 4, date: "1569-10-28", time: "60:10", distance: 8.5, location: "지곡동", sprint: 3, velocity: 8.5, heartRate: ["max": 83, "min": 81], route: [], center: [0, 0]),
    WorkoutData(dataID: 5, date: "2639-10-28", time: "60:10", distance: 8.5, location: "지곡동", sprint: 3, velocity: 8.5, heartRate: ["max": 83, "min": 81], route: [], center: [0, 0]),
    WorkoutData(dataID: 6, date: "5659-10-28", time: "60:10", distance: 8.5, location: "지곡동", sprint: 3, velocity: 8.5, heartRate: ["max": 83, "min": 81], route: [], center: [0, 0]),
    WorkoutData(dataID: 7, date: "1922-10-28", time: "60:10", distance: 8.5, location: "지곡동", sprint: 3, velocity: 8.5, heartRate: ["max": 83, "min": 81], route: [], center: [0, 0])
]
