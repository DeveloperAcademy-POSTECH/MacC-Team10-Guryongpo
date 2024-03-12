//
//  MatricsIndicator.swift
//  SoccerBeat Watch App
//
//  Created by Gucci on 3/12/24.
//

import HealthKit
import SwiftUI

final class MatricsIndicator: NSObject {
    
}

// MARK: - CLLocationManagerDelegate, MatricsIndicator
extension MatricsIndicator: CLLocationManagerDelegate {
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
    
    // MARK: - 위치 공유 권한 정보가 업데이트 되면 불리는 메서드,
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
