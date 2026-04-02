//
//  WorkoutManager+extensions.swift
//  SoccerBeat Watch App
//
//  Created by Gucci on 3/12/24.
//

import CoreLocation
import Foundation
import HealthKit
import OSLog

// MARK: - 세션 pause, resume, end 시에 작동하는 델리게이트
extension WorkoutManager: HKWorkoutSessionDelegate {
    
    // MARK: - 데이터 수집 및 경기 시작
    func startWorkout() {
        setupWorkoutConfig()
        startWorkoutSession()
    }
    
    // 워치 경기 기록 설정
    private func setupWorkoutConfig() {
        // workout configuration 설정
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .soccer
        configuration.locationType = .outdoor

        // 세션, 빌더, 루트 빌더, 로케이션 매니저 초기화
        do {
            session = try HKWorkoutSession(
                healthStore: healthStore,
                configuration: configuration
            )
        } catch {
            NSLog(error.localizedDescription)
        }
        builder = session?.associatedWorkoutBuilder()
        routeBuilder = HKWorkoutRouteBuilder(healthStore: healthStore, device: .local())
        
        // 델리게이트 선언
        session?.delegate = self
        builder?.delegate = self
        builder?.dataSource = HKLiveWorkoutDataSource(healthStore: healthStore,
                                                      workoutConfiguration: configuration)

    }
    
    // 워치 경기 기록 시작
    private func startWorkoutSession() {
        
        let startDate = Date()
        session?.startActivity(with: startDate)
        builder?.beginCollection(withStart: startDate) { (_, _) in
            // The workout has started.
        }
        // 위치 정보 수집
        locationManager.startUpdatingLocation()

        // 헬스킷에서 나이 정보를 통해 적절한 최대심박수 찾기
        matrics.computeProperMaxHeartRate(with: healthStore)
        
        
        // collect motion information
        startMotionDetaction()

        // 워치 세션을 원격 세션과 연동
        Task {
            do {
                try await session?.startMirroringToCompanionDevice()
            } catch {
                NSLog("Error in mirroring", error.localizedDescription)
            }
        }
    }

    private func startMotionDetaction() {
        motionManager.startActivityUpdates(to: .main) { [weak self] activity in
            guard let activity = activity else { return }

            // state change
            if activity.unknown || activity.running || activity.walking {
                self?.isStationaryDetacted = false
            } else if activity.stationary {
                self?.isStationaryDetacted = true
            }
        }
    }

    // 워치 경기 기록 종료
    func endWorkoutSession(_ date: Date) async throws {
        do {
            try await builder?.endCollection(at: date)
        } catch {
            throw SessionError.failureBuilderEnd
        }

        guard let workout = try await builder?.finishWorkout() else {
            throw SessionError.failureFinishWorkout
        }

        self.workout = workout

        let metadata = self.matrics.getMetadata()

        // Route 생성 시도, 실패 시 메타데이터를 HKWorkout에 직접 저장
        if let route = try? await routeBuilder?.finishRoute(
            with: workout,
            metadata: metadata
        ) {
            Task { @MainActor in
                self.route = route
            }
        } else {
            // Route 실패 시 메타데이터를 workout 자체에 첨부
            do {
                try await healthStore.addMetadata(metadata, to: workout)
                NSLog("endWorkoutSession: route failed, metadata saved to workout directly")
            } catch {
                NSLog("endWorkoutSession: failed to save metadata to workout: \(error.localizedDescription)")
            }
        }
    }
    
    // 워치 경기 기록 초기화
    func resetWorkout() {
        builder = nil
        workout = nil
        session = nil
        
        matrics.reset()
    }
    
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
        self.showingSummaryView = true
    }
}

// MARK: - WorkoutData 수집시 동작하는 델리게이트
extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState,
                        from fromState: HKWorkoutSessionState, date: Date) {
        NSLog("WorkOutSession 변화 감지: \(toState)")
        Task { @MainActor in
            self.running = toState == .running
            startMotionDetaction()
        }
        if [HKWorkoutSessionState.paused, .stopped, .ended].contains(toState) {
            self.motionManager.stopActivityUpdates()
        }

        /// Save Wokrout, Route
        if toState == .ended {
            Task { @MainActor in
                do {
                    try await endWorkoutSession(date)
                } catch {
                    NSLog(error.localizedDescription)
                }
            }
        }
    }
    
    // MARK: - 앱이 비정상적으로 Workout을 종료 시킨다.
    /// 시기상 아래 함수보다 먼저 불림
    /// `func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState,`
    // TODO: - 어떤 일을 해야할까? 비정상 종료를 할 때 어떻게 해야할까? 워치가 절전 모드로 간다던가, 이런 데이터들은...?
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) { }

    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) { }

    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder,
                        didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else {
                return // Nothing to do.
            }
            
            guard let statistics = workoutBuilder.statistics(for: quantityType) else {
                continue
            }
            // Update the published values.
            matrics.updateForStatistics(statistics)
        }
    }
}

// MARK: - 위치 정보 수집시 동작하는 델리게이트
extension WorkoutManager {
    // MARK: - 위치 정보가 수집되면 불리는 메서드
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Filter the raw data.
        let filteredLocations = locations.filter { (location: CLLocation) -> Bool in
            location.horizontalAccuracy <= 50.0
        }
        
        guard !filteredLocations.isEmpty else {
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
        checkLocationAuthorization()
        objectWillChange.send()
    }

    func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            NSLog("위치 권한 결정 안됨")
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            NSLog("위치 권한 제한됨")
        case .denied:
            NSLog("위치 권한 거부")
        case .authorizedAlways, .authorizedWhenInUse:
            NSLog("위치 권한 항상 허용 혹은 사용 중 허용")
            locationManager.startUpdatingLocation()
        @unknown default:
            NSLog(locationManager.authorizationStatus.rawValue.description)
        }
    }
}
