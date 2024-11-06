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
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState,
                        from fromState: HKWorkoutSessionState, date: Date) {
        NSLog("WorkOutSession 변화 감지: \(toState)")
        Task { @MainActor in
            self.running = toState == .running
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
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        
    }
}

// MARK: - WorkoutData 수집시 동작하는 델리게이트
extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        
    }
    
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder,
                        didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else {
                return // Nothing to do.
            }
            
            guard let statistics = workoutBuilder.statistics(for: quantityType) else { continue
            }
            // Update the published values.
            matrics.updateForStatistics(statistics)
        }
    }
}

// MARK: - 위치 정보 수집시 동작하는 델리게이트
extension WorkoutManager: CLLocationManagerDelegate {
    // MARK: - 위치 정보가 수집되면 불리는 메서드
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // Filter the raw data.
        let filteredLocations = locations.filter { (location: CLLocation) -> Bool in
            // 필터 조정치 필요, 예시 121, 66등으로 20 미만인 필터 데이터가 존재하지 않음
            location.horizontalAccuracy <= 20.0
        }
        
        // 성공치를 외부에 데이터로 넘기기, 혹은 에러 뭐시기를 하는게 좋으려나?
        guard !filteredLocations.isEmpty else {
            // 실패해도 저장을 하네?
            routeBuilder?.insertRouteData(locations, completion: { _, _ in
            })
            return
        }
        
        // 성공해도 저장을 하네?
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
    }

    func checkLocationAuthorization() {
        hasLocationAuthorization = false
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
            hasLocationAuthorization = true
        @unknown default:
            NSLog(locationManager.authorizationStatus.rawValue.description)
        }
    }
}
