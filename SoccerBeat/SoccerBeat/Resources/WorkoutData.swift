//
//  WorkoutData.swift
//  SoccerBeat
//
//  Created by daaan on 11/1/23.
//

import Foundation
import CoreLocation

struct WorkoutTotalData: Hashable, Equatable, Identifiable {
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

struct WorkoutSpiderData: Hashable, Equatable, Identifiable {
    let id: UUID = UUID()
    let maxHeartRate: Int // Maximum heart rate during the match.
    let minHeartRate: Int // Minimum heart rate during the match.
    let rangeHeartRate: Int // Range of heart rate during the match.
    let totalDistance: Double // Total distance played during the match.
    let maxAcceleration: Int // Maximum acceleration during the match.
    let maxVelocity: Double // Maximum speed during the match.
    let sprintCount: Int // Number of sprints during the match.
    let totalMatchTime: Int // Total play time in the match.
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
