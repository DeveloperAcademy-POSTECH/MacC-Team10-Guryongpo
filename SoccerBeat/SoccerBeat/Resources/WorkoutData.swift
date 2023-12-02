//
//  WorkoutData.swift
//  SoccerBeat
//
//  Created by daaan on 11/1/23.
//

import Foundation
import CoreLocation

// All of the user's workout data.
struct WorkoutData: Hashable, Equatable, Identifiable {
    var id: UUID = UUID()
    var dataID: Int
    let date: String
    let time: String // Total play time in the match.
    let distance: Double // Total distance played during the match.
    let sprint: Int // Number of sprints during the match.
    let velocity: Double // Maximum speed during the match.. km/h
    let acceleration: Double // Maximum acceleration, velocity. m/s
    var heartRate: [String: Int] // min, max of heartRate. ex) ["max": 00, "min": 00]
    var route: [CLLocationCoordinate2D] // whole route
    var center: [Double] // center of heatmap
    var formattedDate: Date { dateFormatter.date(from: date) ?? Date() }
    var maxHeartRate: Int {
        heartRate["max", default: 110] // Maximum heart rate during the match.
    }
    var minHeartRate: Int {
        heartRate["min", default: 50] // Minimum heart rate during the match.
    }
  
    var matchBadge: [Int]

    var day: Int {
        let beforeT = String(date.split(separator: "T")[0])
        let splited = beforeT.split(separator: "-")[2]
        return Int(splited) ?? 0
    }
    var yearMonthDay: String {
        let beforeT = String(date.split(separator: "T")[0])
        let rawValueOfYearMonthDay = beforeT.split(separator: "-").joined(separator: ".")
        return String(rawValueOfYearMonthDay)
    }
    
    static let example = Self(dataID: 0,
                              date: "2023-10-09T01:20:32Z",
                              time: "34:43",
                              distance: 4.5,
                              sprint: 6,
                              velocity: 24.5,
                              acceleration: 3.0,
                              heartRate: ["max": 190, "min": 70],
                              route: [],
                              center: [37.58647414212885, 126.9748537678651],
                              matchBadge: [-1, 2, 0])
    
    static let blankExample = Self(dataID: 0,
                                   date: "2023-10-09T01:20:32Z",
                                   time: "34:43",
                                   distance: 0.1,
                                   sprint: 1,
                                   velocity: 0.5,
                                   acceleration: 1.0,
                                   heartRate: ["max": 80, "min": 60],
                                   route: [],
                                   center: [37.58647414212885, 126.9748537678651], matchBadge: [0, 0, 0])
    
    private let dateFormatter: ISO8601DateFormatter = {
        return ISO8601DateFormatter()
    }()
}

// Average of the user workout data.
struct WorkoutAverageData: Hashable, Equatable, Identifiable {
    var id: UUID = UUID()
    var maxHeartRate: Int // Maximum heart rate during the match.
    var minHeartRate: Int // Minimum heart rate during the match.
    var rangeHeartRate: Int // Range of heart rate during the match.
    var totalDistance: Double // Total distance played during the match.
    var maxAcceleration: Double // Maximum acceleration during the match.
    var maxVelocity: Double // Maximum speed during the match.
    var sprintCount: Int // Number of sprints during the match.
    var totalMatchTime: Int // Total play time in the match.
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
    WorkoutData(dataID: 1, date: "2023-10-09T01:20:32Z", time: "61:10", distance: 3.5, sprint: 3, velocity: 10.5, acceleration: 3.0, heartRate: ["max": 171, "min": 53], route: [], center: [0, 0], matchBadge: [0,3,2]),
    WorkoutData(dataID: 2, date: "2023-10-09T01:20:35Z", time: "62:10", distance: 2.1, sprint: 5, velocity: 11.5, acceleration: 3.0, heartRate: ["max": 152, "min": 70], route: [], center: [0, 0], matchBadge: [0,1,3]),
    WorkoutData(dataID: 3, date: "2023-10-09T01:20:38Z", time: "60:10", distance: 1.1, sprint: 7, velocity: 8.5, acceleration: 3.0, heartRate: ["max": 167, "min": 92], route: [], center: [0, 0], matchBadge: [-1,2,0]),
    WorkoutData(dataID: 4, date: "2023-10-19T01:20:32Z", time: "60:10", distance: 5.1, sprint: 9, velocity: 12.5, acceleration: 3.0, heartRate: ["max": 185, "min": 100], route: [], center: [0, 0], matchBadge: [-1,2,0]),
    WorkoutData(dataID: 5, date: "2023-10-20T01:20:32Z", time: "60:10", distance: 4.5, sprint: 11, velocity: 17.2, acceleration: 3.0, heartRate: ["max": 175, "min": 60], route: [], center: [0, 0], matchBadge: [-1,2,0]),
    WorkoutData(dataID: 6, date: "2023-10-21T01:20:32Z", time: "60:10", distance: 3.6, sprint: 5, velocity: 24.4, acceleration: 3.0, heartRate: ["max": 190, "min": 79], route: [], center: [0, 0], matchBadge: [-1,2,0]),
    WorkoutData(dataID: 7, date: "2023-10-23T01:20:32Z", time: "60:10", distance: 3.8, sprint: 13, velocity: 15.9, acceleration: 3.0, heartRate: ["max": 183, "min": 91], route: [], center: [0, 0], matchBadge: [-1,2,0]),
    WorkoutData(dataID: 8, date: "2023-10-24T01:20:32Z", time: "60:10", distance: 2.9, sprint: 17, velocity: 17.3, acceleration: 3.0, heartRate: ["max": 169, "min": 79], route: [], center: [0, 0], matchBadge: [-1,2,0]),
    WorkoutData(dataID: 9, date: "2023-10-27T01:20:32Z", time: "60:10", distance: 5.3, sprint: 12, velocity: 23.5, acceleration: 3.0, heartRate: ["max": 187, "min": 60], route: [], center: [0, 0], matchBadge: [-1,2,0])
]

let fakeAverageData: WorkoutAverageData = WorkoutAverageData(maxHeartRate: 180,
                                                             minHeartRate: 50,
                                                             rangeHeartRate: 5,
                                                             totalDistance: 2.0,
                                                             maxAcceleration: 5.8,
                                                             maxVelocity: 22.4,
                                                             sprintCount: 3,
                                                             totalMatchTime: 80)
