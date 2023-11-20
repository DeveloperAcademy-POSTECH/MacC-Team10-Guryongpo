//
//  WatchWorkoutManager.swift
//  SoccerBeat Watch App
//
//  Created by jose Yun on 10/21/23.
//

import SwiftUI
import HealthKit
import CoreLocation
import OSLog

class WorkoutManager: NSObject, ObservableObject {
    static let shared: WorkoutManager = WorkoutManager()
    
    @Published var showingSummaryView: Bool = false {
        didSet {
            if showingSummaryView == false {
                resetWorkout()
            }
        }
    }
    
    @Published var showingPrecount: Bool = false
    let heartRateQuantity = HKUnit(from: "count/min")
    let healthStore = HKHealthStore()
    let locationManager = CLLocationManager()
    var session: HKWorkoutSession?
    var builder: HKLiveWorkoutBuilder?
    var routeBuilder: HKWorkoutRouteBuilder?
    
    var saveMinHeartRate: Int = 200
    var saveMaxHeartRate: Int = 0
    var maxHeartRate: Double?
    
    var energy: Double = 0
    
    let sprintSpeed: Double = 5.5556 // modify it to test code
    
    @Published var isSprint: Bool = false
    var maxSpeed: Double = 0.0
    @Published var recentSprintSpeed: Double = 0.0
    @Published var speed: Double = 0.0 {
        didSet(oldValue) {
            
            // 가속도 측정
            acceleration = max(speed - oldValue, acceleration)
            
            // 최고 속도
            maxSpeed = max(maxSpeed, speed)
            
            // 스프린트 카운트
            if !isSprint && speed >= sprintSpeed {
                isSprint = true
                sprint += 1
                recentSprintSpeed = 0.0
            } else if isSprint && speed < sprintSpeed {
                isSprint = false
            }
            
            // 직전 스프린트 최대 속도
            if isSprint {
                recentSprintSpeed = max(recentSprintSpeed, speed)
            }
        }
    }
    var acceleration: Double = 0.0
    
    // MARK: - Workout Metrics
    @Published var heartRate: Double = 0 {
        didSet {
            self.heartZone = computeHeartZone(heartRate)
            
            if saveMinHeartRate > Int(heartRate) {
                saveMinHeartRate = Int(heartRate)
            }
            
            if saveMaxHeartRate < Int(heartRate) {
                saveMaxHeartRate = Int(heartRate)
            }
        }
    }
    
    func computeMaxHeartRate() {
//        do {
//            let birthYear = try healthStore.dateOfBirthComponents().year
//            let year = Calendar.current.component(.year, from: Date())
//            maxHeartRate = Double(220 - ( year - birthYear!))
//        } catch {
            maxHeartRate = 190
//        }
    }
    
    // MARK: - 데이터 수집 및 경기 시작
    func startWorkout() {
        
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .running
        configuration.locationType = .outdoor
        
        // 세션, 빌더, 루트 빌더, 로케이션 매니저 초기화
        do {
            session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
            builder = session?.associatedWorkoutBuilder()
            routeBuilder = HKWorkoutRouteBuilder(healthStore: healthStore, device: .local())
        } catch {
            return
        }
        
        // 델리게이트 선언
        locationManager.delegate = self
        session?.delegate = self
        builder?.delegate = self
        builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore,
                                                      workoutConfiguration: configuration)
        
        // Start the workout session and begin data collection.
        let startDate = Date()
        session?.startActivity(with: startDate)
        builder?.beginCollection(withStart: startDate) { (_, _) in
            // The workout has started.
        }
        
        locationManager.desiredAccuracy = locationManager.accuracyAuthorization == .fullAccuracy
        ? kCLLocationAccuracyBestForNavigation
        : kCLLocationAccuracyBest
        
