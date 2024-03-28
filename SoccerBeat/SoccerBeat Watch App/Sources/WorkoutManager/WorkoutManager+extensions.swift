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
                    let metadata = self?.matrics.getMetadata()
                    
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
            
            let statistics = workoutBuilder.statistics(for: quantityType)
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
            manager.startUpdatingLocation()
        case .authorizedWhenInUse:
            NSLog("위치 권한 사용중 허용")
            manager.startUpdatingLocation()
        @unknown default:
            NSLog(manager.authorizationStatus.rawValue.description)
        }
    }
}
