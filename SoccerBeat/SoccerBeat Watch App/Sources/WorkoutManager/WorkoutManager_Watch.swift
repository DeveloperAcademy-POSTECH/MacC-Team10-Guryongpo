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

/// Retains the exact session/builders across asynchronous save and UI transitions.
final class WatchWorkoutRecording {
    let session: HKWorkoutSession
    let builder: HKLiveWorkoutBuilder
    var routeBuilder: HKWorkoutRouteBuilder
    let store = WorkoutRecoveryStore()
    var journal: WorkoutRecoveryRecord
    var beginTask: Task<Void, Error>?
    var insertionTask: Task<Void, Never>?
    var finalizationTask: Task<Void, Never>?
    var locations: [CLLocation] = []
    var insertionFailed = false
    var collectionBegan = false
    var recoveryWriteFailed = false
    var routeBackupFailed = false
    var collectionEnded = false
    var acceptingLocations = true
    var metadata: [String: Any] = [:]
    var savedWorkout: HKWorkout?

    init(session: HKWorkoutSession, builder: HKLiveWorkoutBuilder, routeBuilder: HKWorkoutRouteBuilder, start: Date) {
        self.session = session
        self.builder = builder
        self.routeBuilder = routeBuilder
        journal = WorkoutRecoveryRecord(sessionID: UUID(), startDate: start)
    }
}

private enum WorkoutPersistenceError: Error {
    case missingRecording, unconfirmedWorkout, unconfirmedRoute
}

// MARK: - 세션 pause, resume, end 시에 작동하는 델리게이트
extension WorkoutManager: HKWorkoutSessionDelegate {
    
    // MARK: - 데이터 수집 및 경기 시작
    @MainActor
    func startWorkout() {
        // 카운트다운 중 위치가 오래되거나 정밀 권한이 바뀐 경우 실제 세션 시작을 차단한다.
        guard hasAllAuthorization else {
            showingPrecount = false
            return
        }

        guard watchRecording == nil else { return }
        do {
            try setupWorkoutConfig()
            startWorkoutSession()
        } catch {
            NSLog("Workout setup failed: %@", error.localizedDescription)
            workoutSaveState = .failed
            showingPrecount = false
            showingSummaryView = true
        }
    }
    
    // 워치 경기 기록 설정
    @MainActor
    private func setupWorkoutConfig() throws {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .soccer
        configuration.locationType = .outdoor
        let session = try HKWorkoutSession(healthStore: healthStore, configuration: configuration)
        let builder = session.associatedWorkoutBuilder()
        let routeBuilder = HKWorkoutRouteBuilder(healthStore: healthStore, device: .local())
        let recording = WatchWorkoutRecording(session: session, builder: builder, routeBuilder: routeBuilder, start: Date())
        try recording.store.save(recording.journal)
        self.session = session
        self.builder = builder
        self.routeBuilder = routeBuilder
        watchRecording = recording
        workoutSaveState = .idle
        session.delegate = self
        builder.delegate = self
        let source = HKLiveWorkoutDataSource(healthStore: healthStore, workoutConfiguration: configuration)
        source.enableCollection(for: HKQuantityType(.runningPower), predicate: nil)
        builder.dataSource = source
    }

    @MainActor
    private func startWorkoutSession() {
        guard let recording = watchRecording else { return }
        recording.session.startActivity(with: recording.journal.startDate)
        recording.beginTask = Task { @MainActor in
            do {
                try await recording.builder.beginCollection(at: recording.journal.startDate)
                recording.collectionBegan = true
            } catch {
                NSLog("Workout collection could not start: %@", error.localizedDescription)
                workoutSaveState = .failed
                showingSummaryView = true
                let failedAt = Date()
                recording.journal.endDate = failedAt
                recording.session.stopActivity(with: failedAt)
                throw error
            }
            do {
                try await recording.builder.addMetadata(["SoccerBeatSessionID": recording.journal.sessionID.uuidString])
            } catch {
                NSLog("Workout initial metadata failed: %@", error.localizedDescription)
            }
        }
        locationManager.startUpdatingLocation()
        matrics.computeProperMaxHeartRate(with: healthStore)
        startMotionDetaction()
        Task {
            do { try await recording.session.startMirroringToCompanionDevice() }
            catch { NSLog("Workout mirroring failed: %@", error.localizedDescription) }
        }
    }

