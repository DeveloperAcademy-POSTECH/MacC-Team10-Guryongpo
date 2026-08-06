//
//  WatchWorkoutManager.swift
//  SoccerBeat Watch App
//
//  Created by jose Yun on 10/21/23.
//

import Combine
import CoreMotion
import CoreLocation
import HealthKit
import SwiftUI

final class WorkoutManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    static let shared: WorkoutManager = WorkoutManager(matrics: DIContianer.makeMatricsIndicator())
    let healthStore = HKHealthStore()
    private(set) var locationManager = CLLocationManager()
    private(set) var motionManager = CMMotionActivityManager()
    private(set) var matrics: MatricsIndicator
    var session: HKWorkoutSession?
    
    @Published var isStationaryDetacted = false

    init(matrics: MatricsIndicator) {
        self.matrics = matrics
        super.init()
        locationManager.delegate = self
        #if os(watchOS)
        // 짧은 Sprint 속도 변화를 수집하기 위해 watchOS 기본 100m 정확도보다 높은 정밀도를 요청한다.
        // Apple: https://developer.apple.com/documentation/corelocation/cllocationmanager/desiredaccuracy
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.activityType = .fitness
        #endif
        locationManager.requestWhenInUseAuthorization()
        requestHealthAuthorization()
    }
    
    #if os(watchOS)
    
    /**
            워치에서만 경기를 종료 / 재설정함.
     */
    var builder: HKLiveWorkoutBuilder?
    // 헬스킷 세션 기록용 빌더 선언
    var routeBuilder: HKWorkoutRouteBuilder?

    // 세션 시작과 종료 시에 뷰 관리 변수
    @Published var showingPrecount = false
    @Published var showingSummaryView = false {
        didSet {
            if showingSummaryView == false {
                resetWorkout()
            }
        }
    }
    
    // MARK: - 세션 관리
    @Published var running = false
    
    // MARK: 워치 경기 기록용 저장 변수
    @Published var workout: HKWorkout?
    @Published var route: HKWorkoutRoute?

    // MARK: - 데이터 선언 및 초기화
    /// 데이터 기록을 위한 초기 설정
    private let heartRateQuantity = HKUnit(from: "count/min")
    private let meterUnit = HKUnit.meter()

    enum SessionError: Error {
        case failureBuilderEnd
        case failureFinishWorkout
        case failureMakeRoute
    }
    #else
    var contextDate: Date?
    var hkWorkouts = [HKWorkout]()

    // Send when permission is granted by the user.
    var authSuccess = PassthroughSubject<(), Never>()
    private(set) var onWorkoutRemoved = PassthroughSubject<(IndexSet), Never>()
    // Send when data fetch is successful.
    var fetchWorkoutsSuccess = PassthroughSubject<([WorkoutData]), Never>()
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()

    @Published var recentGames = [WorkoutData]()
    @Published var recent4Games = [WorkoutData]()

    var monthly = [String: [WorkoutData]]()
    @Published var isLoading = false
    @Published var formerSession = false
    #endif
    
    // MARK: - 워치 폰 공통 사용 변수

    let typesToRead: Set = [
        HKQuantityType.quantityType(forIdentifier: .heartRate)!,
        HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKQuantityType.quantityType(forIdentifier: .walkingSpeed)!,
        HKQuantityType.quantityType(forIdentifier: .runningSpeed)!,
        HKQuantityType.quantityType(forIdentifier: .runningPower)!,
        HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
        HKQuantityType.quantityType(forIdentifier: .vo2Max)!,
        HKSeriesType.workoutType(),
        HKSeriesType.workoutRoute(),
        HKObjectType.activitySummaryType()
    ]
    
    let typesToShare: Set = [HKQuantityType.workoutType(),
                                     HKSeriesType.workoutRoute(),
                                     HKQuantityType.quantityType(forIdentifier: .runningSpeed)!,
                                     HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
    ]
    
    var isHealthDataAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    #if os(watchOS)
    var hasPreciseRecentLocation: Bool {
        guard locationManager.accuracyAuthorization == .fullAccuracy,
              let location = locationManager.location,
              location.horizontalAccuracy >= 0 else {
            return false
        }

        // 경기 시작 시 오래된 캐시 위치를 사용하지 않도록 CoreLocation 샘플 시각을 직접 검증한다.
        let sampleAge = Date().timeIntervalSince(location.timestamp)
        return (0...5).contains(sampleAge)
    }
    #endif

    var hasAllAuthorization: Bool {
        hasHealthAuthorization() && hasLocationAuthorization() && isHealthDataAvailable
    }
    
    func hasLocationAuthorization() -> Bool {
        [
            CLAuthorizationStatus.authorizedAlways,
            .authorizedWhenInUse
        ].contains(locationManager.authorizationStatus)
    }

    func hasHealthAuthorization() -> Bool {
        for type in typesToShare
        where healthStore.authorizationStatus(for: type) == .sharingDenied {
            NSLog(
                type.debugDescription,
                healthStore.authorizationStatus(for: type).rawValue
            )
            return false
        }
        return true
    }
    
    func requestHealthAuthorization() {
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            if let error {
                NSLog(error.localizedDescription)
                return
            }
            if success {

            } else {
                NSLog("Error in getting healthstore reading authorization. ")
            }
        }
    }
}
