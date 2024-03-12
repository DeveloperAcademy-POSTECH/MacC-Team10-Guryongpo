//
//  WatchWorkoutManager.swift
//  SoccerBeat Watch App
//
//  Created by jose Yun on 10/21/23.
//

import Combine
import CoreLocation
import HealthKit
import OSLog
import SwiftUI

// TODO: - 변수와 변수가 사용되는 함수의 라인을 근접하게 하기
// TODO: - 역할 나누기
/// WorkoutManager는 여러가지 일을 수행하고 있습니다.
/// 1. 경기 세션의 상태 변화 관리
/// 2. 위치 정보 수집
/// ----
/// 3. HealthKit에 read, write 작업
/// 4. HealthKit에 관련한 권한이 있는지 확인
final class WorkoutManager: NSObject, ObservableObject {
    static let shared: WorkoutManager = WorkoutManager()
    let healthStore = HKHealthStore()
    let locationManager = CLLocationManager()
    
    // 헬스킷 세션 기록용 빌더 선언
    var session: HKWorkoutSession?
    var builder: HKLiveWorkoutBuilder?
    var routeBuilder: HKWorkoutRouteBuilder?
    
    // MARK: - 헬스킷과 위치데이터 권한 받기
    var authHealthKit = PassthroughSubject<(), Never>()
    var hasNotLocationAuthorization: Bool {
        [CLAuthorizationStatus.notDetermined, .denied, .restricted].contains(locationManager.authorizationStatus)
    }
    private let typesToShare: Set = [HKQuantityType.workoutType(),
                             HKSeriesType.workoutRoute(),
                             HKQuantityType.quantityType(forIdentifier: .runningSpeed)!,
                             HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
                             
    ]
    
    var hasNotHealthAuthorization: Bool {
        var right = false
        for type in typesToShare {
            if [HKAuthorizationStatus.notDetermined, .sharingDenied].contains(healthStore.authorizationStatus(for: type)) {
                right = true
                break
            }
        }
        return right
    }

    func requestAuthorization() {
        
        let typesToRead: Set = [
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
            // 위치 정보 권한 요청
            if self.hasNotLocationAuthorization {
                self.locationManager.requestWhenInUseAuthorization()
            }
            
            // 헬스킷 권한이 없다면
            if self.hasNotHealthAuthorization {
                self.authHealthKit.send()
            }
        }
    }
    
    // 세션 시작과 종료 시에 뷰 관리 변수
    @Published var showingPrecount: Bool = false
    @Published var showingSummaryView: Bool = false {
        didSet {
            if showingSummaryView == false {
                resetWorkout()
            }
        }
    }
    
    // MARK: - 데이터 선언 및 초기화
    /// 데이터 기록을 위한 초기 설정
    let heartRateQuantity = HKUnit(from: "count/min")
    let meterUnit = HKUnit.meter()
    func computeProperMaxHeartRate() {
        do {
            let birthYear = try healthStore.dateOfBirthComponents().year
            let year = Calendar.current.component(.year, from: Date())
            properMaxHeartRate = Double(220 - ( year - birthYear!))
        } catch {
            properMaxHeartRate = 190
        }
    }
    
    // 데이터 상수 선언
    var properMaxHeartRate: Double? // 신체 나이에 맞는 적절한 최대심박수.
    let sprintSpeed: Double = 2.78 // 2.78ms == 10km/h 비교에 사용되는 스프린트 변수 상수 값.

    // 데이터 기록 변수
    var saveMinHeartRate: Int = 300 // 심박최고수 저장
    var saveMaxHeartRate: Int = 0

    // 데이터 표기 변수
    var energy: Double = 0 // 칼로리
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
    