    private func startMotionDetaction() {
        isAutomotiveMotion = false
        motionManager.startActivityUpdates(to: .main) { [weak self] activity in
            guard let activity = activity else { return }

            self?.isAutomotiveMotion = activity.automotive && activity.confidence != .low
            if self?.isAutomotiveMotion == true { self?.matrics.pauseSpeed() }

            // state change
            if activity.unknown || activity.running || activity.walking {
                self?.isStationaryDetacted = false
            } else if activity.stationary {
                self?.isStationaryDetacted = true
            }
        }
    }

    // A workout and its route are separate saves. Keep the journal until both are verified.
    @MainActor
    func endWorkoutSession(_ date: Date) async throws {
        guard let recording = watchRecording else { throw WorkoutPersistenceError.missingRecording }
        recording.journal.endDate = recording.journal.endDate ?? date
        if recording.metadata.isEmpty { try captureMetadata(for: recording) }
        persistJournal(for: recording)
        try await recording.beginTask?.value
        if !recording.collectionEnded {
            try await recording.builder.endCollection(at: recording.journal.endDate!)
            recording.collectionEnded = true
        }
        recording.acceptingLocations = false
        await recording.insertionTask?.value
        if !recording.journal.finishAttempted { try captureMetadata(for: recording) }
        if !recording.journal.finishAttempted {
            do {
                try await recording.builder.addMetadata(recording.metadata)
                recording.journal.metadataStored = true
            } catch {
                NSLog("Workout metadata save failed; retaining recovery copy: %@", error.localizedDescription)
            }
            // Persist BEFORE the call: an interrupted or nil result must not create a duplicate on retry.
            let shouldFinish: Bool
            do { shouldFinish = try recording.store.claimWorkoutFinish(&recording.journal) }
            catch {
                // Prefer preserving the real HealthKit workout if the auxiliary recovery store is full.
                // Keep the in-memory once-only marker; recovery never creates a replacement workout.
                recording.journal.finishAttempted = true
                recording.recoveryWriteFailed = true
                NSLog("Recovery intent could not be written; attempting HealthKit save once: %@", error.localizedDescription)
                shouldFinish = true
            }
            if shouldFinish {
                do { recording.savedWorkout = try await recording.builder.finishWorkout() }
                catch { NSLog("Workout finish could not be confirmed: %@", error.localizedDescription) }
            }
        }
        if recording.savedWorkout == nil {
            recording.savedWorkout = try await recoveryWorkout(for: recording.journal)
        }
        guard let saved = recording.savedWorkout else { throw WorkoutPersistenceError.unconfirmedWorkout }
        workout = saved
        recording.journal.workoutID = saved.uuid
        persistJournal(for: recording)
        await recording.insertionTask?.value
        do {
            if !recording.locations.isEmpty {
                if !recording.journal.routeFinishAttempted {
                    if recording.insertionFailed {
                        // insertRouteData failure invalidates that route builder. Rebuild from actual collected fixes.
                        recording.routeBuilder = HKWorkoutRouteBuilder(healthStore: healthStore, device: .local())
                        try await recording.routeBuilder.insertRouteData(recording.locations)
                    }
                    if try recording.store.claimRouteFinish(&recording.journal) {
                        route = try await recording.routeBuilder.finishRoute(with: saved, metadata: recording.metadata)
                    }
                }
                if route == nil { route = try await recoveryRoute(for: saved) }
                guard let route, route.count >= recording.locations.count else { throw WorkoutPersistenceError.unconfirmedRoute }
            } else if !recording.journal.metadataStored {
                throw WorkoutPersistenceError.unconfirmedRoute
            }
            try? recording.store.complete(recording.journal.sessionID)
            workoutSaveState = .saved
        } catch {
            // Never retry an invalidated finishRoute builder, and never discard the actual GPS backup.
            NSLog("Workout saved, route/details pending: %@", error.localizedDescription)
            workoutSaveState = .partial
        }
    }

