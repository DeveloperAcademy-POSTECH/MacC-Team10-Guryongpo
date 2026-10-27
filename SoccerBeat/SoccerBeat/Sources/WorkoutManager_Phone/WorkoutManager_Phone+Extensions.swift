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
    case failureCastingWorkoutSamples
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
        workoutObserverQueries.forEach { healthStore.stop($0) }
        workoutObserverQueries.removeAll()
        startObservingWorkoutChanges()
    }

    @MainActor
    func delete(at offset: IndexSet) async throws {
        let targets = offset.compactMap { hkWorkouts.indices.contains($0) ? hkWorkouts[$0] : nil }
        for workout in targets {
            try await healthStore.delete(workout)
            deletedWorkoutIDs.insert(workout.uuid)
            workoutCache.removeValue(forKey: workout.uuid)
            hkWorkouts.removeAll { $0.uuid == workout.uuid }
            await publishWorkouts(hkWorkouts, state: hkWorkouts.isEmpty ? .empty : .loaded)
        }
    }

    @MainActor
    func fetchWorkoutData() async {
        if workoutRefreshInProgress {
            workoutRefreshQueued = true
            return
        }
        workoutRefreshInProgress = true
        defer { workoutRefreshInProgress = false }
        repeat {
            workoutRefreshQueued = false
            workoutFetchState = .loading
            isLoading = true
            do {
                let fetchedWorkouts = try await fetchHKWorkouts()
                // An empty read can also mean that HealthKit data is not accessible yet.
                // Only an explicit delete/deletion update removes a previously loaded workout.
                if fetchedWorkouts.isEmpty && !workoutCache.isEmpty {
                    for id in workoutCache.keys {
                        workoutCache[id]?.hasRetrievalFailure = true
                    }
                    await publishWorkouts(hkWorkouts, state: .failed)
                } else {
                    var originals = Dictionary(uniqueKeysWithValues: hkWorkouts.map { ($0.uuid, $0) })
                    for (index, workout) in fetchedWorkouts.enumerated() {
                        let incoming = await convert(from: workout, at: index)
                        guard !deletedWorkoutIDs.contains(workout.uuid) else { continue }
                        workoutCache[workout.uuid] = incoming.preservingAvailableData(from: workoutCache[workout.uuid])
                        originals[workout.uuid] = workout
                    }
                    let retained = originals.values.filter { workoutCache[$0.uuid] != nil && !deletedWorkoutIDs.contains($0.uuid) }
                        .sorted { $0.startDate > $1.startDate }
                    await publishWorkouts(retained, state: retained.isEmpty ? .empty : .loaded)
                }
            } catch {
                NSLog("fetchWorkoutData failed: \(error.localizedDescription)")
                for id in workoutCache.keys { workoutCache[id]?.hasRetrievalFailure = true }
                await publishWorkouts(hkWorkouts, state: .failed)
            }
        } while workoutRefreshQueued
    }

    @MainActor
    private func publishWorkouts(_ originals: [HKWorkout], state: WorkoutFetchState) async {
        let originals = originals.filter { !deletedWorkoutIDs.contains($0.uuid) && workoutCache[$0.uuid] != nil }
        let records = originals.compactMap { workoutCache[$0.uuid] }
        settingForChartView(records)
        hkWorkouts = originals
        monthly = divideWorkoutsByMonthly(records)
        isLoading = false
        workoutFetchState = state
        fetchWorkoutsSuccess.send(records)
    }

    private func convert(from workout: HKWorkout, at index: Int) async -> WorkoutData {
        var pausedIntervals: [DateInterval] = []
        var pauseStart: Date?
        for event in (workout.workoutEvents ?? []).sorted(by: { $0.dateInterval.start < $1.dateInterval.start }) {
            switch event.type {
            case .pause, .motionPaused:
                if pauseStart == nil { pauseStart = event.dateInterval.start }
            case .resume, .motionResumed:
                if let start = pauseStart, event.dateInterval.start > start {
                    pausedIntervals.append(DateInterval(start: start, end: event.dateInterval.start))
                }
                pauseStart = nil
            default: break
            }
        }
        if let start = pauseStart, workout.endDate > start {
            pausedIntervals.append(DateInterval(start: start, end: workout.endDate))
        }

        var routeResult = await convertToRouteAndMetadata(from: workout)
        let expectedRoutePoints: Int = workout.metadata?.getValue(forKey: "SoccerBeatRoutePointCount") ?? 0
        if routeResult.locations.isEmpty, routeResult.availability == .unavailable, expectedRoutePoints > 0 {
            routeResult.availability = .pending
        }
        let locations = routeResult.locations
        let metadata = WorkoutRecordReconciliation.metadata(workout: workout.metadata ?? [:], routes: routeResult.metadata)
        var retrievalFailed = routeResult.hasFailure
        var routeSpeed = SprintDetector()
        var previousRouteTimestamp: Date?
        for location in locations {
            if let previous = previousRouteTimestamp, pausedIntervals.contains(where: {
                max(previous, $0.start) < min(location.timestamp, $0.end)
            }) { routeSpeed.pause() }
            previousRouteTimestamp = location.timestamp
            let isPaused = pausedIntervals.contains { $0.start <= location.timestamp && location.timestamp < $0.end }
            if !isPaused {
                routeSpeed.process(timestamp: location.timestamp, speed: location.speed,
                                   speedAccuracy: location.speedAccuracy, horizontalAccuracy: location.horizontalAccuracy,
                                   receivedAt: location.timestamp)
            }
        }

        func valid(_ value: Double?) -> Double? {
            guard let value, value.isFinite, value >= 0 else { return nil }
            return value
        }
        func positive(_ value: Double?) -> Double? {
            guard let value = valid(value), value > 0 else { return nil }
            return value
        }
        let hasDistance: Bool? = metadata.getValue(forKey: "HasDistanceData")
        let distanceMetadata: Double? = metadata.getValue(forKey: "Distance")
        var distance = WorkoutRecordReconciliation.distance(
            statistics: workout.statistics(for: HKQuantityType(.distanceWalkingRunning))?
                .sumQuantity()?.doubleValue(for: .meterUnit(with: .kilo)),
            total: workout.totalDistance?.doubleValue(for: .meterUnit(with: .kilo)),
            metadata: distanceMetadata, metadataObserved: hasDistance)
        if distance == nil {
            do { distance = try await queryDistanceSamples(for: workout) }
            catch {
                retrievalFailed = true
                NSLog("Workout distance query failed: \(error.localizedDescription)")
            }
        }

        let hasSpeed: Bool? = metadata.getValue(forKey: "HasSpeedData")
        let speedMeta: Double? = metadata.getValue(forKey: "MaxSpeed")
        let criteriaVersion: Int = metadata.getValue(forKey: "SprintCriteriaVersion") ?? 0
        var velocity: Double?
        if hasSpeed != false, let speedMeta, SprintDetector.isPlausibleSpeed(speedMeta),
           (speedMeta > 0 || hasSpeed == true), criteriaVersion >= 3 {
            velocity = speedMeta * 3.6
        } else if routeSpeed.hasConfirmedSpeed {
            velocity = routeSpeed.maxSpeedMPS * 3.6
        } else if hasSpeed != false, let speedMeta, SprintDetector.isPlausibleSpeed(speedMeta),
                  speedMeta > 0 || hasSpeed == true {
            velocity = speedMeta * 3.6
        } else if let measured = workout.statistics(for: HKQuantityType(.runningSpeed))?
            .maximumQuantity()?.doubleValue(for: HKUnit(from: "m/s")), SprintDetector.isPlausibleSpeed(measured) {
            velocity = measured * 3.6
        }
        let sprintMeta: Int? = metadata.getValue(forKey: "SprintCount")
        var sprintCount: Int?
        if hasSpeed != false, let sprintMeta, sprintMeta >= 0,
           sprintMeta > 0 || hasSpeed == true || routeSpeed.hasConfirmedSpeed {
            sprintCount = sprintMeta
        } else if routeSpeed.hasConfirmedSpeed {
            sprintCount = routeSpeed.sprintCount
        }

        var recordedPower = PeakPower()
        let hasPowerMetadata: Bool = metadata.getValue(forKey: "HasPowerData") ?? false
        if let powerMeta: Double = metadata.getValue(forKey: "Power"), powerMeta > 0 || hasPowerMetadata {
            recordedPower.observe(powerMeta)
        }
        if let powerStat = workout.statistics(for: HKQuantityType(.runningPower)) {
            recordedPower.observe(powerStat.maximumQuantity()?.doubleValue(for: .watt())
                                  ?? powerStat.averageQuantity()?.doubleValue(for: .watt()))
        }

        let hrUnit = HKUnit.count().unitDivided(by: .minute())
        let hrStatistics = workout.statistics(for: HKQuantityType(.heartRate))
        let hasHeartRate: Bool? = metadata.getValue(forKey: "HasHeartRateData")
        var maximum = positive(hrStatistics?.maximumQuantity()?.doubleValue(for: hrUnit))
            ?? (hasHeartRate == false ? nil : positive(metadata.getValue(forKey: "MaxHeartRate")))
        var minimum = positive(hrStatistics?.minimumQuantity()?.doubleValue(for: hrUnit))
            ?? (hasHeartRate == false ? nil : positive(metadata.getValue(forKey: "MinHeartRate")))
        var heartRates = hasHeartRate == false ? [] : WorkoutRecordReconciliation.heartRates(metadata: metadata.getValue(forKey: "HeartRates") ?? "")
        var heartRateDates: [Date] = []
        var heartRateFailure: WorkoutDataAvailability?
        do {
            let samples = try await queryHeartRateSamples(for: workout)
            let measured = samples.compactMap { sample -> (Date, Double)? in
                guard let value = positive(sample.quantity.doubleValue(for: hrUnit)) else { return nil }
                return (sample.startDate, value)
            }
            if !measured.isEmpty {
                heartRates = measured.map { Int($0.1.rounded(.toNearestOrAwayFromZero)) }
                heartRateDates = measured.map { $0.0 }
                if let measuredMaximum = measured.map({ $0.1 }).max() {
                    maximum = max(maximum ?? measuredMaximum, measuredMaximum)
                }
                if let measuredMinimum = measured.map({ $0.1 }).min() {
                    minimum = min(minimum ?? measuredMinimum, measuredMinimum)
                }
            }
        } catch {
            heartRateFailure = availability(for: error)
            retrievalFailed = true
            NSLog("Workout heart-rate query failed: \(error.localizedDescription)")
        }

        // Historical array metadata can survive even when separate extrema are absent.
        if let recordedMinimum = heartRates.min() {
            minimum = min(minimum ?? Double(recordedMinimum), Double(recordedMinimum))
        }
        if let recordedMaximum = heartRates.max() {
            maximum = max(maximum ?? Double(recordedMaximum), Double(recordedMaximum))
        }

        let calorieStatistic = valid(workout.statistics(for: HKQuantityType(.activeEnergyBurned))?
            .sumQuantity()?.doubleValue(for: .kilocalorie()))
        let calorieMetadata: Int? = metadata.getValue(forKey: "Calories")
        let hasCalories: Bool? = metadata.getValue(forKey: "HasCaloriesData")
        let calories = calorieStatistic
            ?? calorieMetadata.flatMap { value in
                guard hasCalories != false, value >= 0, value > 0 || hasCalories == true else { return nil }
                return Double(value)
            }
            ?? valid(workout.totalEnergyBurned?.doubleValue(for: .kilocalorie()))
        let vo2Max = positive(metadata.getValue(forKey: "Vo2Max"))
            ?? positive(workout.statistics(for: HKQuantityType(.vo2Max))?.maximumQuantity()?
                .doubleValue(for: HKUnit(from: "ml/kg*min")))

        var unavailable: Set<WorkoutMetric> = []
        if distance == nil { unavailable.insert(.distance) }
        if sprintCount == nil { unavailable.insert(.sprint) }
        if velocity == nil { unavailable.insert(.maxSpeed) }
        if calories == nil { unavailable.insert(.calories) }
        if minimum == nil { unavailable.insert(.minHeartRate) }
        if maximum == nil { unavailable.insert(.maxHeartRate) }
        if heartRates.isEmpty { unavailable.insert(.heartRate) }
        let center = locations.isEmpty ? [] : [
            locations.reduce(0) { $0 + $1.coordinate.latitude } / Double(locations.count),
            locations.reduce(0) { $0 + $1.coordinate.longitude } / Double(locations.count)
        ]
        var result = WorkoutData(dataID: index + 1, date: dateFormatter.string(from: workout.startDate),
                                 time: "\(Int(workout.duration) / 60) : \(Int(workout.duration) % 60)",
                                 distance: distance ?? 0, sprint: sprintCount ?? 0,
                                 velocity: velocity.map { ($0 * 100).rounded(.toNearestOrAwayFromZero) / 100 } ?? 0,
                                 power: recordedPower.watts ?? 0,
                                 heartRate: ["max": maximum.map { Int($0.rounded(.toNearestOrAwayFromZero)) } ?? 0,
                                             "min": minimum.map { Int($0.rounded(.toNearestOrAwayFromZero)) } ?? 0],
                                 heartRates: heartRates, route: locations.map(\.coordinate), center: center,
                                 calories: calories.map { Int($0.rounded(.toNearestOrAwayFromZero)) } ?? 0, vo2Max: vo2Max ?? 0,
                                 error: false,
                                 heatmapSamples: locations.map {
                                     HeatmapSample(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude,
                                                   timestamp: $0.timestamp, horizontalAccuracy: $0.horizontalAccuracy)
                                 }, heatmapPausedIntervals: pausedIntervals, hasPowerData: recordedPower.watts != nil)
        result.id = workout.uuid
        result.unavailableMetrics = unavailable
        result.routeAvailability = routeResult.availability
        result.heartRateAvailability = heartRates.isEmpty ? (heartRateFailure ?? .unavailable) : .available
        result.heartRateDates = heartRateDates
        result.hasRetrievalFailure = retrievalFailed
        return result
    }

    private static let soccerBeatSourceKeyword = "SoccerBeat"

    private func fetchHKWorkouts() async throws -> [HKWorkout] {
        let soccerPredicate = HKQuery.predicateForWorkouts(with: .soccer)
        let runningPredicate = HKQuery.predicateForWorkouts(with: .running)
        let combinedPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [soccerPredicate, runningPredicate])

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
            throw HealthKitError.failureCastingWorkoutSamples
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
    }

    private func availability(for error: Error) -> WorkoutDataAvailability {
        let error = error as NSError
        return error.domain == HKErrorDomain && error.code == HKError.Code.errorAuthorizationDenied.rawValue
            ? .permissionDenied : .failed
    }

    private func samplePredicate(for workout: HKWorkout, associated: Bool) -> NSPredicate {
        let interval = HKQuery.predicateForSamples(withStart: workout.startDate, end: workout.endDate,
                                                  options: [.strictStartDate, .strictEndDate])
        let owner = associated ? HKQuery.predicateForObjects(from: workout)
            : HKQuery.predicateForObjects(from: workout.sourceRevision.source)
        return NSCompoundPredicate(andPredicateWithSubpredicates: [interval, owner])
    }

    private func queryDistanceSamples(for workout: HKWorkout) async throws -> Double? {
        let type = HKQuantityType(.distanceWalkingRunning)
        // Prefer the workout relationship. Legacy records may have samples saved by the
        // same app without the relationship; never sum unrelated phone/watch sources.
        for associated in [true, false] {
            let predicate = samplePredicate(for: workout, associated: associated)
            let value = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Double?, Error>) in
                let query = HKStatisticsQuery(quantityType: type, quantitySamplePredicate: predicate,
                                              options: .cumulativeSum) { _, statistics, error in
                    if let error { continuation.resume(throwing: error) }
                    else {
                        continuation.resume(returning: statistics?.sumQuantity()?.doubleValue(for: .meterUnit(with: .kilo)))
                    }
                }
                healthStore.execute(query)
            }
            if let value, value.isFinite, value >= 0 { return value }
        }
        return nil
    }

    private func queryHeartRateSamples(for workout: HKWorkout) async throws -> [HKQuantitySample] {
        for associated in [true, false] {
            let predicate = samplePredicate(for: workout, associated: associated)
            let samples = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKQuantitySample], Error>) in
                let query = HKSampleQuery(sampleType: HKQuantityType(.heartRate), predicate: predicate,
                                          limit: HKObjectQueryNoLimit,
                                          sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]) {
                    _, samples, error in
                    if let error { continuation.resume(throwing: error) }
                    else { continuation.resume(returning: samples as? [HKQuantitySample] ?? []) }
                }
                healthStore.execute(query)
            }
            if !samples.isEmpty { return samples }
        }
        return []
    }

    private struct RouteReadResult {
        var locations: [CLLocation] = []
        var metadata: [[String: Any]] = []
        var availability: WorkoutDataAvailability = .unavailable
        var hasFailure = false
    }

    private struct RouteLocationIdentity: Hashable {
        let timestamp: Date
        let latitude: Double
        let longitude: Double
    }

    private func convertToRouteAndMetadata(from workout: HKWorkout) async -> RouteReadResult {
        var result = RouteReadResult()
        do {
            let routes = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKWorkoutRoute], Error>) in
                let query = HKSampleQuery(sampleType: HKSeriesType.workoutRoute(),
                                          predicate: HKQuery.predicateForObjects(from: workout),
                                          limit: HKObjectQueryNoLimit,
                                          sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: true)]) {
                    _, samples, error in
                    if let error { continuation.resume(throwing: error) }
                    else { continuation.resume(returning: samples as? [HKWorkoutRoute] ?? []) }
                }
                healthStore.execute(query)
            }
            for route in routes {
                result.metadata.append(route.metadata ?? [:])
                let read = await readLocations(from: route)
                result.locations.append(contentsOf: read.locations)
                if let error = read.error {
                    result.hasFailure = true
                    result.availability = availability(for: error)
                    NSLog("Workout route query failed: \(error.localizedDescription)")
                }
            }
            var seen = Set<RouteLocationIdentity>()
            result.locations = result.locations.sorted { $0.timestamp < $1.timestamp }.filter { location in
                guard CLLocationCoordinate2DIsValid(location.coordinate),
                      location.timestamp >= workout.startDate, location.timestamp <= workout.endDate,
                      location.horizontalAccuracy.isFinite, location.horizontalAccuracy >= 0 else { return false }
                return seen.insert(RouteLocationIdentity(timestamp: location.timestamp,
                                                         latitude: location.coordinate.latitude,
                                                         longitude: location.coordinate.longitude)).inserted
            }
            if !result.locations.isEmpty { result.availability = .available }
        } catch {
            result.availability = availability(for: error)
            result.hasFailure = true
            NSLog("Workout route discovery failed: \(error.localizedDescription)")
        }
        return result
    }

    private func readLocations(from route: HKWorkoutRoute) async -> (locations: [CLLocation], error: Error?) {
        await withCheckedContinuation { continuation in
            var locations: [CLLocation] = []
            var finished = false
            let lock = NSLock()
            let query = HKWorkoutRouteQuery(route: route) { _, batch, done, error in
                lock.lock()
                guard !finished else { lock.unlock(); return }
                locations.append(contentsOf: batch ?? [])
                if error != nil || done {
                    finished = true
                    let result = (locations: locations, error: error)
                    lock.unlock()
                    continuation.resume(returning: result)
                } else { lock.unlock() }
            }
            healthStore.execute(query)
        }
    }

}

