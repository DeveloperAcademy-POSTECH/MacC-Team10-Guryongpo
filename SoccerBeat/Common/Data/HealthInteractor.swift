//
//  HealthInteractor.swift
//  SoccerBeat
//
//  Created by daaan on 11/1/23.
//

import Combine
import CoreLocation
import HealthKit
import SwiftUI

enum HealthKitError: Error {
    case failureConvertingRouteAndMeta
}

final class HealthInteractor: NSObject, ObservableObject {
    // Object to request permission to read HealthKit data.
    var healthStore = HKHealthStore()
    let locationManager = CLLocationManager()
    let typesToRead = Set([
                           HKObjectType.quantityType(forIdentifier: .heartRate)!,
                           HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                           HKObjectType.quantityType(forIdentifier: .walkingSpeed)!,
                           HKObjectType.quantityType(forIdentifier: .runningSpeed)!,
                           HKQuantityType.quantityType(forIdentifier: .runningPower)!,
                           HKQuantityType.quantityType(forIdentifier: .activeEnergyBurned)!,
                           HKQuantityType.quantityType(forIdentifier: .vo2Max)!,
                           HKSeriesType.workoutType(),
                           HKSeriesType.workoutRoute(),
                           HKObjectType.activitySummaryType()
                          ])

    let typesToShare: Set = [HKQuantityType.workoutType(),
                             HKSeriesType.workoutRoute(),
                             HKQuantityType.quantityType(forIdentifier: .runningSpeed)!,
                             HKQuantityType.quantityType(forIdentifier: .distanceWalkingRunning)!
    ]

    // Entire user workouts in HealthKit data.
    private var hkWorkouts = [HKWorkout]()

    override init() {
        super.init()
        locationManager.delegate = self
    }

    // Send when permission is granted by the user.
    var authSuccess = PassthroughSubject<(), Never>()
    private(set) var onWorkoutRemoved = PassthroughSubject<(IndexSet), Never>()
    // Send when data fetch is successful.
    var fetchWorkoutsSuccess = PassthroughSubject<([WorkoutData]), Never>()

    static let shared = HealthInteractor()

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter
    }()

    @Published var recentGames = [WorkoutData]()
    @Published var recent4Games = [WorkoutData]()

    private(set) var monthly = [String: [WorkoutData]]()

    func hasLocationAuthorization() -> Bool {
        [
            CLAuthorizationStatus.authorizedAlways,
            .authorizedWhenInUse
        ].contains(locationManager.authorizationStatus)
    }

    func haveHealthAuthorization() -> Bool {
        for type in typesToShare
        where healthStore.authorizationStatus(for: type) == .sharingDenied {
            NSLog(
                type.debugDescription,
                healthStore.authorizationStatus(for: type).rawValue
            )
            return false
        }
        return true
    }

    @MainActor
    func requestAuthorization() {
        NSLog("requestAuthorization: request user authorization..")

        let locationAccessDenied = [
            CLAuthorizationStatus.notDetermined,
            .denied,
            .restricted
        ]
            .contains(locationManager.authorizationStatus)

        if locationAccessDenied {
            self.locationManager.requestAlwaysAuthorization()
        }
        // 해당 기기가 헬스킷을 사용할 수 있는지 확인 함
        guard HKHealthStore.isHealthDataAvailable() else {
            NSLog("requestAuthorization: health data not available")
            return
        }

        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            guard let error else {
                NSLog(error.debugDescription)
                return
            }
            if success && self.haveHealthAuthorization() {
                DispatchQueue.main.async {
                    self.authSuccess.send()
                }
            } else {
                NSLog("Error in getting healthstore reading authorization. ")
            }
        }
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

    @Published var isLoading = false

    func fetchWorkoutData() async {
        await MainActor.run {
            isLoading = true
        }

        // Fetch from HealthStore
        self.hkWorkouts = await fetchHKWorkouts()

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

        guard let (locations, metadata) = try? await convertToRouteAndMetadata(from: workout) else {
            NSLog("Failure Converting Workout to Route and Metadata")
            throw HealthKitError.failureConvertingRouteAndMeta
        }

        for location in locations {
            routes.append(CLLocationCoordinate2D(latitude: location.coordinate.latitude,
                                                 longitude: location.coordinate.longitude))
            latSum += location.coordinate.latitude
            lonSum += location.coordinate.longitude
        }
        let displayedTime = String(Int(workout.duration)/60) + " : " + String(Int(workout.duration) % 60)
        let dotCount = routes.isEmpty ? 1 : routes.count

        // Metadata를 WorkoutData로 변환
        // 기본으로 데이터 오류 없음 가정
        var dataError = false

        var distance = 0.0
        var sprintCount = 0
        var velocity = 0.0
        var maxHeartRate = 0
        var minHeartRate = 0
        var heartRates:[Int] = []
        var power = 0.0
        var calories = 0
        var vo2Max = 0.0
        
        print(metadata)

        if let distanceMeta: Double = metadata.getValue(forKey: "Distance") {
            distance = distanceMeta
        } else { dataError = true }

        if let sprintCountMeta: Int = metadata.getValue(forKey: "SprintCount") {
            sprintCount = sprintCountMeta
        } else { dataError = true }

        if let velocityMeta: Double = metadata.getValue(forKey: "MaxSpeed") {
            velocity = Double(((velocityMeta) * 3.6).rounded(at: 2)) ?? 0
        } else { dataError = true }

        if let powerMeta: Double = metadata.getValue(forKey: "Power") ??
            metadata.getValue(forKey: "Acceleration") {
            power = powerMeta
        } else { dataError = true }

        if let maxHeartRateMeta: Int = metadata.getValue(forKey: "MaxHeartRate") {
            maxHeartRate = maxHeartRateMeta
        } else { dataError = true }

        if let minHeartRateMeta: Int = metadata.getValue(forKey: "MinHeartRate") {
            minHeartRate = minHeartRateMeta
        } else { dataError = true }
        
        if let heartRatesMeta: String = metadata.getValue(forKey: "HeartRates") {
            heartRates = heartRatesMeta.split(separator: ",").map { Int($0) ?? 0 }
        } // if no heartRates, but this is not an error
        
        if let caloriesMeta: Int = metadata.getValue(forKey: "Calories") {
            calories = caloriesMeta
        }
        
        if let vo2MaxMeta: Double = metadata.getValue(forKey: "Vo2Max") {
            vo2Max = vo2MaxMeta
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
                           error: dataError)
    }

    private func fetchHKWorkouts() async -> [HKWorkout] {
        let soccerPredicate = HKQuery.predicateForObjects(from: .default())
        let data = try? await withCheckedThrowingContinuation { (
            continuation: CheckedContinuation<[HKSample], Error>
        ) in
            let query = HKSampleQuery(
                sampleType: .workoutType(),
                predicate: soccerPredicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: [NSSortDescriptor(keyPath: \HKSample.startDate, ascending: false)],
                resultsHandler: { _, samples, error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else if let samples = samples {
                        continuation.resume(returning: samples)
                    }
                }
            )
            healthStore.execute(query)
        }
        guard let workouts = data as? [HKWorkout] else { return [] }
        return workouts
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
                    } else if let samples = samples {
                        continuation.resume(returning: samples)
                    }
                }
            )
            healthStore.execute(query)
        }

        guard let route = (samples as? [HKWorkoutRoute])?.first, let metadata = route.metadata else {
            return ([], [:])
        }

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

        return (locations, metadata)
    }
}

// MARK: - Chart Methods

extension HealthInteractor {

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

extension HealthInteractor: CLLocationManagerDelegate {
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
