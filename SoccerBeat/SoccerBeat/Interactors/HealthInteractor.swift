//
//  HealthInteractor.swift
//  SoccerBeat
//
//  Created by daaan on 11/1/23.
//

import Foundation
import Combine
import CoreLocation
import HealthKit

class HealthInteractor: ObservableObject {
    // Object to request permission to read HealthKit data.
    var healthStore = HKHealthStore()
    // Entire user workouts in HealthKit data.
    var userWorkouts: [WorkoutData] = []
    var allWorkouts: [HKWorkout] = []
    var allMetadata: [[String : Any]] = []
    var allRoutes: [CLLocation] = []
    // Badges in ProfileView
    var allBadges: [[Bool]] = [[false, false, false, false],
                               [false, false, false, false],
                               [false, false, false, false]]
    
    // Send when permission is granted by the user.
    var authSuccess = PassthroughSubject<(), Never>()
    // Send when data fetch is successful.
    var fetchSuccess = PassthroughSubject<(), Never>()
    
    static let shared = HealthInteractor()
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.mm.dd"
        return formatter
    }()
    
    var monthly: [String: [WorkoutData]] {
        var dict = [String: [WorkoutData]]()
        userWorkouts.forEach { match in
            let yearMonth = Array(match.date.split(separator: "-")[...1]).joined(separator: "-")
            dict[yearMonth, default: []].append(match)
        }
        return dict
    }
    
    @MainActor
    func requestAuthorization() {
        print("requestAuthorization: request user authorization..")
        let typeToRead = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!,
                              HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                              HKObjectType.quantityType(forIdentifier: .runningSpeed)!,
                              HKObjectType.quantityType(forIdentifier: .walkingSpeed)!,
                              HKSeriesType.workoutType(),
                              HKSeriesType.workoutRoute(),
                              HKObjectType.activitySummaryType()
                             ])
        
        guard HKHealthStore.isHealthDataAvailable() else {
            print("requestAuthorization: health data not available")
            return
        }
        
        healthStore.requestAuthorization(toShare: nil, read: typeToRead) { success, error in
            // Success means that the Permission window appears.
            if success {
                self.authSuccess.send()
            }
        }
    }
    
    @MainActor
    func fetchAllData() async {
        print("fetchAllData: attempting to fetch all data..")
        
        allWorkouts = await getAllWorkout() ?? []
        if !allWorkouts.isEmpty {
            var dataID = 0
            for allWorkout in allWorkouts {
                var latSum = 0.0
                var lonSum = 0.0
                var routes: [CLLocationCoordinate2D] = []
                let routeWorkouts = await getWorkoutRoute(workout: allWorkout) ?? []
                for routeWorkout in routeWorkouts {
                    routes.append(CLLocationCoordinate2D(latitude: routeWorkout.coordinate.latitude, longitude: routeWorkout.coordinate.longitude))
                    latSum += routeWorkout.coordinate.latitude
                    lonSum += routeWorkout.coordinate.longitude
                }
                
                let custom = allMetadata[dataID]
                
                var distance = custom["Distance"] as! Double
                var sprint = custom["SprintCount"] as! Int
                var velocity = custom["MaxSpeed"] as! Double
                
                var matchBadge: [Int] = calculateBadgeData(distance: distance, sprint: sprint, velocity: velocity)
            
            
            
            var time: String = String(Int(allWorkout.duration)/60) + " : " + String(Int(allWorkout.duration) % 60)
            userWorkouts.append(WorkoutData(dataID: dataID,
                                            date: dateFormatter.string(from: allWorkout.startDate),
                                            time: time as! String,
                                            distance: custom["Distance"] as! Double,
                                            sprint: custom["SprintCount"] as! Int,
                                            velocity: custom["MaxSpeed"] as! Double,
                                            acceleration: custom["Acceleration"] as! Double,
                                            heartRate: ["max": custom["MaxHeartRate"] as! Int,
                                                        "min": custom["MinHeartRate"] as! Int],
                                            route: routes,
                                            center: [latSum / Double(routes.count),
                                                     lonSum / Double(routes.count)],
                                            matchBadge: matchBadge))
            dataID += 1
        }
        self.fetchSuccess.send()
    }
}

func getAllWorkout() async -> [HKWorkout]? {
    let soccer = HKQuery.predicateForObjects(from: .default())
    let data = try! await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKSample], Error>) in
        healthStore.execute(HKSampleQuery(sampleType: .workoutType(), predicate: soccer, limit: HKObjectQueryNoLimit,sortDescriptors: [.init(keyPath: \HKSample.startDate, ascending: false)], resultsHandler: { query, samples, error in
            if let hasError = error {
                continuation.resume(throwing: hasError)
                return
            }
            continuation.resume(returning: samples!)
        }))
    }
    guard let workouts = data as? [HKWorkout] else {
        return nil
    }
    return workouts
}

