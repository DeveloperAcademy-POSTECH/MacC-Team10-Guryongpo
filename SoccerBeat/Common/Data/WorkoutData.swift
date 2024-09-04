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
    let time: String // == Total play time in the match.
    let distance: Double // Total distance played during the match.
    let sprint: Int // Number of sprints during the match.
    let velocity: Double // Maximum speed during the match.. km/h
    let power: Double // Maximum power, w
    // TODO: min, max 각각 프로퍼티로 나누기
    var heartRate: [String: Int] // min, max of heartRate. ex) ["max": 00, "min": 00]
    var heartRates: [Int]
    var route: [CLLocationCoordinate2D] // whole route
    var center: [Double] // center of heatmap
    var formattedDate: Date { dateFormatter.date(from: date) ?? Date() }
    var maxHeartRate: Int {
        heartRate["max", default: 110] // Maximum heart rate during the match.
    }
    var minHeartRate: Int {
        heartRate["min", default: 50] // Minimum heart rate during the match.
    }
    var calories: Int
    var vo2Max: Double
    
    var error = false
    
    var matchBadge: [Int] {
        // MARK: Badge 기준
        // Distance(km) : [1, 2, 3, 4]
        // Sprint(회) : [1, 3, 5, 7]
        // Velocity(km/h) : [10, 15, 20, 25]
        var badge = [0,0,0]

        if distance < 1 {
            badge[0] = -1
        } else if (1 <= distance && distance < 2) {
            badge[0] = 0
        } else if (2 <= distance && distance < 3) {
            badge[0] = 1
        } else if (3 <= distance && distance < 4) {
            badge[0] = 2
        } else {
            badge[0] = 3
        }

        if sprint < 1 {
            badge[1] = -1
        } else if (1 <= sprint && sprint < 3) {
            badge[1] = 0
        } else if (3 <= sprint && sprint < 5) {
            badge[1] = 1
        } else if (5 <= sprint && sprint < 7) {
            badge[1] = 2
        } else {
            badge[1] = 3
        }

        if velocity < 10 {
            badge[2] = -1
        } else if (10 <= velocity && velocity < 15) {
            badge[2] = 0
        } else if (15 <= velocity && velocity < 20) {
            badge[2] = 1
        } else if (20 <= velocity && velocity < 25) {
            badge[2] = 2
        } else {
            badge[2] = 3
        }

        return badge
    }
    
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
    
    var playtimeSec: Int {
        let separatedTime = time.components(separatedBy: ":")
        let separatedMinutes = separatedTime[0].trimmingCharacters(in: .whitespacesAndNewlines)
        let separatedSeconds = separatedTime[1].trimmingCharacters(in: .whitespacesAndNewlines)
        return (Int(separatedMinutes) ?? 0) * 60 + (Int(separatedSeconds) ?? 0)
    }
    
    static let example = Self(dataID: 0,
                              date: "2023-10-09T01:20:32Z",
                              time: "34:43",
                              distance: 4.5,
                              sprint: 6,
                              velocity: 24.5,
                              power: 3.0,
                              heartRate: ["max": 190, "min": 70],
                              heartRates: [100, 120, 130, 100, 120],
                              route: [],
                              center: [37.58647414212885, 126.9748537678651],
                              calories: 0,
                              vo2Max: 0,
                              error: true)
    
    static let blankExample = Self(dataID: 0,
                                   date: "0000-00-00T00:00:00Z",
                                   time: "00:00",
                                   distance: 0,
                                   sprint: 0,
                                   velocity: 0,
                                   power: 0,
                                   heartRate: ["max": 0, "min": 0],
                                   heartRates: [100, 120, 130, 100, 120],
                                   route: [],
                                   center: [0, 0],
                                   calories: 3,
                                   vo2Max: 3)
    
    // TODO: - Factory Method Pattern으로 빼내는건 어떨까요?
    static let exampleWorkouts = [
        WorkoutData(dataID: 1, date: "2023-10-09T01:20:32Z", time: "99:99", distance: 999.0, sprint: 999, velocity: 999.0, power: 999.0, heartRate: ["max": 999, "min": 1], heartRates: [100, 120, 130, 100, 120], route: [], center: [0, 0], calories: 0, vo2Max: 0),
        WorkoutData(dataID: 2, date: "2023-10-09T01:20:35Z", time: "62:10", distance: 2.1, sprint: 5, velocity: 11.5, power: 32.0, heartRate: ["max": 152, "min": 70], heartRates: [100, 120, 130, 100, 120], route: [], center: [0, 0], calories: 0, vo2Max: 0),
        WorkoutData(dataID: 3, date: "2023-10-09T01:20:38Z", time: "60:10", distance: 1.1, sprint: 7, velocity: 8.5, power: 97.0, heartRate: ["max": 167, "min": 92], heartRates: [100, 120, 130, 100, 120], route: [], center: [0, 0], calories: 0, vo2Max: 0),
        WorkoutData(dataID: 4, date: "2023-10-19T01:20:32Z", time: "60:10", distance: 5.1, sprint: 9, velocity: 12.5, power: 3.0, heartRate: ["max": 185, "min": 100], heartRates: [100, 120, 130, 100, 120], route: [], center: [0, 0], calories: 0, vo2Max: 0),
        WorkoutData(dataID: 5, date: "2023-10-20T01:20:32Z", time: "60:10", distance: 4.5, sprint: 11, velocity: 17.2, power: 3.0, heartRate: ["max": 175, "min": 60], heartRates: [100, 120, 130, 100, 120], route: [], center: [0, 0], calories: 0, vo2Max: 0),
        WorkoutData(dataID: 6, date: "2023-10-21T01:20:32Z", time: "60:10", distance: 3.6, sprint: 5, velocity: 24.4, power: 3.0, heartRate: ["max": 190, "min": 79], heartRates: [100, 120, 130, 100, 120], route: [], center: [0, 0], calories: 0, vo2Max: 0),
        WorkoutData(dataID: 7, date: "2023-10-23T01:20:32Z", time: "60:10", distance: 3.8, sprint: 13, velocity: 15.9, power: 3.0, heartRate: ["max": 183, "min": 91], heartRates: [100, 120, 130, 100, 120], route: [], center: [0, 0], calories: 0, vo2Max: 0),
        WorkoutData(dataID: 8, date: "2023-10-24T01:20:32Z", time: "60:10", distance: 2.5, sprint: 17, velocity: 17.3, power: 3.0, heartRate: ["max": 159, "min": 69], heartRates: [100, 120, 130, 100, 120], route: [], center: [0, 0], calories: 0, vo2Max: 0),
        WorkoutData(dataID: 8, date: "2023-10-24T01:20:32Z", time: "60:10", distance: 2.1, sprint: 1, velocity: 17.3, power: 3.0, heartRate: ["max": 144, "min": 73], heartRates: [100, 120, 130, 100, 120], route: [], center: [0, 0], calories: 0, vo2Max: 0),
        WorkoutData(dataID: 8, date: "2023-10-24T01:20:32Z", time: "60:10", distance: 3.2, sprint: 7, velocity: 16.3, power: 3.0, heartRate: ["max": 159, "min": 72], heartRates: [100, 120, 130, 100, 120], route: [], center: [0, 0], calories: 0, vo2Max: 0),
        WorkoutData(dataID: 8, date: "2023-10-24T01:20:32Z", time: "60:10", distance: 0.5, sprint: 8, velocity: 14.3, power: 3.0, heartRate: ["max": 162, "min": 63], heartRates: [100, 120, 130, 100, 120], route: [], center: [0, 0], calories: 0, vo2Max: 0),
        WorkoutData(dataID: 8, date: "2023-10-24T01:20:32Z", time: "60:10", distance: 1.9, sprint: 9, velocity: 12.3, power: 3.0, heartRate: ["max": 168, "min": 59], heartRates: [100, 120, 130, 100, 120], route: [], center: [0, 0], calories: 0, vo2Max: 0),
        WorkoutData(dataID: 8, date: "2023-10-24T01:20:32Z", time: "60:10", distance: 4.9, sprint: 10, velocity: 13.3, power: 3.0, heartRate: ["max": 171, "min": 68], heartRates: [100, 120, 130, 100, 120],  route: [], center: [0, 0], calories: 0, vo2Max: 0),
        WorkoutData(dataID: 8, date: "2023-10-24T01:20:32Z", time: "60:10", distance: 2.9, sprint: 17, velocity: 11.3, power: 3.0, heartRate: ["max": 158, "min": 69], heartRates: [100, 120, 130, 100, 120], route: [], center: [0, 0], calories: 0, vo2Max: 0),
        WorkoutData(dataID: 9, date: "2023-10-27T01:20:32Z", time: "60:10", distance: 5.3, sprint: 12, velocity: 23.5, power: 3.0, heartRate: ["max": 187, "min": 60], heartRates: [100, 120, 130, 100, 120], route: [], center: [0, 0], calories: 0, vo2Max: 0)
    ]
    
    private let dateFormatter: ISO8601DateFormatter = {
        return ISO8601DateFormatter()
    }()
}

