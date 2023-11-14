//
//  WorkoutData.swift
//  SoccerBeat
//
//  Created by daaan on 11/1/23.
//

import Foundation
import CoreLocation

struct WorkoutData: Hashable, Equatable, Identifiable {
    var id: UUID = UUID()
    var dataID: Int
    let date: String
    let time: String
    let distance: Double // total distance
    let sprint: Int // sprint counter
    let velocity: Double // maximum velocity. km/h
    var heartRate: [String: Int] // min, max of heartRate. ex) ["max": 00, "min": 00]
    var route: [CLLocationCoordinate2D] // whole route
    var center: [Double] // center of heatmap
}

extension CLLocationCoordinate2D: Hashable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.latitude) 
    }
}


// MARK: - 현재 위치 받아오는 코드
extension WorkoutData {
    var location: String {
        get async throws {
            guard let last = route.last else { return "마지막 위치가 지정되지 않았습니다." }
            guard let loadedAddress = try? await showCurrentAddress(last) else { return "주소값을 변환하는데 실패했습니다." }
            return loadedAddress
        }
    }
    
    private func showCurrentAddress(_ location: CLLocationCoordinate2D?) async throws -> String {
        guard let position = location else { return "" }
        let locale = Locale(identifier: "Ko-kr")
        let geoCoder = CLGeocoder()
        
        let location : CLLocation = CLLocation(latitude: position.latitude, longitude: position.longitude)
        
        var currentAddress = ""
        guard let marker = try await geoCoder.reverseGeocodeLocation(location, preferredLocale: locale).first
            else { return "" }
        
        if let administrativeArea = marker.administrativeArea {
            currentAddress += administrativeArea + " "
        }
        if let locality = marker.locality {
            currentAddress += locality + " "
        }
        if let subLocality = marker.subLocality {
            currentAddress += subLocality + " "
        }
        if let subThoroughfare = marker.subThoroughfare {
            currentAddress += subThoroughfare + " "
        }
        return currentAddress
    }
}