    @MainActor
    private func captureMetadata(for recording: WatchWorkoutRecording) throws {
        for type in [HKQuantityType(.heartRate), HKQuantityType(.distanceWalkingRunning),
                     HKQuantityType(.activeEnergyBurned), HKQuantityType(.runningPower), HKQuantityType(.vo2Max)] {
            if let statistics = recording.builder.statistics(for: type) { matrics.updateForStatistics(statistics) }
        }
        recording.metadata = matrics.getMetadata()
        recording.metadata["SoccerBeatSessionID"] = recording.journal.sessionID.uuidString
        recording.metadata["SoccerBeatRoutePointCount"] = recording.locations.count
        recording.journal.routePointCount = recording.locations.count
        recording.journal.metadata = try PropertyListSerialization.data(fromPropertyList: recording.metadata,
                                                                       format: .binary, options: 0)
        persistJournal(for: recording)
        if recording.routeBackupFailed {
            do {
                try recording.store.replaceSamples(recording.locations.map(\.recoverySample),
                                                    for: recording.journal.sessionID)
                recording.routeBackupFailed = false
            } catch {
                NSLog("GPS recovery copy still unavailable: %@", error.localizedDescription)
            }
        }
    }

    @MainActor
    private func persistJournal(for recording: WatchWorkoutRecording) {
        do {
            try recording.store.save(recording.journal)
            recording.recoveryWriteFailed = false
        } catch {
            recording.recoveryWriteFailed = true
            NSLog("Workout recovery journal write failed; keeping builders in memory: %@", error.localizedDescription)
        }
    }

    @MainActor
    var canDismissWorkoutSummary: Bool {
        switch workoutSaveState {
        case .saved: return true
        case .partial: return watchRecording.map { !$0.recoveryWriteFailed && !$0.routeBackupFailed } ?? false
        case .failed:
            return watchRecording.map {
                !$0.collectionBegan && $0.locations.isEmpty && !matrics.hasHeartRateData &&
                !matrics.hasDistanceData && !matrics.hasCaloriesData && !matrics.hasSpeedData && !matrics.hasPowerData
            } ?? true
        default: return false
        }
    }

    @MainActor
    func retryWorkoutSave() {
        guard let recording = watchRecording, recording.finalizationTask == nil else { return }
        beginFinalization(recording.journal.endDate ?? Date())
    }

    @MainActor
    private func beginFinalization(_ date: Date) {
        guard let recording = watchRecording, recording.finalizationTask == nil else { return }
        workoutSaveState = .saving
        recording.finalizationTask = Task { @MainActor in
            defer {
                recording.session.end()
                recording.finalizationTask = nil
            }
            do { try await endWorkoutSession(date) }
            catch {
                NSLog("Workout save pending: %@", error.localizedDescription)
                workoutSaveState = .failed
            }
        }
    }

    @MainActor
    func resetWorkout() {
        guard canDismissWorkoutSummary else { return }
        builder = nil
        routeBuilder = nil
        workout = nil
        route = nil
        session = nil
        watchRecording = nil
        matrics.reset()
        isAutomotiveMotion = false
        workoutSaveState = .idle
        checkLocationAuthorization()
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
    
    @MainActor
    func endWorkout() {
        guard let recording = watchRecording, workoutSaveState != .saving else { return }
        workoutSaveState = .saving
        showingSummaryView = true
        let endDate = Date()
        recording.journal.endDate = endDate
        running = false
        matrics.pauseSpeed()
        motionManager.stopActivityUpdates()
        locationManager.stopUpdatingLocation()
        recording.session.stopActivity(with: endDate)
    }
}

// MARK: - WorkoutData 수집시 동작하는 델리게이트
extension WorkoutManager: HKLiveWorkoutBuilderDelegate {
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState,
                        from fromState: HKWorkoutSessionState, date: Date) {
        Task { @MainActor in
            guard self.session === workoutSession else { return }
            // A queued running callback must not reactivate collection after the user requested stop.
            if toState == .running && watchRecording?.journal.endDate != nil { return }
            running = toState == .running
            if toState == .running {
                startMotionDetaction()
            } else {
                motionManager.stopActivityUpdates()
                matrics.pauseSpeed()
            }
            if toState == .stopped || toState == .ended {
                locationManager.stopUpdatingLocation()
                if let recording = watchRecording, recording.finalizationTask == nil,
                   (toState == .stopped || workoutSaveState == .idle) {
                    showingSummaryView = true
                    beginFinalization(date)
                }
            }
        }
    }

    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        Task { @MainActor in
            guard self.session === workoutSession else { return }
            NSLog("Workout session failed: %@", error.localizedDescription)
            running = false
            locationManager.stopUpdatingLocation()
            motionManager.stopActivityUpdates()
            matrics.pauseSpeed()
            showingSummaryView = true
            beginFinalization(Date())
        }
    }

    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) { }

    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder,
                        didCollectDataOf collectedTypes: Set<HKSampleType>) {
        Task { @MainActor in
            guard self.builder === workoutBuilder else { return }
            for type in collectedTypes {
                guard let quantityType = type as? HKQuantityType,
                      let statistics = workoutBuilder.statistics(for: quantityType) else { continue }
                matrics.updateForStatistics(statistics)
            }
        }
    }
}

