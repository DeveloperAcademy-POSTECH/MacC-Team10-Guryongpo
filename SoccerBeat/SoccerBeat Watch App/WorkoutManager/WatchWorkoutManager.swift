//
//  WatchWorkoutManager.swift
//  SoccerBeat Watch App
//
//  Created by jose Yun on 10/21/23.
//

import Foundation
import HealthKit

class WorkoutManager: NSObject, ObservableObject {
    @Published var showingSummaryView: Bool = false {
        didSet {
            if showingSummaryView == false {
                resetWorkout()
            }
        }
    }

    let healthStore = HKHealthStore()
    var session: HKWorkoutSession?
    var builder: HKLiveWorkoutBuilder?
    
    var maxHeartRate: Double?
    
    func computeMaxHeartRate() {
        do {
            let birthYear = try healthStore.dateOfBirthComponents().year
            let year = Calendar.current.component(.year, from: Date())
            maxHeartRate = Double(220 - ( year - birthYear!))
        } catch {
            maxHeartRate = 190
        }
    }

    func startWorkout() {
        
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .running
        configuration.locationType = .outdoor

        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session?.associatedWorkoutBuilder()
            computeMaxHeartRate()
            
        } catch {
            // Handle any exceptions.
            return
        }

        // Setup session and builder.
        session?.delegate = self
        builder?.delegate = self

        // Set the workout builder's data source.
        builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore,
                                                     workoutConfiguration: configuration)

        // Start the workout session and begin data collection.
        let startDate = Date()
        session?.startActivity(with: startDate)
        builder?.beginCollection(withStart: startDate) { (success, error) in
            // The workout has started.
        }
    }

    // Request authorization to access HealthKit.
    func requestAuthorization() {
        // The quantity types to read from the health store.
        let typesToRead: Set = [
            HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!, // get MaxHeartRate
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKQuantityType.quantityType(forIdentifier: .runningSpeed)!,
            HKQuantityType.quantityType(forIdentifier: .walkingSpeed)!,
            HKObjectType.activitySummaryType()
        ]
        healthStore.requestAuthorization(toShare: [], read: typesToRead) { (success, error) in
            // Handle error.
        }
    }

    // MARK: - Session State Control

    // The app's workout state.
    @Published var running = false

    func togglePause() {
        if running == true {
            pause()
        } else {
            resume()
        }
    }

    private func pause() {
        session?.pause()
    }

    private func resume() {
        session?.resume()
    }

    func endWorkout() {
        session?.end()
        showingSummaryView = true
    }

    // MARK: - Workout Metrics
    @Published var heartRate: Int = 0 {
        didSet {
            self.heartZone = computeHeartZone(heartRate)
        }
    }
    @Published var heartZone: Int = 1
    
    let sprintSpeed: Double = 5.5556 // modify it to test code
    var isSprint: Bool = false
    var speed: Double = 0.0 {
        didSet {
            if !isSprint && speed >= sprintSpeed {
                isSprint = true
                sprint = max(0, sprint - 1)
            } else if isSprint && speed < sprintSpeed {
                isSprint = false
            }
        }
    }
    
    @Published var distance: Double = 0
    @Published var sprint: Int = 6 // default setup
    @Published var workout: HKWorkout?
    @Published var isAlert: Bool = false
    
    func updateForStatistics(_ statistics: HKStatistics?) {
        guard let statistics = statistics else { return }

        DispatchQueue.main.async {
            switch statistics.quantityType {
            case HKQuantityType.quantityType(forIdentifier: .heartRate):
                let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                let heartRateDouble = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit) ?? 0.0
                self.heartRate = Int(heartRateDouble)
            case HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning):
                let meterUnit = HKUnit.meter()
                self.distance = statistics.sumQuantity()?.doubleValue(for: meterUnit) ?? 0
            case HKQuantityType.quantityType(forIdentifier: .runningSpeed), HKQuantityType.quantityType(forIdentifier: .walkingSpeed):
                self.speed = statistics.mostRecentQuantity()?.doubleValue(for:  HKUnit.init(from: "m/s")) ?? 0
            default:
                return
            }
        }
    }

    func resetWorkout() {
        builder = nil
        workout = nil
        session = nil
        heartRate = 0
        distance = 0
    }
    
    // MARK: - Heart Rate Setup
    func computeHeartZone(_ heartRate: Int) -> Int {
        let heartDouble = Double(heartRate)
        if heartDouble < Double(maxHeartRate!) * 0.6 {
            return 1
        } else if heartDouble < Double(maxHeartRate!) * 0.7 {
            return 2
        } else if heartDouble < Double(maxHeartRate!) * 0.8 {
            return 3
        } else if heartDouble < Double(maxHeartRate!) * 0.9 {
            return 4
        } else {
            return 5
        }
    }
}

// MARK: - HKWorkoutSessionDelegate
extension WorkoutManager: HKWorkoutSessionDelegate {
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState,
                        from fromState: HKWorkoutSessionState, date: Date) {
        DispatchQueue.main.async {
            self.running = toState == .running
        }

        // Wait for the session to transition states before ending the builder.
        if toState == .ended {
            builder?.endCollection(withEnd: date) { (success, error) in
                self.builder?.finishWorkout { (workout, error) in
                    DispatchQueue.main.async {
                        self.workout = workout
                    }
                }
            }
        }
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {

    }
}

// MARK: - HKLiveWorkoutBuilderDelegate
extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {

    }

    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else {
                return // Nothing to do.
            }

            let statistics = workoutBuilder.statistics(for: quantityType)

            // Update the published values.
            updateForStatistics(statistics)
        }
    }
}
