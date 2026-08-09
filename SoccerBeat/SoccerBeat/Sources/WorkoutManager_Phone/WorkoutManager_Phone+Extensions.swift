//  WorkoutManager_Phone+Extensions.swift
//  아이폰과 워치 경기 관리 매니저가 통합되었습니다.
//  개별 매니저는 exntesnion 으로 관리합니다.
//

import Combine
import CoreLocation
import HealthKit
import SwiftUI

enum HealthKitError: Error {
    case failureConvertingRouteAndMeta
}

extension WorkoutManager {
    @MainActor
    func requestAuthorization() async throws {
        NSLog("requestAuthorization: request user authorization..")

        // 해당 기기가 헬스킷을 사용할 수 있는지 확인 함
        guard HKHealthStore.isHealthDataAvailable() else {
            NSLog("requestAuthorization: health data not available")
            return
        }

        // 요청 완료는 개별 읽기 권한 허용을 뜻하지 않으므로 결과를 권한 상태로 해석하지 않습니다.
        // https://developer.apple.com/documentation/healthkit/hkhealthstore/requestauthorization(toshare:read:)
        try await healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead)
    }

    func delete(at offset: IndexSet) async throws {
        for index in offset {
            try await healthStore.delete(hkWorkouts[index])
        }
        hkWorkouts.remove(atOffsets: offset)
        Task { @MainActor in
            self.onWorkoutRemoved.send(offset)
        }
    }

    func fetchWorkoutData() async {
        await MainActor.run {
            isLoading = true
        }

        // Fetch from HealthStore
        self.hkWorkouts = await fetchHKWorkouts()
        if self.hkWorkouts.isEmpty {
            NSLog("fetchWorkoutData: no workouts found. Check HealthKit read permissions in Settings > Health > SoccerBeat")
        }

        // Convert WorkoutData(Bussiness Model)
        var workoutData = [WorkoutData]()
        for (index, workout) in self.hkWorkouts.enumerated() {
            do {
                let workoutDatum = try await convert(from: workout, at: index)
                workoutData.append(workoutDatum)
            } catch {
                NSLog(error.localizedDescription)
                continue
            }
        }
        await settingForChartView(workoutData)
        monthly = divideWorkoutsByMonthly(workoutData)

        await MainActor.run { [workoutData] in
            isLoading = false
            self.fetchWorkoutsSuccess.send(workoutData)
        }
    }

    private func convert(from workout: HKWorkout, at index: Int) async throws -> WorkoutData {

        var latSum = 0.0
        var lonSum = 0.0
        var routes: [CLLocationCoordinate2D] = []
        var metadata: [String: Any] = [:]
        // dataError 제거: 값이 없으면 기본값(0)으로 표시

        // Route와 Metadata 가져오기 (실패해도 계속 진행)
        if let (locations, meta) = try? await convertToRouteAndMetadata(from: workout) {
            metadata = meta
            for location in locations {
                routes.append(CLLocationCoordinate2D(latitude: location.coordinate.latitude,
                                                     longitude: location.coordinate.longitude))
                latSum += location.coordinate.latitude
                lonSum += location.coordinate.longitude
            }
        }
        // Route metadata가 비어있으면 workout 자체의 metadata에서 fallback
        if metadata.isEmpty, let workoutMeta = workout.metadata {
            metadata = workoutMeta
        }

        let displayedTime = String(Int(workout.duration)/60) + " : " + String(Int(workout.duration) % 60)
        let dotCount = routes.isEmpty ? 1 : routes.count
        let hasMetadata = !metadata.isEmpty

        // Metadata에서 값 추출, 없으면 HKWorkout.statistics(for:)에서 fallback
        var distance = 0.0
        var sprintCount = 0
        var velocity = 0.0
        var maxHeartRate = 0
        var minHeartRate = 0
        var heartRates:[Int] = []
        var power = 0.0
        var calories = 0
        var vo2Max = 0.0

        // Distance: metadata → totalDistance → statistics → 시간 범위 샘플 쿼리
        if let distanceMeta: Double = metadata.getValue(forKey: "Distance"), distanceMeta > 0 {
            distance = distanceMeta
        } else if let hkDistance = workout.totalDistance?.doubleValue(for: .meterUnit(with: .kilo)), hkDistance > 0 {
            distance = Double(Int(hkDistance * 10)) / 10
        } else if let distanceStat = workout.statistics(for: HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!),
                  let sum = distanceStat.sumQuantity()?.doubleValue(for: .meterUnit(with: .kilo)), sum > 0 {
            distance = Double(Int(sum * 10)) / 10
        } else {
            // 워크아웃 시간 범위 내 거리 샘플 직접 쿼리
            let queriedDistance = await queryDistanceSamples(start: workout.startDate, end: workout.endDate)
            distance = Double(Int(queriedDistance * 10)) / 10
        }

        // Sprint (HKWorkout에 해당 통계 없음)
        if let sprintCountMeta: Int = metadata.getValue(forKey: "SprintCount") {
            sprintCount = sprintCountMeta
        } else if !hasMetadata {
            // metadata 없는 워크아웃은 sprint 0으로 처리
        }

        // Velocity
        if let velocityMeta: Double = metadata.getValue(forKey: "MaxSpeed") {
            velocity = Double(((velocityMeta) * 3.6).rounded(at: 2)) ?? 0
        } else if let speedStat = workout.statistics(for: HKQuantityType.quantityType(forIdentifier: .runningSpeed)!) {
            let speedUnit = HKUnit(from: "m/s")
            if let maxSpeed = speedStat.maximumQuantity()?.doubleValue(for: speedUnit) {
                velocity = Double(Int(maxSpeed * 3.6 * 100)) / 100
            } else if let avgSpeed = speedStat.averageQuantity()?.doubleValue(for: speedUnit) {
                velocity = Double(Int(avgSpeed * 3.6 * 100)) / 100
            }
        }

        // Power
        if let powerMeta: Double = metadata.getValue(forKey: "Power") ??
            metadata.getValue(forKey: "Acceleration") {
            power = powerMeta
        } else if let powerStat = workout.statistics(for: HKQuantityType.quantityType(forIdentifier: .runningPower)!) {
            if let maxPower = powerStat.maximumQuantity()?.doubleValue(for: .watt()) {
                power = Double(Int(maxPower * 10)) / 10
            } else if let avgPower = powerStat.averageQuantity()?.doubleValue(for: .watt()) {
                power = Double(Int(avgPower * 10)) / 10
            }
        }

        // Heart Rate
        let hrType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let hrUnit = HKUnit.count().unitDivided(by: .minute())
        if let maxHeartRateMeta: Int = metadata.getValue(forKey: "MaxHeartRate") {
            maxHeartRate = maxHeartRateMeta
        } else if let hrStat = workout.statistics(for: hrType),
                  let maxHR = hrStat.maximumQuantity()?.doubleValue(for: hrUnit) {
            maxHeartRate = Int(maxHR)
        }

        if let minHeartRateMeta: Int = metadata.getValue(forKey: "MinHeartRate") {
            minHeartRate = minHeartRateMeta
        } else if let hrStat = workout.statistics(for: hrType),
                  let minHR = hrStat.minimumQuantity()?.doubleValue(for: hrUnit) {
            minHeartRate = Int(minHR)
        }

        if let heartRatesMeta: String = metadata.getValue(forKey: "HeartRates") {
            heartRates = heartRatesMeta.split(separator: ",").map { Int($0) ?? 0 }
        }

        // Calories
        if let caloriesMeta: Int = metadata.getValue(forKey: "Calories") {
            calories = caloriesMeta
        } else if let hkCalories = workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()) {
            calories = Int(hkCalories)
        } else if let calStat = workout.statistics(for: HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!),
                  let sum = calStat.sumQuantity()?.doubleValue(for: .kilocalorie()) {
            calories = Int(sum)
        }

        // Vo2Max
        if let vo2MaxMeta: Double = metadata.getValue(forKey: "Vo2Max") {
            vo2Max = vo2MaxMeta
        } else if let vo2Stat = workout.statistics(for: HKQuantityType.quantityType(forIdentifier: .vo2Max)!),
                  let maxVo2 = vo2Stat.maximumQuantity()?.doubleValue(for: HKUnit(from: "ml/kg*min")) {
            vo2Max = Double(Int(maxVo2 * 10)) / 10
        }

        return WorkoutData(dataID: index+1,
                           date: dateFormatter.string(from: workout.startDate),
                           time: displayedTime,
                           distance: distance,
                           sprint: sprintCount,
                           velocity: velocity, // km/h
                           power: power,
                           heartRate: ["max": maxHeartRate,
                                       "min": minHeartRate],
                           heartRates: heartRates,
                           route: routes,
                           center: [latSum / Double(dotCount),
                                    lonSum / Double(dotCount)],
                           calories: calories,
                           vo2Max: vo2Max,
                           error: false)
    }

    private static let soccerBeatSourceKeyword = "SoccerBeat"

    private func fetchHKWorkouts() async -> [HKWorkout] {
        let soccerPredicate = HKQuery.predicateForWorkouts(with: .soccer)
        let runningPredicate = HKQuery.predicateForWorkouts(with: .running)
        let combinedPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [soccerPredicate, runningPredicate])

        do {
            let data = try await withCheckedThrowingContinuation { (
                continuation: CheckedContinuation<[HKSample], Error>
            ) in
                let query = HKSampleQuery(
                    sampleType: .workoutType(),
                    predicate: combinedPredicate,
                    limit: HKObjectQueryNoLimit,
                    sortDescriptors: [NSSortDescriptor(keyPath: \HKSample.startDate, ascending: false)],
                    resultsHandler: { _, samples, error in
                        if let error = error {
                            continuation.resume(throwing: error)
                        } else {
                            continuation.resume(returning: samples ?? [])
                        }
                    }
                )
                healthStore.execute(query)
            }
            guard let workouts = data as? [HKWorkout] else {
                NSLog("fetchHKWorkouts: failed to cast samples to [HKWorkout]")
                return []
            }

            // 디버그: 각 워크아웃의 타입과 소스 확인
            for workout in workouts {
                NSLog("fetchHKWorkouts: type=\(workout.workoutActivityType.rawValue) source=\(workout.sourceRevision.source.bundleIdentifier) date=\(workout.startDate)")
            }

            // .soccer는 전부 포함, .running은 SoccerBeat Watch App에서 기록한 것만 포함
            let filtered = workouts.filter { workout in
                if workout.workoutActivityType == .soccer {
                    return true
                }
                return workout.sourceRevision.source.bundleIdentifier.contains(Self.soccerBeatSourceKeyword)
            }

            NSLog("fetchHKWorkouts: fetched \(workouts.count) workouts, \(filtered.count) after filtering")
            return filtered
        } catch {
            NSLog("fetchHKWorkouts failed: \(error.localizedDescription)")
            return []
        }
    }

    /// 워크아웃 시간 범위 내 Walking+Running Distance 샘플을 직접 쿼리하여 합산 (km 단위)
    private func queryDistanceSamples(start: Date, end: Date) async -> Double {
        let distanceType = HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
        let predicate = HKQuery.predicateForSamples(withStart: start, end: end, options: .strictStartDate)

        do {
            let sum = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Double, Error>) in
                let query = HKStatisticsQuery(quantityType: distanceType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, statistics, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let sum = statistics?.sumQuantity()?.doubleValue(for: .meterUnit(with: .kilo)) {
                        continuation.resume(returning: sum)
                    } else {
                        continuation.resume(returning: 0.0)
                    }
                }
                healthStore.execute(query)
            }
            return sum
        } catch {
            NSLog("queryDistanceSamples failed: \(error.localizedDescription)")
            return 0.0
        }
    }

    // HKWorkout + Metadata
    func convertToRouteAndMetadata(from workout: HKWorkout) async throws -> ([CLLocation], [String: Any]) {
        let byWorkoutPredicate = HKQuery.predicateForObjects(from: workout)

        let samples = try await withCheckedThrowingContinuation { (
            continuation: CheckedContinuation<[HKSample], Error>
        ) in
            let query = HKAnchoredObjectQuery(
                type: HKSeriesType.workoutRoute(),
                predicate: byWorkoutPredicate,
                anchor: nil,
                limit: HKObjectQueryNoLimit,
                resultsHandler: { query, samples, deletedObjects, anchor, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: samples ?? [])
                    }
                }
            )
            healthStore.execute(query)
        }

        let routes = samples as? [HKWorkoutRoute]
        guard let route = routes?.first else {
            // Route 자체가 없음 → 위치 데이터 없이 빈 값 반환
            return ([], [:])
        }

        // Route에서 위치 데이터 추출
        let locations = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[CLLocation], Error>) in
            var allLocations = [CLLocation]()
            let query = HKWorkoutRouteQuery(route: route) { (query, locationsOrNil, done, errorOrNil) in
                if let error = errorOrNil {
                    continuation.resume(throwing: error)
                    return
                }

                if let locations = locationsOrNil {
                    allLocations += locations
                }

                if done {
                    continuation.resume(returning: allLocations)
                }
            }
            healthStore.execute(query)
        }

        // Metadata는 있으면 반환, 없으면 빈 딕셔너리
        return (locations, route.metadata ?? [:])
    }
}