// MARK: - 위치 정보 수집시 동작하는 델리게이트
extension WorkoutManager {
    // MARK: - 위치 정보가 수집되면 불리는 메서드
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            guard let recording = watchRecording, recording.acceptingLocations else {
                objectWillChange.send()
                return
            }
            let receivedAt = Date()
            let sorted = locations.sorted { $0.timestamp < $1.timestamp }
            for location in sorted where running {
                matrics.updateSpeed(timestamp: location.timestamp, speed: location.speed,
                                    speedAccuracy: location.speedAccuracy, horizontalAccuracy: location.horizontalAccuracy,
                                    isAutomotive: isAutomotiveMotion, receivedAt: receivedAt)
            }
            let valid = sorted.filter {
                CLLocationCoordinate2DIsValid($0.coordinate) && $0.horizontalAccuracy.isFinite &&
                (0...50).contains($0.horizontalAccuracy) && $0.timestamp >= recording.journal.startDate &&
                $0.timestamp <= receivedAt && $0.timestamp <= (recording.journal.endDate ?? receivedAt)
            }
            guard !valid.isEmpty else { return }
            recording.locations.append(contentsOf: valid)
            do {
                try recording.store.append(valid.map { $0.recoverySample }, to: recording.journal.sessionID)
            } catch {
                recording.routeBackupFailed = true
                NSLog("GPS recovery copy failed; still attempting HealthKit insertion: %@", error.localizedDescription)
            }
            let previous = recording.insertionTask
            recording.insertionTask = Task { @MainActor in
                await previous?.value
                guard !recording.insertionFailed else { return }
                do { try await recording.routeBuilder.insertRouteData(valid) }
                catch {
                    recording.insertionFailed = true
                    NSLog("Route insertion failed; raw fixes retained for rebuilding: %@", error.localizedDescription)
                }
            }
        }
    }

    // MARK: - 위치 공유 권한 정보가 업데이트 되면 불리는 메서드
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            checkLocationAuthorization()
            objectWillChange.send()
        }
    }

    @MainActor
    func checkLocationAuthorization() {
        recoverPendingWorkoutRoutes()
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
            if locationManager.accuracyAuthorization == .reducedAccuracy {
                // Sprint 속도 측정 중에만 정밀 위치를 요청하고, 거절 시 권한 안내 화면을 유지한다.
                // swiftlint:disable:next line_length
                // https://developer.apple.com/documentation/corelocation/cllocationmanager/requesttemporaryfullaccuracyauthorization(withpurposekey:)
                locationManager.requestTemporaryFullAccuracyAuthorization(
                    withPurposeKey: "SprintMeasurement"
                ) { error in
                    if let error {
                        NSLog(error.localizedDescription)
                    }
                }
            }
            if watchRecording == nil || running { locationManager.startUpdatingLocation() }
        @unknown default:
            NSLog(locationManager.authorizationStatus.rawValue.description)
        }
    }
}

private extension CLLocation {
    var recoverySample: WorkoutRouteSample {
        WorkoutRouteSample(latitude: coordinate.latitude, longitude: coordinate.longitude, altitude: altitude,
                           horizontalAccuracy: horizontalAccuracy, verticalAccuracy: verticalAccuracy,
                           course: course, speed: speed, speedAccuracy: speedAccuracy,
                           courseAccuracy: courseAccuracy, timestamp: timestamp)
    }
}

