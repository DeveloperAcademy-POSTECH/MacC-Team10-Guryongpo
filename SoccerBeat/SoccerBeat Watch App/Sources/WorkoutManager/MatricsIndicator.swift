//
//  MatricsIndicator.swift
//  SoccerBeat Watch App
//
//  Created by Gucci on 3/12/24.
//

import HealthKit
import SwiftUI

final class MatricsIndicator: NSObject, ObservableObject {
    
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
    @Published var isSprint: Bool = false
    @Published var recentSprintSpeedMPS = 0.0
    @Published var speedMPS: Double = 0.0
    

    // MARK: - Distance
    @Published var distanceMeter: Double = 0
    @Published var sprintCount: Int = 0 // default setup
    
    
    // MARK: - 심박수 위험 지대 감지
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
    
    private var bpmString: String { String(heartRate.formatted(.number.precision(.fractionLength(0)))) }
    var isBPMActive: Bool { bpmString != "0" }
    var bpmForText: String { isBPMActive ? bpmString : "---" }
    var isDistanceActive: Bool { distanceMeter != 0 }
    private var timer: Timer?
    private var zone5Count = 0
    // 데이터 상수 선언
    var properMaxHeartRate: Double? // 신체 나이에 맞는 적절한 최대심박수.
    let sprintSpeed: Double = 2.78 // 2.78ms == 10km/h 비교에 사용되는 스프린트 변수 상수 값.

    // 데이터 기록 변수
    var saveMinHeartRate: Int = 300 // 심박최고수 저장
    var saveMaxHeartRate: Int = 0

    // 데이터 표기 변수
    var energy: Double = 0 // 칼로리
    var power: Double = 0.0
    var maxSpeedMPS: Double = 0.0

    // TODO: - WorkoutData로 반환하도록 설정
    func getMetadata() -> [String: Any] {
        return [
            "MaxSpeed": Double(maxSpeedMPS.rounded(at: 2)), // m/s
            "SprintCount": sprintCount,
            "MinHeartRate": saveMinHeartRate != 300 ? saveMinHeartRate : 0,
            "MaxHeartRate": saveMaxHeartRate,
            "Distance": Double((distanceMeter / 1000).rounded(at: 1)), // km
            "Power": Double(power.rounded(at: 1)) // w
        ]
    }
    
    func computeProperMaxHeartRate(with store: HKHealthStore) {
        do {
            let birthYear = try store.dateOfBirthComponents().year
            let currentYear = Calendar.current.component(.year, from: Date())
            properMaxHeartRate = Double(220 - (currentYear - birthYear!))
        } catch {
            properMaxHeartRate = 190
        }
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
    
    func reset() {
        heartRate = 0
        heartZone = 1
        zone5Count = 0
        saveMaxHeartRate = 0
        saveMinHeartRate = 300
        
        distanceMeter = 0
        maxSpeedMPS = 0
        speedMPS = 0
        sprintCount = 0
        recentSprintSpeedMPS = 0
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
                self.distanceMeter = statistics.sumQuantity()?.doubleValue(for: meterUnit) ?? 0
            case HKQuantityType.quantityType(forIdentifier: .runningSpeed), HKQuantityType.quantityType(forIdentifier: .walkingSpeed):
                let oldSpeedMPS = self.speedMPS
                self.speedMPS = statistics.mostRecentQuantity()?.doubleValue(for:  HKUnit.init(from: "m/s")) ?? 0
                self.calculateSpeedMatrics(before: oldSpeedMPS, current: self.speedMPS)
            case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
                self.energy = statistics.sumQuantity()?.doubleValue(for: HKUnit(from: "kcal")) ?? 0
            case HKQuantityType.quantityType(forIdentifier: .runningPower):
                self.power = statistics.sumQuantity()?.doubleValue(for: HKUnit(from: "W")) ?? 0
            default:
                return
            }
        }
    }
    
    private func calculateSpeedMatrics(before: Double, current: Double) {
        // 최고 속도
        maxSpeedMPS = max(maxSpeedMPS, current)
        // 스프린트 카운트
        if !isSprint && speedMPS >= sprintSpeed {
            isSprint = true
            sprintCount += 1
            recentSprintSpeedMPS = 0.0
        } else if isSprint && current < sprintSpeed {
            isSprint = false
        }
        
        // 직전 스프린트 최대 속도
        if isSprint {
            recentSprintSpeedMPS = max(recentSprintSpeedMPS, current)
        }
    }
}