// MARK: - Chart Methods

extension WorkoutManager {

    @MainActor
    private func settingForChartView(_ workouts: [WorkoutData]) {
        recent4Games = readRecentMatches(from: workouts, count: 4)
            .sorted(by: { $0.formattedDate < $1.formattedDate })
            .appendingBlanks(upTo: 4, with: .blankExample)
        recentGames = workouts.sorted(by: { $0.formattedDate < $1.formattedDate })
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
    @MainActor
    func startObservingWorkoutChanges() {
        guard workoutObserverQueries.isEmpty else { return }
        // HealthKit sync may deliver the workout, route and quantity samples separately.
        // The deleted UUIDs are authoritative; an ordinary empty query is not.
        let onWorkouts: (HKAnchoredObjectQuery, [HKSample]?, [HKDeletedObject]?, HKQueryAnchor?, Error?) -> Void = {
            [weak self] _, _, deleted, _, error in
            guard let self else { return }
            if let error {
                NSLog("Workout observation failed: \(error.localizedDescription)")
                return
            }
            Task { @MainActor in
                for object in deleted ?? [] {
                    self.deletedWorkoutIDs.insert(object.uuid)
                    self.workoutCache.removeValue(forKey: object.uuid)
                    self.hkWorkouts.removeAll { $0.uuid == object.uuid }
                }
                await self.fetchWorkoutData()
            }
        }
        let workouts = HKAnchoredObjectQuery(type: HKObjectType.workoutType(), predicate: nil,
                                            anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: onWorkouts)
        workouts.updateHandler = onWorkouts
        workoutObserverQueries.append(workouts)
        healthStore.execute(workouts)

        let types: [HKSampleType] = [HKSeriesType.workoutRoute(), HKQuantityType(.heartRate),
                                     HKQuantityType(.distanceWalkingRunning), HKQuantityType(.activeEnergyBurned)]
        for type in types {
            let query = HKObserverQuery(sampleType: type, predicate: nil) { [weak self] _, completion, error in
                guard let self, error == nil else {
                    if let error { NSLog("Workout sample observation failed: \(error.localizedDescription)") }
                    completion()
                    return
                }
                Task {
                    await self.fetchWorkoutData()
                    completion()
                }
            }
            workoutObserverQueries.append(query)
            healthStore.execute(query)
        }
    }

    // 폰에서 앱 실행 시 워치의 원격 세션과 연동함
    func retrieveRemoteSession() {
        Task { @MainActor in self.startObservingWorkoutChanges() }
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
