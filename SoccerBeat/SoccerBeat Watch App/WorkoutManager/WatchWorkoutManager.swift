//
//  WatchWorkoutManager.swift
//  SoccerBeat Watch App
//
//  Created by jose Yun on 10/21/23.
//

import SwiftUI
import HealthKit
import CoreLocation

class WorkoutManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    static let shared: WorkoutManager = WorkoutManager()
    
    @Published var showingSummaryView: Bool = false {
        didSet {
            if showingSummaryView == false {
                resetWorkout()
            }
        }
    }
    let heartRateQuantity = HKUnit(from: "count/min")
    let healthStore = HKHealthStore()
    var locationManager = CLLocationManager()
    var session: HKWorkoutSession?
    var builder: HKLiveWorkoutBuilder?
    var routeBuilder: HKWorkoutRouteBuilder?
    
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
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()

        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session?.associatedWorkoutBuilder()
            routeBuilder = HKWorkoutRouteBuilder(healthStore: healthStore, device: nil)
            computeMaxHeartRate()
            
        } catch {
            // Handle any exceptions.
            return
        }

        // Setup session and builder.
        session?.delegate = self
        builder?.delegate = self
        locationManager.delegate = self

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
        
        // write
        let typesToShare: Set = [HKQuantityType.workoutType(), HKSeriesType.workoutRoute()]
        
        // The quantity types to read from the health store.
        let typesToRead: Set = [
            HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!, // get MaxHeartRate
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKQuantityType.quantityType(forIdentifier: .runningSpeed)!,
            HKQuantityType.quantityType(forIdentifier: .walkingSpeed)!,
            HKSeriesType.workoutType(),
            HKSeriesType.workoutRoute(),
            HKObjectType.activitySummaryType()
        ]
        healthStore.requestAuthorization(toShare: typesToShare,
                                         read: typesToRead) { (success, error) in
        }
        
        self.locationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: - Session State Control
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
    @Published var heartRate: Double = 0 {
        didSet {
            self.heartZone = computeHeartZone(heartRate)
        }
    }

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
    
    // MARK: - Detact Zone 5
    private var timer: Timer?
    private var zone5Count = 0
    @Published var isInZone5For2Min = false
    @Published var heartZone: Int = 1 {
        didSet {
            if heartZone == 5 {
                if timer == .none {
                    timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                        self.zone5Count += 1
                    }
                } else {
                    if zone5Count >= 120 {
                        isInZone5For2Min = true
                        resetZone5Timer()
                    }
                }
            } else {
                resetZone5Timer()
            }
        }
    }
    
    private func resetZone5Timer() {
        self.timer?.invalidate()
        self.timer = .none
        self.zone5Count = 0
    }
    
    func updateForStatistics(_ statistics: HKStatistics?) {
        guard let statistics = statistics else { return }

        DispatchQueue.main.async {
            switch statistics.quantityType {
            case HKQuantityType.quantityType(forIdentifier: .heartRate):
                let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                self.heartRate  = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit) ?? 0.0
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Filter the raw data.
        let filteredLocations = locations.filter { (location: CLLocation) -> Bool in
            location.horizontalAccuracy <= 20.0
        }
        
        guard !filteredLocations.isEmpty else { return }
        
        // Add the filtered data to the route.
        routeBuilder?.insertRouteData(filteredLocations) { (success, error) in
            if !success {
                // Handle any errors here.
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
    func computeHeartZone(_ heartRate: Double) -> Int {
        if heartRate < Double(maxHeartRate!) * 0.6 {
            return 1
        } else if heartRate < Double(maxHeartRate!) * 0.7 {
            return 2
        } else if heartRate < Double(maxHeartRate!) * 0.8 {
            return 3
        } else if heartRate < Double(maxHeartRate!) * 0.9 {
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
            
            routeBuilder?.finishRoute(with: self.workout!, metadata: nil) { (newRoute, error) in
                
                guard newRoute != nil else {
                    // Handle any errors here.
                    return
                }
                // Optional: Do something with the route here.
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