        // 위치 정보 수집
        startLocationUpdates()
        computeMaxHeartRate()
    }
    
    // MARK: - Request authorization to access HealthKit And LocationManager.
    func requestAuthorization() {
        
        // write
        let typesToShare: Set = [HKQuantityType.workoutType(),
                                 HKSeriesType.workoutRoute(),
                                 HKQuantityType.quantityType(forIdentifier: .runningSpeed)!,
                                 HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                                 HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!
                                 
        ]
        
        // The quantity types to read from the health store.
        let typesToRead: Set = [
            HKObjectType.characteristicType(forIdentifier: .dateOfBirth)!, // get MaxHeartRate
            HKQuantityType.quantityType(forIdentifier: .heartRate)!,
            HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKQuantityType.quantityType(forIdentifier: .runningSpeed)!,
            HKQuantityType.quantityType(forIdentifier: .walkingSpeed)!,
            HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKSeriesType.workoutType(),
            HKSeriesType.workoutRoute(),
            HKObjectType.activitySummaryType()
        ]
        healthStore.requestAuthorization(toShare: typesToShare,
                                         read: typesToRead) { (_, _) in
        }
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
    
    // MARK: - BPM
    
    private var bpmString: String {
        String(heartRate.formatted(.number.precision(.fractionLength(0))))
    }
    
    public var isBPMActive: Bool {
        return bpmString != "0"
    }
    
    public var bpmForText: String {
        return isBPMActive ? bpmString : "---"
    }
    
    // MARK: - Distance
    
    @Published var distance: Double = 0
    public var isDistanceActive: Bool {
        distance != 0
    }
    @Published var sprint: Int = 0 // default setup
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
    
    let meterUnit = HKUnit.meter()
    
    func updateForStatistics(_ statistics: HKStatistics?) {
        guard let statistics = statistics else { return }
        //        print(statistics)
        //
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
            case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
                self.energy = statistics.sumQuantity()?.doubleValue(for: HKUnit(from: "kcal")) ?? 0
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
        heartZone = 0
        distance = 0
        maxSpeed = 0
        speed = 0
        sprint = 0
        saveMaxHeartRate = 0
        saveMinHeartRate = 0
        zone5Count = 0
        heartZone = 1
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
        NSLog("WorkOutSession 변화 감지: \(toState)")
        DispatchQueue.main.async {
            self.running = toState == .running
        }
        /// Save Wokrout, Route
        if toState == .ended {
            
            builder?.endCollection(withEnd: date) { (_, _) in
                self.builder?.finishWorkout { [weak self] (workout, _) in
                    DispatchQueue.main.async {
                        self?.workout = workout
                    }
                    
                    guard let workout else {
                        NSLog("workout is nil")
                        return
                    }
                    
                    // custom data 를 routedata의 metadata에 저장
                    let metadata: [String: Any] = [
                        "MaxSpeed": Double(Int(self!.maxSpeed * 100.rounded()))/100,
                        "SprintCount": self!.sprint,
                        "MinHeartRate": self!.saveMinHeartRate,
                        "MaxHeartRate": self!.saveMaxHeartRate,
                        "Distance": (Double(Int(self!.distance/1000 * 100 ))) / 100,
                        "Acceleration": Double(Int(self!.acceleration * 100.rounded()))/100
                    ]
                    
                    print(metadata)
                    
                    self?.routeBuilder?.finishRoute(with: workout, metadata: metadata) { (newRoute, _) in
                        guard newRoute != nil else {
                            NSLog("새로운 루트가 없습니다.")
                            return
                        }
                        NSLog("새로운 루트가 저장되었습니다.")
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
    
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder,
                        didCollectDataOf collectedTypes: Set<HKSampleType>) {
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

// MARK: - CLLocationManagerDelegate
extension WorkoutManager: CLLocationManagerDelegate {
    // MARK: - 위치 정보가 수집되면 불리는 메서드
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Filter the raw data.
        let filteredLocations = locations.filter { (location: CLLocation) -> Bool in
            // 필터 조정치 필요, 예시 121, 66등으로 20 미만인 필터 데이터가 존재하지 않음
            location.horizontalAccuracy <= 20.0
        }
        
        guard !filteredLocations.isEmpty else {
            routeBuilder?.insertRouteData(locations, completion: { _, _ in
            })
            return
        }
        
        // Add the filtered data to the route.
        routeBuilder?.insertRouteData(filteredLocations) { (success, error) in
            if !success {
                // Handle any errors here.
                print(error.debugDescription)
            }
            
        }
    }
    
    // MARK: - 위치 공유 권한 정보가 업데이트 되면 불리는 메서드
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            NSLog("위치 권한 결정 안됨")
            manager.requestWhenInUseAuthorization()
        case .restricted:
            NSLog("위치 권한 제한됨")
            manager.requestAlwaysAuthorization()
        case .denied:
            NSLog("위치 권한 거부")
            manager.requestAlwaysAuthorization()
        case .authorizedAlways:
            NSLog("위치 권한 항상 허용")
            startLocationUpdates()
        case .authorizedWhenInUse:
            NSLog("위치 권한 사용중 허용")
            startLocationUpdates()
        @unknown default:
            NSLog(manager.authorizationStatus.rawValue.description)
        }
    }
    
    private func startLocationUpdates() {
        if [CLAuthorizationStatus.notDetermined, .denied, .restricted].contains(locationManager.authorizationStatus) {
            locationManager.requestWhenInUseAuthorization()
        }
        locationManager.startUpdatingLocation()
    }
    
    private func stopLocationUpdates() {
        print("Stopping location updates")
        locationManager.stopUpdatingHeading()
    }
}
