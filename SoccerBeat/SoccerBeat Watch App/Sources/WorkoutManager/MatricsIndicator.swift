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
            guard heartRate.isFinite, heartRate > 0 else {
                heartZone = 1
                return
            }
            hasHeartRateData = true
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
    // Sprint 판정은 CoreLocation 속도를 수집하는 Watch 타깃에서만 수행한다.
    #if os(watchOS)
    private var sprintDetector = SprintDetector()
    #endif


    // MARK: - Distance
    @Published var distanceMeter: Double = 0
    @Published private(set) var hasDistanceData = false
    @Published private(set) var hasHeartRateData = false
    @Published private(set) var hasCaloriesData = false
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
    var isDistanceActive: Bool { hasDistanceData }
    private var timer: Timer?
    private var zone5Count = 0
    // 데이터 상수 선언
    var properMaxHeartRate: Double? // 신체 나이에 맞는 적절한 최대심박수.
    let sprintSpeed: Double = 5.56 // 2.78ms == 10km/h 비교에 사용되는 스프린트 변수 상수 값. 현재는 20km/h 기준

    // 데이터 기록 변수
    var saveMinHeartRate: Int = 300
    var saveMaxHeartRate: Int = 0
    var saveHeartRates: [Int] = []

    // 데이터 표기 변수
    @Published var energy: Double = 0 // 활동 칼로리 (kcal)
    @Published private var peakPower = PeakPower()
    var power: Double { peakPower.watts ?? 0 }
    var hasPowerData: Bool { peakPower.watts != nil }
    var maxSpeedMPS: Double = 0.0
    var acceleration: Double = 0.0
    var vo2Max: Double = 0.0

    // TODO: - WorkoutData로 반환하도록 설정
    func getMetadata() -> [String: Any] {
        var metadata: [String: Any] = [
            "MaxSpeed": maxSpeedMPS, // m/s
            "SprintCount": sprintCount,
            "MinHeartRate": saveMinHeartRate == 300 ? 0 : saveMinHeartRate,
            "MaxHeartRate": saveMaxHeartRate,
            "HeartRates": saveHeartRates.map {String($0)}.joined(separator: ","),
            "Vo2Max": vo2Max,
            "Distance": distanceMeter / 1000, // km; round only for display.
            "Acceleration": acceleration,
            "Calories": Int(energy.rounded(.toNearestOrAwayFromZero))
        ]

        metadata["HasPowerData"] = hasPowerData
        if hasPowerData { metadata["Power"] = power }
        metadata["PowerSource"] = hasPowerData ? "healthKitRunningPower" : "unavailable"
        metadata["HasDistanceData"] = hasDistanceData
        metadata["HasHeartRateData"] = hasHeartRateData
        metadata["HasCaloriesData"] = hasCaloriesData
        if !hasDistanceData { metadata.removeValue(forKey: "Distance") }
        if !hasCaloriesData { metadata.removeValue(forKey: "Calories") }
        if !hasHeartRateData {
            ["MinHeartRate", "MaxHeartRate", "HeartRates"].forEach { metadata.removeValue(forKey: $0) }
        }

        #if os(watchOS)
        metadata["SprintCriteriaVersion"] = 3
        metadata["SoccerMaximumSpeedMPS"] = SprintDetector.maximumSpeedMPS
        metadata["SprintSpeedSource"] = "coreLocation"
        metadata["SprintValidSampleCount"] = sprintDetector.validSampleCount
        metadata["SprintDiscardedSampleCount"] = sprintDetector.discardedSampleCount
        metadata["HasSpeedData"] = sprintDetector.hasConfirmedSpeed
        if !sprintDetector.hasConfirmedSpeed {
            metadata.removeValue(forKey: "MaxSpeed")
            metadata.removeValue(forKey: "SprintCount")
        }
        #endif

        return metadata
    }
    
    func computeProperMaxHeartRate(with store: HKHealthStore) {
        do {
            let birthYear = try store.dateOfBirthComponents().year
            let currentYear = Calendar.current.component(.year, from: Date())
            properMaxHeartRate = birthYear.map { Double(220 - (currentYear - $0)) } ?? 190
        } catch {
            properMaxHeartRate = 190
        }
    }
    
    // MARK: - Heart Rate Setup -> MatricsIndicator
    func computeHeartZone(_ heartRate: Double) -> Int {
        let maximum = properMaxHeartRate ?? 190
        if heartRate < maximum * 0.6 {
            return 1
        } else if heartRate < maximum * 0.7 {
            return 2
        } else if heartRate < maximum * 0.8 {
            return 3
        } else if heartRate < maximum * 0.9 {
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
        saveMinHeartRate = 0
        saveHeartRates = []
        
        energy = 0
        distanceMeter = 0
        hasDistanceData = false
        hasHeartRateData = false
        hasCaloriesData = false
        maxSpeedMPS = 0
        speedMPS = 0
        isSprint = false
        sprintCount = 0
        recentSprintSpeedMPS = 0
        acceleration = 0
        peakPower = PeakPower()

        #if os(watchOS)
        // 재시작 시 이전 경기의 Sprint 후보 구간이 이어지지 않도록 판정 상태도 함께 초기화한다.
        sprintDetector.reset()
        #endif
    }
    
    private func resetZone5Timer() {
        self.timer?.invalidate()
        self.timer = .none
        self.zone5Count = 0
    }
    
    #if os(watchOS)
    func updateSpeed(
        timestamp: Date,
        speed: Double,
        speedAccuracy: Double,
        horizontalAccuracy: Double,
        isAutomotive: Bool,
        receivedAt: Date = .now
    ) {
        sprintDetector.process(
            timestamp: timestamp,
            speed: speed,
            speedAccuracy: speedAccuracy,
            horizontalAccuracy: horizontalAccuracy,
            isAutomotive: isAutomotive,
            receivedAt: receivedAt
        )

        speedMPS = sprintDetector.speedMPS
        maxSpeedMPS = sprintDetector.maxSpeedMPS
        isSprint = sprintDetector.isSprint
        sprintCount = sprintDetector.sprintCount
        recentSprintSpeedMPS = sprintDetector.recentSprintSpeedMPS
        acceleration = sprintDetector.maxAccelerationMPS2
    }

    func pauseSpeed() {
        // 일시정지 전후의 위치 샘플이 같은 Sprint 구간으로 이어지지 않도록 후보 상태만 끊는다.
        sprintDetector.pause()
        speedMPS = sprintDetector.speedMPS
        isSprint = sprintDetector.isSprint
    }

    func currentSpeed(at date: Date) -> Double? {
        sprintDetector.currentSpeed(at: date)
    }

    var hasSpeedData: Bool { sprintDetector.hasConfirmedSpeed }
    #endif

    /// 이게 한번만 불리는게 아니라, 여러 세트가 있을 수 있음
    /// 예를들어 경기를 1쿼터, 2쿼터 나눠서 할거면, 지금처럼 메트릭스 인디케이터가 여러개가 생길 수도 있는 것임.
    /// 아니면 애초에 heartRate, distanceMeter, SpeedMPS 등을 배열로 선언해서 각 쿼터에 얼마나 했는지를 추정할 수도 있겠음
    @MainActor
    func updateForStatistics(_ statistics: HKStatistics) {
        switch statistics.quantityType {
        case HKQuantityType.quantityType(forIdentifier: .heartRate):
            let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
            if let value = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit), value.isFinite, value > 0 {
                heartRate = value
            }
        case HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning):
            updateDistance(statistics.sumQuantity()?.doubleValue(for: .meter()))
        case HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned):
            updateCalories(statistics.sumQuantity()?.doubleValue(for: .kilocalorie()))
        case HKQuantityType.quantityType(forIdentifier: .runningPower):
            updatePower(statistics.maximumQuantity()?.doubleValue(for: .watt()))
        case HKQuantityType.quantityType(forIdentifier: .vo2Max):
            if let value = statistics.mostRecentQuantity()?.doubleValue(for: HKUnit(from: "ml/kg*min")), value.isFinite, value > 0 {
                calculateMaxVo2Max(before: vo2Max, current: value)
            }
        default:
            return
        }
    }

    @MainActor
    func updateDistance(_ measurement: Double?) {
        guard let value = measurement, value.isFinite, value >= 0 else { return }
        distanceMeter = max(distanceMeter, value)
        hasDistanceData = true
    }

    @MainActor
    func updateCalories(_ measurement: Double?) {
        guard let value = measurement, value.isFinite, value >= 0 else { return }
        energy = max(energy, value)
        hasCaloriesData = true
    }
    
    func updatePower(_ measurement: Double?) {
        peakPower.observe(measurement)
    }

    private func calculateMaxVo2Max(before: Double, current: Double) {
        vo2Max = max(before, current)
    }
}
