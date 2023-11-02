//
//  HealthInteractor.swift
//  SoccerBeat
//
//  Created by daaan on 11/1/23.
//

import Foundation
import HealthKit
import CoreLocation

class HealthInteractor: ObservableObject {
    var healthStore = HKHealthStore()
    
    var userWorkouts: [WorkoutData] = []
    
    var allWorkouts: [HKWorkout] = []
    var allRoutes: [CLLocation] = []
    var customData: [HKQuantitySample] = []
    
    private let dateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-mm-dd"
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
    
    static let shared = HealthInteractor()
    
    init() {
        requestAuthorization()
    }
    
    func requestAuthorization() {
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
            if success {
                Task {
                    await self.fetchAllData()
                }
            }
        }
    }
    
    func fetchAllData() async {
        print("fetchAllData: attempting to fetch all data..")
        
        allWorkouts = await getAllWorkout() ?? []
        customData = await getCustomData() ?? []
//        await getWorkoutDistance(workout: allWorkouts.last!)
        if !allWorkouts.isEmpty {
            var dataId = 0
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
                
                let custom = customData[dataId]
                
                var time: String = String(Int(allWorkout.duration)/60) + " : " + String(Int(allWorkout.duration) % 60)
                
//                await userWorkouts.append(WorkoutData(dataId: dataId, date: allWorkout.startDate, time: time, distance: custom.metadata!["Distance"] as! Double, location: "Empty", sprint: 0, velocity: custom.metadata!["MaxSpeed"] as! Double, heartRate: ["max": custom.metadata?["MaxHeartRate"] as! Int, "min": custom.metadata!["MinHeartRate"] as! Int], route: routes, center: (latSum / Double(routes.count), lonSum / Double(routes.count))))
                
                await userWorkouts.append(WorkoutData(dataId: dataId, date: dateFormatter.string(from: allWorkout.startDate), time: time, distance: custom.metadata!["Distance"] as! Double, location: "Empty", sprint: custom.metadata?["SprintCount"] as! Int, calorie: custom.metadata?["Calorie"] as! Double, velocity: custom.metadata!["MaxSpeed"] as! Double, heartRate: ["max": custom.metadata?["MaxHeartRate"] as! Int, "min": custom.metadata!["MinHeartRate"] as! Int]))
                
                dataId += 1
            }
        }
        
        print(userWorkouts)
    }
    
    func getAllWorkout() async -> [HKWorkout]? {
        // TODO: workout data from out application
        // How to get from SoccerBeat
        let soccer = HKQuery.predicateForObjects(from: .default())
        
        // TODO: how to seperate workout data ?
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