// TODO: - 변수를 그대로 똑같이 읊는 주석은 제거 대상
// Average of the user workout data.
struct WorkoutAverageData: Hashable, Equatable, Identifiable {
    var id: UUID = UUID()
    var maxHeartRate: Int // Maximum heart rate during the match.
    var minHeartRate: Int // Minimum heart rate during the match.
    var heartRates: [Int]
    var rangeHeartRate: Int // Range of heart rate during the match.
    var totalDistance: Double // Total distance played during the match.
    var maxPower: Double // Maximum power during the match.
    var maxVelocity: Double // Maximum speed during the match.
    var sprintCount: Int // Number of sprints during the match.
    var calories: Int
    var totalMatchTime: Int // Total play time in the match.
    
    static let exampleAverage: WorkoutAverageData = WorkoutAverageData(maxHeartRate: 180,
                                                             minHeartRate: 50,
                                                             heartRates: [130, 120, 130, 135],
                                                             rangeHeartRate: 5,
                                                             totalDistance: 2.0,
                                                             maxPower: 5.8,
                                                             maxVelocity: 22.4,
                                                             sprintCount: 3,
                                                             calories: 0,
                                                             totalMatchTime: 80)
    
    static let blankAverage: WorkoutAverageData = WorkoutAverageData(maxHeartRate: 0,
                                                             minHeartRate: 0,
                                                             heartRates: [130, 120, 130, 135],
                                                             rangeHeartRate: 0,
                                                             totalDistance: 0,
                                                             maxPower: 0,
                                                             maxVelocity: 0,
                                                             sprintCount: 0,
                                                             calories: 0,
                                                             totalMatchTime: 0)
    
    init(maxHeartRate: Int, minHeartRate: Int, heartRates: [Int], rangeHeartRate: Int, totalDistance: Double, maxPower: Double, maxVelocity: Double, sprintCount: Int, calories: Int, totalMatchTime: Int) {
        self.maxHeartRate = maxHeartRate
        self.minHeartRate = minHeartRate
        self.heartRates = heartRates
        self.rangeHeartRate = rangeHeartRate
        self.totalDistance = totalDistance
        self.maxPower = maxPower
        self.maxVelocity = maxVelocity
        self.sprintCount = sprintCount
        self.calories = calories
        self.totalMatchTime = totalMatchTime
    }
    
    init() {
        self.maxHeartRate = 0
        self.minHeartRate = 0
        self.heartRates = []
        self.rangeHeartRate = 0
        self.totalDistance = 0
        self.maxPower = 0
        self.maxVelocity = 0
        self.sprintCount = 0
        self.calories = 0
        self.totalMatchTime = 0
    }
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
        let currentLocale = Locale.current
        let languageCode = currentLocale.language.languageCode ?? "en"
        let regionCode = currentLocale.region?.identifier ?? "US"
        let locale = Locale(identifier: "\(languageCode)_\(regionCode)")
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
