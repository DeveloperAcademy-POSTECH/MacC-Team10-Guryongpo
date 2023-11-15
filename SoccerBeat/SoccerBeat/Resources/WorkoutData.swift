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
    
    static let example = Self(dataID: 0,
                              date: "2023.10.15",
                              time: "34:43",
                              distance: 4.5,
                              sprint: 6,
                              velocity: 24.5,
                              heartRate: ["max": 190, "min": 70],
                              route: [],
                              center: [37.58647414212885, 126.9748537678651])
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
    WorkoutData(dataID: 1, date: "2023.10.09", time: "60:10", distance: 3.5, sprint: 3, velocity: 10.5, heartRate: ["max": 83, "min": 81], route: [], center: [0, 0]),
    WorkoutData(dataID: 2, date: "2023.10.10", time: "60:10", distance: 2.1, sprint: 3, velocity: 11.5, heartRate: ["max": 83, "min": 81], route: [], center: [0, 0]),
    WorkoutData(dataID: 3, date: "2023.10.11", time: "60:10", distance: 1.1, sprint: 3, velocity: 8.5, heartRate: ["max": 83, "min": 81], route: [], center: [0, 0]),
    WorkoutData(dataID: 4, date: "2023.10.12", time: "60:10", distance: 5.1, sprint: 3, velocity: 12.5, heartRate: ["max": 83, "min": 81], route: [], center: [0, 0]),
    WorkoutData(dataID: 5, date: "2023.10.13", time: "60:10", distance: 4.5, sprint: 3, velocity: 17.2, heartRate: ["max": 83, "min": 81], route: [], center: [0, 0]),
    WorkoutData(dataID: 6, date: "2023.10.14", time: "60:10", distance: 3.6, sprint: 3, velocity: 24.4, heartRate: ["max": 83, "min": 81], route: [], center: [0, 0]),
    WorkoutData(dataID: 7, date: "2023.10.15", time: "60:10", distance: 3.8, sprint: 3, velocity: 15.9, heartRate: ["max": 83, "min": 81], route: [], center: [0, 0]),
    WorkoutData(dataID: 8, date: "2023.10.16", time: "60:10", distance: 2.9, sprint: 3, velocity: 17.3, heartRate: ["max": 83, "min": 81], route: [], center: [0, 0]),
    WorkoutData(dataID: 9, date: "2023.10.17", time: "60:10", distance: 5.3, sprint: 3, velocity: 23.5, heartRate: ["max": 83, "min": 81], route: [], center: [0, 0])
]