private extension WorkoutRouteSample {
    var location: CLLocation {
        CLLocation(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude), altitude: altitude,
                   horizontalAccuracy: horizontalAccuracy, verticalAccuracy: verticalAccuracy,
                   course: course, courseAccuracy: courseAccuracy, speed: speed,
                   speedAccuracy: speedAccuracy, timestamp: timestamp)
    }
}

extension WorkoutManager {
    /// Only new sessions with our durable journal are candidates; never rewrite historical workouts.
    @MainActor
    func recoverPendingWorkoutRoutes() {
        guard workoutRecoveryTask == nil else { return }
        let store = WorkoutRecoveryStore()
        workoutRecoveryTask = Task { @MainActor in
            defer { workoutRecoveryTask = nil }
            do {
                for var record in try store.records() {
                    do {
                        guard record.sessionID != watchRecording?.journal.sessionID, record.finishAttempted else { continue }
                        guard let saved = try await recoveryWorkout(for: record) else {
                            NSLog("Workout recovery pending: saved workout not yet accessible; keeping local journal")
                            continue
                        }
                        record.workoutID = saved.uuid
                        try store.save(record)
                        let existing = try await recoveryRoute(for: saved)
                        let samples = try store.samples(for: record.sessionID)
                        let expected = max(record.routePointCount, saved.metadata?["SoccerBeatRoutePointCount"] as? Int ?? 0)
                        if let existing {
                            if existing.count >= max(expected, samples.count) { try store.complete(record.sessionID) }
                            continue
                        }
                        if samples.isEmpty {
                            if record.metadataStored { try store.complete(record.sessionID) }
                            continue
                        }
                        // A finish call consumes its builder even on error, and lock can make its outcome ambiguous.
                        // Query on later activations, rather than create another route after an unconfirmed finish.
                        guard !record.routeFinishAttempted, samples.count >= expected else { continue }
                        let routeBuilder = HKWorkoutRouteBuilder(healthStore: healthStore, device: .local())
                        try await routeBuilder.insertRouteData(samples.map(\.location))
                        let metadata = (try PropertyListSerialization.propertyList(from: record.metadata, options: [],
                                                                                   format: nil)) as? [String: Any] ?? [:]
                        guard try store.claimRouteFinish(&record) else { continue }
                        let route = try await routeBuilder.finishRoute(with: saved, metadata: metadata)
                        if route.count >= samples.count { try store.complete(record.sessionID) }
                    } catch {
                        NSLog("Workout recovery deferred for one session: %@", error.localizedDescription)
                    }
                }
            } catch {
                NSLog("Workout recovery deferred; local journal retained: %@", error.localizedDescription)
            }
        }
    }

    @MainActor
    private func recoveryWorkout(for record: WorkoutRecoveryRecord) async throws -> HKWorkout? {
        let predicate = record.workoutID.map { HKQuery.predicateForObject(with: $0) }
            ?? HKQuery.predicateForObjects(withMetadataKey: "SoccerBeatSessionID", allowedValues: [record.sessionID.uuidString])
        return try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: HKObjectType.workoutType(), predicate: predicate, limit: 1,
                                      sortDescriptors: nil) { _, samples, error in
                if let error { continuation.resume(throwing: error) }
                else { continuation.resume(returning: samples?.first as? HKWorkout) }
            }
            healthStore.execute(query)
        }
    }

    @MainActor
    private func recoveryRoute(for workout: HKWorkout) async throws -> HKWorkoutRoute? {
        try await withCheckedThrowingContinuation { continuation in
            let query = HKSampleQuery(sampleType: HKSeriesType.workoutRoute(),
                                      predicate: HKQuery.predicateForObjects(from: workout), limit: HKObjectQueryNoLimit,
                                      sortDescriptors: nil) { _, samples, error in
                if let error { continuation.resume(throwing: error) }
                else { continuation.resume(returning: (samples as? [HKWorkoutRoute])?.max(by: { $0.count < $1.count })) }
            }
            healthStore.execute(query)
        }
    }
}