    // 스프린트 관련 변수. 스프린트 모드와 관련해 여러 변수 사용
    var maxSpeedMPS: Double = 0.0
    @Published var isSprint: Bool = false
    @Published var recentSprintSpeedMPS = 0.0
    @Published var speed: Double = 0.0 {
        didSet(oldValue) {
            
            // 가속도 측정
            acceleration = max(speed - oldValue, acceleration)
            // 최고 속도
            maxSpeedMPS = max(maxSpeedMPS, speed)
            // 스프린트 카운트
            if !isSprint && speed >= sprintSpeed {
                isSprint = true
                sprint += 1
                recentSprintSpeedMPS = 0.0
            } else if isSprint && speed < sprintSpeed {
                isSprint = false
            }
            
            // 직전 스프린트 최대 속도
            if isSprint {
                recentSprintSpeedMPS = max(recentSprintSpeedMPS, speed)
            }
        }
    }
    
    
    private func setupWorkoutConfig() {
        // workout configuration 설정
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
    }
    
    private func startWorkoutSession() {
        let startDate = Date()
        session?.startActivity(with: startDate)
        builder?.beginCollection(withStart: startDate) { (_, _) in
            // The workout has started.
        }
        
        locationManager.desiredAccuracy = locationManager.accuracyAuthorization == .fullAccuracy
        ? kCLLocationAccuracyBestForNavigation
        : kCLLocationAccuracyBest
        
        // 위치 정보 수집
        // TODO: - Loaction Manager한테 넘어가도 될 것 같네요
        locationManager.startUpdatingLocation()

        // 헬스킷에서 나이 정보를 통해 적절한 최대심박수 찾기
        computeProperMaxHeartRate()
    }
    
    // MARK: - 데이터 수집 및 경기 시작
    func startWorkout() {
        setupWorkoutConfig()
        startWorkoutSession()
    }
    
    
    // MARK: - 세션 관리
    @Published var running = false
    
    func togglePause() {
        running ? pause() : resume()
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
    
    // MARK: - 심박수 표기
    
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
    @Published var distanceMeter: Double = 0
    public var isDistanceActive: Bool {
        distanceMeter != 0
    }
    @Published var sprint: Int = 0 // default setup
    @Published var workout: HKWorkout?
    
    // MARK: - 심박수 위험 지대 감지
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
    // heartZone 과 관련 -> MatricsIndicator
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
                self.distanceMeter = statistics.sumQuantity()?.doubleValue(for: meterUnit) ?? 0
            case HKQuantityType.quantityType(forIdentifier: .runningSpeed), HKQuantityType.quantityType(forIdentifier: .walkingSpeed):
                self.speed = statistics.mostRecentQuantity()?.doubleValue(for:  HKUnit.init(from: "m/s")) ?? 0
            case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
                self.energy = statistics.sumQuantity()?.doubleValue(for: HKUnit(from: "kcal")) ?? 0
            default:
                return
            }
        }
    }
    
    // 두 부분으로 나누기
    func resetWorkout() {
        builder = nil
        workout = nil
        session = nil
        
        heartRate = 0
        heartZone = 1
        zone5Count = 0
        saveMaxHeartRate = 0
        saveMinHeartRate = 300 // initialize
        
        distanceMeter = 0
        maxSpeedMPS = 0
        speed = 0
        sprint = 0
        recentSprintSpeedMPS = 0
    }
    
    // MARK: - Heart Rate Setup -> MatricsIndicator
    func computeHeartZone(_ heartRate: Double) -> Int {
        if heartRate < Double(properMaxHeartRate!) * 0.6 {
            return 1
        } else if heartRate < Double(properMaxHeartRate!) * 0.7 {
            return 2
        } else if heartRate < Double(properMaxHeartRate!) * 0.8 {
            return 3
        } else if heartRate < Double(properMaxHeartRate!) * 0.9 {
            return 4
        } else {
            return 5
        }
    }
}

// MARK: - HKWorkoutSessionDelegate -> SessionManager
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
                        "MaxSpeed": Double(self!.maxSpeedMPS.rounded(at: 2)), // m/s
                        "SprintCount": self!.sprint,
                        "MinHeartRate": self!.saveMinHeartRate != 300 ? self!.saveMinHeartRate : 0,
                        "MaxHeartRate": self!.saveMaxHeartRate,
                        "Distance": Double((self!.distanceMeter / 1000).rounded(at: 1)), // km
                        "Acceleration": Double(self!.acceleration.rounded(at: 2)) // m/s^2
                    ]
                    
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

// MARK: - HKLiveWorkoutBuilderDelegate, SessionManager
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
