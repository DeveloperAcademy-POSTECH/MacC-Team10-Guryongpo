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
                
                var time: String = String(Int(allWorkout.duration)/60) + " : " + String(Int(allWorkout.duration) % 60)
                userWorkouts.append(WorkoutData(dataID: dataID,
                                                date: dateFormatter.string(from: allWorkout.startDate),
                                                time: time as! String,
                                                distance: custom["Distance"] as! Double,
                                                sprint: custom["SprintCount"] as! Int,
                                                velocity: custom["MaxSpeed"] as! Double,
                                                heartRate: ["max": custom["MaxHeartRate"] as! Int,
                                                            "min": custom["MinHeartRate"] as! Int],
                                                route: routes,
                                                center: [latSum / Double(routes.count),
                                                         lonSum / Double(routes.count)]))
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
