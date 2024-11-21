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
            
            if saveMinHeartRate == 0 {
                saveMinHeartRate = Int(heartRate) // by defaults, minimum HR is 0. Initial HR value becomes the minimum value.
            } else if saveMinHeartRate > Int(heartRate){
                saveMinHeartRate = Int(heartRate)
            }
            
            if saveMaxHeartRate < Int(heartRate) {
                saveMaxHeartRate = Int(heartRate)
            }
            
            if heartRate != 0 {
                self.saveHeartRates.append(Int(heartRate))
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
    let sprintSpeed: Double = 5.56 // 2.78ms == 10km/h 비교에 사용되는 스프린트 변수 상수 값. 현재는 20km/h 기준

    // 데이터 기록 변수
    var saveMinHeartRate: Int = 0
    var saveMaxHeartRate: Int = 0
    var saveHeartRates: [Int] = []

    // 데이터 표기 변수
    var energy: Double = 0 // 칼로리
    var power: Double = 0.0
    var maxSpeedMPS: Double = 0.0
    var acceleration: Double = 0.0
    var vo2Max: Double = 0.0

    // TODO: - WorkoutData로 반환하도록 설정
    func getMetadata() -> [String: Any] {
        return [
            "MaxSpeed": Double(maxSpeedMPS.rounded(at: 2)), // m/s
            "SprintCount": sprintCount,
            "MinHeartRate": saveMinHeartRate,
            "MaxHeartRate": saveMaxHeartRate,
            "HeartRates": saveHeartRates.map {String($0)}.joined(separator: ","),
            "Vo2Max": Double(vo2Max.rounded(at: 1)),
            "Distance": Double((distanceMeter / 1000).rounded(at: 1)), // km
            "Power": Double(power.rounded(at: 1)), // w
            "Acceleration": Double(acceleration.rounded(at: 1)),
            "Calories": Int(energy)
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
        saveHeartRates = []
        
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
    
    /// 이게 한번만 불리는게 아니라, 여러 세트가 있을 수 있음
    /// 예를들어 경기를 1쿼터, 2쿼터 나눠서 할거면, 지금처럼 메트릭스 인디케이터가 여러개가 생길 수도 있는 것임.
    /// 아니면 애초에 heartRate, distanceMeter, SpeedMPS 등을 배열로 선언해서 각 쿼터에 얼마나 했는지를 추정할 수도 있겠음
    func updateForStatistics(_ statistics: HKStatistics) {
        DispatchQueue.main.async {
            switch statistics.quantityType {
            case HKQuantityType.quantityType(forIdentifier: .heartRate):
                let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
                self.heartRate = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit) ?? 0.0
            case HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning):
                let meterUnit = HKUnit.meter()
                self.distanceMeter = statistics.sumQuantity()?.doubleValue(for: meterUnit) ?? 0
            case HKQuantityType.quantityType(forIdentifier: .runningSpeed), HKQuantityType.quantityType(forIdentifier: .walkingSpeed):
                let oldSpeedMPS = self.speedMPS
                self.speedMPS = statistics.mostRecentQuantity()?.doubleValue(for:  HKUnit.init(from: "m/s")) ?? 0
                self.calculateSpeedMatrics(before: oldSpeedMPS, current: self.speedMPS)
            case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
                self.energy = statistics.sumQuantity()?.doubleValue(for: HKUnit.kilocalorie()) ?? 0
            case HKQuantityType.quantityType(forIdentifier: .runningPower):
                let oldPower = self.power
                self.power = statistics.mostRecentQuantity()?.doubleValue(for: HKUnit.watt()) ?? 0
                self.calculateMaxPower(before: oldPower, current: self.power)
            case HKQuantityType.quantityType(forIdentifier: .vo2Max):
                let oldvo2Max = self.vo2Max
                self.vo2Max = statistics.mostRecentQuantity()?.doubleValue(for: HKUnit(from: "ml/kg*min")) ?? 0
                self.calculateMaxVo2Max(before: oldvo2Max, current: self.vo2Max)
            default:
                return
            }
        }
    }
    
    private func calculateSpeedMatrics(before: Double, current: Double) {
        acceleration = max(current - before, acceleration)
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
        
        // 직전 스프린트 최고 속도
        if isSprint {
            recentSprintSpeedMPS = max(recentSprintSpeedMPS, current)
        }
    }
    
    private func calculateMaxPower(before: Double, current: Double) {
        power = max(power, current)
    }
    
    private func calculateMaxVo2Max(before: Double, current: Double) {
        vo2Max = max(vo2Max, current)
    }
}