func getCustomData() async -> [HKQuantitySample]? {
    
    guard let speedType =
            HKObjectType.quantityType(forIdentifier:
                                        HKQuantityTypeIdentifier.runningSpeed) else {
        fatalError("*** Unable to create a distance type ***")
    }
    
    let soccer = HKQuery.predicateForObjects(from: .default())
    let data = try! await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKSample], Error>) in
        self.healthStore.execute(HKSampleQuery(sampleType: speedType, predicate: soccer, limit: HKObjectQueryNoLimit,sortDescriptors: [.init(keyPath: \HKSample.startDate, ascending: false)], resultsHandler: { query, samples, error in
            if let hasError = error {
                continuation.resume(throwing: hasError)
                return
            }
            continuation.resume(returning: samples!)
        }))
    }
    guard let speedData = data as? [HKQuantitySample] else {
        return nil
    }
    return speedData
}

func calculateBadgeData(distance: Double, sprint: Int, velocity: Double) -> [Int] {
    // matchBadge: [distance, sprint, velocity]
    // 뱃지 미 획득 시: -1
    var matchBadge: [Int] = [0, 0, 0]
    
    if distance < 1.5 {
        matchBadge[0] = -1
    } else if (1.5 <= distance && distance < 2.0) {
        matchBadge[0] = 0
        allBadges[0][1] = true
    } else if (2.0 <= distance && distance < 2.5) {
        matchBadge[0] = 1
        allBadges[0][1] = true
    } else if (2.5 <= distance && distance < 3.0) {
        matchBadge[0] = 2
        allBadges[0][2] = true
    } else {
        matchBadge[0] = 3
        allBadges[0][3] = true
    }
    
    if sprint < 5 {
        matchBadge[1] = -1
    } else if (5 <= distance && distance < 7) {
        matchBadge[1] = 0
        allBadges[1][0] = true
    } else if (7 <= distance && distance < 9) {
        matchBadge[1] = 1
        allBadges[1][1] = true
    } else if (9 <= distance && distance < 11) {
        matchBadge[1] = 2
        allBadges[1][2] = true
    } else {
        matchBadge[1] = 3
        allBadges[1][3] = true
    }
    
    if velocity < 15 {
        matchBadge[2] = -1
    } else if (15 <= distance && distance < 20) {
        matchBadge[2] = 0
        allBadges[2][0] = true
    } else if (20 <= distance && distance < 25) {
        matchBadge[2] = 1
        allBadges[2][1] = true
    } else if (25 <= distance && distance < 30) {
        matchBadge[2] = 2
        allBadges[2][2] = true
    } else {
        matchBadge[2] = 3
        allBadges[2][3] = true
    }
    
    return matchBadge
}

func getWorkoutRoute(workout: HKWorkout) async -> ([CLLocation]?) {
    let byWorkout = HKQuery.predicateForObjects(from: workout)
    
    let samples = try? await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKSample], Error>) in
        healthStore.execute(HKAnchoredObjectQuery(type: HKSeriesType.workoutRoute(), predicate: byWorkout, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: { (query, samples, deletedObjects, anchor, error) in
            if let hasError = error {
                continuation.resume(throwing: hasError); return
            }
            
            guard let samples = samples else { return }
            
            continuation.resume(returning: samples)
        }))
    }
    
    guard let route = (samples as? [HKWorkoutRoute])?.first else { return nil }
    // save Meta data in workoutRoute
    samples?.forEach { sample in
        allMetadata.append(sample.metadata!)
    }
    
    let locations = try? await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[CLLocation], Error>) in
        var allLocations = [CLLocation]() // built up over time as and when HK tells us
        healthStore.execute(HKWorkoutRouteQuery(route: route) { (query, locationsOrNil, done, errorOrNil) in
            // This block may be called multiple times.
            if let error = errorOrNil {
                continuation.resume(throwing: error); return
            }
            
            guard let locations = locationsOrNil else {
                fatalError("Invalid State: This can only fail if there was an error.")
            }
            allLocations += locations
            
            if done {
                continuation.resume(returning: allLocations)
            }
        })
    }
    return locations
}
}

extension HealthInteractor {
    func readRecentMatches(for count: Int) -> [WorkoutData] {
        guard userWorkouts.count >= count  else { return userWorkouts }
        let startIndex = userWorkouts.count - count
        let lastIndex = userWorkouts.count-1
        var recentMatches = [WorkoutData]()
        for i in startIndex...lastIndex {
            recentMatches.append(userWorkouts[i])
        }
        return recentMatches
    }
}
