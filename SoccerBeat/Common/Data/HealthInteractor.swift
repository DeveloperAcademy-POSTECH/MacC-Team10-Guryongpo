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

final class HealthInteractor: ObservableObject {
    // Object to request permission to read HealthKit data.
    var healthStore = HKHealthStore()
    let locationManager = CLLocationManager()
    let typesToRead = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!,
                          HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                          HKObjectType.quantityType(forIdentifier: .runningSpeed)!,
                          HKObjectType.quantityType(forIdentifier: .walkingSpeed)!,
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
    
    // Send when permission is granted by the user.
    var authSuccess = PassthroughSubject<(), Never>()
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
    
    func haveNoLocationAuthorization() -> Bool {
        return locationManager.authorizationStatus == .denied
    }
    
    func haveNoHealthAuthorization() -> Bool {
        for type in typesToShare {
            if healthStore.authorizationStatus(for: type) == .sharingDenied {
                print(type, healthStore.authorizationStatus(for: type).rawValue)
                return true
            }}
        return false
    }
    
    @MainActor
    func requestAuthorization() {
        print("requestAuthorization: request user authorization..")
        
        // 휴대폰에서 위치 권한 얻기
        if locationManager.authorizationStatus == .denied ||
            locationManager.authorizationStatus == .notDetermined ||
            locationManager.authorizationStatus == .restricted {
            self.locationManager.requestAlwaysAuthorization()
        }
        
        // 해당 기기가 헬스킷을 사용할 수 있는지 확인 함
        guard HKHealthStore.isHealthDataAvailable() else {
            print("requestAuthorization: health data not available")
            return
        }
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { success, error in
            if success && !self.haveNoHealthAuthorization() {
                DispatchQueue.main.async {
                    self.authSuccess.send()
                }
            } else {
                NSLog("Error in getting healthstore reading authorization. ")
            }
        }
    }
    
    func delete(at offset: IndexSet) async throws {
        hkWorkouts.remove(atOffsets: offset)
        for index in offset {
            try await healthStore.delete(hkWorkouts[index])
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
            let workoutDatum = await convert(from: workout, at: index)
            workoutData.append(workoutDatum)
        }
        
        await settingForChartView(workoutData)
        monthly = divideWorkoutsByMonthly(workoutData)

        await MainActor.run { [workoutData] in
            isLoading = false
            self.fetchWorkoutsSuccess.send(workoutData)
        }
    }
    
    private func convert(from workout: HKWorkout, at index: Int) async -> WorkoutData {
        var latSum = 0.0
        var lonSum = 0.0
        var routes: [CLLocationCoordinate2D] = []
        let (locations, metadata) = await convertToRouteAndMetadata(from: workout)
        for location in locations {
            routes.append(CLLocationCoordinate2D(latitude: location.coordinate.latitude,
                                                 longitude: location.coordinate.longitude))
            latSum += location.coordinate.latitude
            lonSum += location.coordinate.longitude
        }
        
        // Metadata를 WorkoutData로 변환
        guard let distance: Double = metadata.getValue(forKey: "Distance"),
              let sprintCount: Int = metadata.getValue(forKey: "SprintCount"),
              let velocityMPS: Double = metadata.getValue(forKey: "MaxSpeed"),
              // Acceleration -> Power 변경. 이전 데이터 터짐 방지 위해 Power -> Acceleration 으로 변환 표시. 
              let power: Double = metadata.getValue(forKey: "Power") ?? metadata.getValue(forKey: "Acceleration"),
              let maxHeartRate: Int = metadata.getValue(forKey: "MaxHeartRate"),
              let minHeartRate: Int = metadata.getValue(forKey: "MinHeartRate")
        else { return  WorkoutData.blankExample }
        
        let velocityKMPH = Double((velocityMPS * 3.6).rounded(at: 2)) ?? 0
        let displayedTime = String(Int(workout.duration)/60) + " : " + String(Int(workout.duration) % 60)
        let dotCount = routes.count
        return WorkoutData(dataID: index+1,
                           date: dateFormatter.string(from: workout.startDate),
                           time: displayedTime,
                           distance: distance,
                           sprint: sprintCount,
                           velocity: velocityKMPH, // km/h
                           power: power,
                           heartRate: ["max": maxHeartRate,
                                       "min": minHeartRate],
                           route: routes,
                           center: [latSum / Double(dotCount),
                                    lonSum / Double(dotCount)])
    }

