//
//  WatchWorkoutManager.swift
//  SoccerBeat Watch App
//
//  Created by jose Yun on 10/21/23.
//

import Combine
import CoreLocation
import HealthKit
import SwiftUI

final class WorkoutManager: NSObject, ObservableObject {
    let healthStore = HKHealthStore()
    let locationManager = CLLocationManager()
    let matrics: MatricsIndicator
    
    init(matrics: MatricsIndicator) {
        self.matrics = matrics
    }
    
    // 헬스킷 세션 기록용 빌더 선언
    var session: HKWorkoutSession?
    var builder: HKLiveWorkoutBuilder?
    var routeBuilder: HKWorkoutRouteBuilder?
    
    // MARK: - 헬스킷과 위치데이터 권한 받기
    var authHealthKit = PassthroughSubject<(), Never>()
    
    let typesToShare: Set = [HKQuantityType.workoutType(),
                                     HKSeriesType.workoutRoute(),
                                     HKQuantityType.quantityType(forIdentifier: .runningSpeed)!,
                                     HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
                                     
    ]
    
    let typesToRead: Set = [
        HKQuantityType.quantityType(forIdentifier: .heartRate)!,
        HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!,
        HKQuantityType.quantityType(forIdentifier: .runningSpeed)!,
        HKQuantityType.quantityType(forIdentifier: .walkingSpeed)!,
        HKQuantityType.quantityType(forIdentifier: .runningPower)!,
        HKSeriesType.workoutType(),
        HKSeriesType.workoutRoute(),
        HKObjectType.activitySummaryType()
    ]
    
    @Published var workout: HKWorkout?
    var hasNoLocationAuthorization: Bool {
        [CLAuthorizationStatus.notDetermined, .denied, .restricted].contains(locationManager.authorizationStatus)
    }
    
    var hasNoHealthAuthorization: Bool {
        var right = false
        for type in typesToShare  {
            if [HKAuthorizationStatus.notDetermined, .sharingDenied].contains(healthStore.authorizationStatus(for: type)) {
                print(type, healthStore.authorizationStatus(for: type).rawValue)
                right = true
            }
        }

        return right
    }

    func requestAuthorization() {

            // 위치 정보 권한 요청
            if self.hasNoLocationAuthorization {
                self.locationManager.requestAlwaysAuthorization()
            }
    
            // 헬스킷 권한이 없다면
            if self.hasNoHealthAuthorization {
            healthStore.requestAuthorization(toShare: typesToShare,
                                                 read: typesToRead) { (success, error) in
                    
                    if success {
                        print("Success in HealthKit Authorization!")
                    } else {
                        print("HealthKit authorization in watch has problems. ")
                    }
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
    private let heartRateQuantity = HKUnit(from: "count/min")
    private let meterUnit = HKUnit.meter()
    
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
        locationManager.startUpdatingLocation()

        // 헬스킷에서 나이 정보를 통해 적절한 최대심박수 찾기
        matrics.computeProperMaxHeartRate(with: healthStore)
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
    
    // 두 부분으로 나누기
    func resetWorkout() {
        builder = nil
        workout = nil
        session = nil
        
        matrics.reset()
    }
}