// MARK: - Chart Methods

extension WorkoutManager {

    private func settingForChartView(_ workouts: [WorkoutData]) async {
        let fourGames = await MainActor.run {
            readRecentMatches(from: workouts, count: 4)
                .sorted(by: { $0.formattedDate < $1.formattedDate })
                .appendingBlanks(upTo: 4, with: .blankExample)
        }
        await MainActor.run {
            recent4Games = fourGames
            recentGames = workouts.sorted(by: { $0.formattedDate < $1.formattedDate })
        }
    }

    private func readRecentMatches(from workouts: [WorkoutData], count: Int) -> [WorkoutData] {
        guard !workouts.isEmpty else { return [] }
        if workouts.count < count {
            return Array(workouts[0..<workouts.count])
        } else {
            return Array(workouts[0..<count])
        }
    }

    private func divideWorkoutsByMonthly(_ workouts: [WorkoutData]) -> [String: [WorkoutData]] {
        return Dictionary(grouping: workouts) {
            String($0.date.prefix(7))  // Assuming date format is "YYYY-MM-DD"
        }
    }
}

private extension Array where Element == WorkoutData {
    func appendingBlanks(upTo count: Int, with blank: WorkoutData) -> [WorkoutData] {
        let blankCount = Swift.max(0, count - self.count)
        return Array(repeating: blank, count: blankCount) + self
    }
}

// MARK: - CLLocationManagerDelegate

extension WorkoutManager {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let statusMessage: String
        switch manager.authorizationStatus {
        case .authorizedAlways:
            statusMessage = "항상 허용"
        case .notDetermined:
            statusMessage = "not decision"
        case .restricted:
            statusMessage = "ask later"
        case .denied:
            statusMessage = "denied"
        case .authorizedWhenInUse:
            statusMessage = "when in use"
        @unknown default:
            statusMessage = "default"
        }
        NSLog(statusMessage)
    }
}

// MARK: - 워치 세션 연동 핸들러
extension WorkoutManager {
    // 폰에서 앱 실행 시 워치의 원격 세션과 연동함
    func retrieveRemoteSession() {
        /**
         HealthKit calls this handler when a session starts mirroring.
         */
        self.healthStore.workoutSessionMirroringStartHandler = { mirroredSession in
            Task { @MainActor in
                self.session = mirroredSession
            }
        }
    }
}