    private func fetchHKWorkouts() async -> [HKWorkout] {
        let soccer = HKQuery.predicateForObjects(from: .default())
        let data = try? await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKSample], Error>) in
            healthStore.execute(HKSampleQuery(sampleType: .workoutType(), predicate: soccer, limit: HKObjectQueryNoLimit,sortDescriptors: [.init(keyPath: \HKSample.startDate, ascending: false)], resultsHandler: { query, samples, error in
                if let hasError = error {
                    continuation.resume(throwing: hasError)
                    return
                }
                continuation.resume(returning: samples!)
            }))
        }
        guard let workouts = data as? [HKWorkout] else { return [] }
        return workouts
    }

    // HKWorkout + Metadata
    // TODO: - throws로 바꿔야 할 것
    // TODO: - withCheckedThrowingContinuation을 어떻게 바꿀것인가?
    func convertToRouteAndMetadata(from workout: HKWorkout) async -> ([CLLocation], [String: Any]) {
        let byWorkout = HKQuery.predicateForObjects(from: workout)

        let samples = try? await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[HKSample], Error>) in
            healthStore.execute(HKAnchoredObjectQuery(type: HKSeriesType.workoutRoute(), predicate: byWorkout, anchor: nil, limit: HKObjectQueryNoLimit, resultsHandler: { (query, samples, deletedObjects, anchor, error) in
                if let hasError = error {
                    continuation.resume(throwing: hasError); return
                }

                guard let samples = samples else { return }

                continuation.resume(returning: samples)
            }))
        }
        
        guard let route = (samples as? [HKWorkoutRoute])?.first else { return ([], [:]) }
        guard let metadata = route.metadata else { return ([], [:]) }
        
        let locations = try? await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[CLLocation], Error>) in
            var allLocations = [CLLocation]() // built up over time as and when HK tells us
            healthStore.execute(HKWorkoutRouteQuery(route: route) { (query, locationsOrNil, done, errorOrNil) in
                // This block may be called multiple times.
                if let error = errorOrNil {
                    continuation.resume(throwing: error); return
                }

                guard let locations = locationsOrNil else {
                    fatalError("Invalid State: This can only fail if there was an error.")
                }
                allLocations += locations

                if done {
                    continuation.resume(returning: allLocations)
                }
            })
        }
        guard let locations else { return ([], [:]) }
        return (locations, metadata)
    }
}

// MARK: - Chart Methods

extension HealthInteractor {

    private func settingForChartView(_ workouts: [WorkoutData]) async {
        let fourGames: [WorkoutData] = {
            let games = readRecentMatches(with: workouts, for: 4)
            let sorted = sortWorkoutsForChart(games)
            return makeBlankWorkouts(with: sorted)
        }()

        await MainActor.run {
            recent4Games = fourGames
            recentGames = sortWorkoutsForChart(workouts)
        }
    }
    
    private func readRecentMatches(with workouts: [WorkoutData], for count: Int) -> [WorkoutData] {
        guard !workouts.isEmpty else { return [] }
        guard workouts.count >= count  else { return workouts }
        let startIndex = workouts.count - count
        let lastIndex = workouts.count-1
        var recentMatches = [WorkoutData]()
        for i in startIndex...lastIndex {
            recentMatches.append(workouts[i])
        }
        return recentMatches
    }
    
    // 추세 데이터에서 데이터가 4개 이하인 경우에 실제 데이터와 fake 데이터를 혼합해서 보여줌
    private func makeBlankWorkouts(with workouts: [WorkoutData]) -> [WorkoutData] {
        var blanks = [WorkoutData]()
        if workouts.count < 4 {
            let count = workouts.count
            let blankCount = 4-count
            for _ in 0..<blankCount {
                blanks.append(WorkoutData.blankExample)
            }
        }
        return blanks + workouts
    }
    
    private func sortWorkoutsForChart(_ workouts: [WorkoutData]) -> [WorkoutData] {
        return workouts.sorted { preWork, postWork in
            preWork.formattedDate < postWork.formattedDate
        }
    }
    
    private func divideWorkoutsByMonthly(_ workouts: [WorkoutData]) -> [String: [WorkoutData]] {
        var dict = [String: [WorkoutData]]()
        workouts.forEach { match in
                let yearMonth = Array(match.date.split(separator: "-")[...1]).joined(separator: "-")
                dict[yearMonth, default: []].append(match)
            }
        return dict
    }
    
}
