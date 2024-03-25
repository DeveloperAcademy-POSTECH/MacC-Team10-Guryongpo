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


/// 1. 유저 최고 능력치 계산
/// 2.유저 평군 능력치 계산
/// 3. HealthStore와 통신
/// 4. 월별 경기 데이터 가지고 있음
/// 5. 경기별 경로 데이터
/// 6. HKHealthStore에서 경기 데이터 가져오기
/// 7. 커스텀 데이터 계산
/// 8. 추세 analysis 데이터 계산
// MARK: - 역할
@MainActor
final class HealthInteractor: ObservableObject {
    // Object to request permission to read HealthKit data.
    var healthStore = HKHealthStore()
    let typesToRead = Set([HKObjectType.quantityType(forIdentifier: .heartRate)!,
                          HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
                          HKObjectType.quantityType(forIdentifier: .runningSpeed)!,
                          HKObjectType.quantityType(forIdentifier: .walkingSpeed)!,
                          HKSeriesType.workoutType(),
                          HKSeriesType.workoutRoute(),
                          HKObjectType.activitySummaryType()
                         ])
    // Entire user workouts in HealthKit data.
    private var workoutData: [WorkoutData] = []
    
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
    
    @Published var recent9Games = [WorkoutData]()
    @Published var recent4Games = [WorkoutData]()
    
    var monthly: [String: [WorkoutData]] {
        var dict = [String: [WorkoutData]]()
        workoutData.forEach { match in
            let yearMonth = Array(match.date.split(separator: "-")[...1]).joined(separator: "-")
            dict[yearMonth, default: []].append(match)
        }
        return dict
    }
    
    @MainActor
    func requestAuthorization() {
        print("requestAuthorization: request user authorization..")
        
        // 해당 기기가 헬스킷을 사용할 수 있는지 확인 함
        guard HKHealthStore.isHealthDataAvailable() else {
            print("requestAuthorization: health data not available")
            return
        }
        
        healthStore.requestAuthorization(toShare: nil, read: typesToRead) { success, error in
            // Success means that the Permission window appears.
            if success {
                self.authSuccess.send()
            } else {
                NSLog("Error in getting healthstore reading authorization. ")
            }
        }
                

    }
    
    func fetchWorkoutData() async {
        print("fetchHKWorkout: attempting to fetch all data..")
        // Fetch from HealthStore
        let workouts = await fetchHKWorkouts()
        
        // Convert WorkoutData(Bussiness Model)
        for (index, workout) in workouts.enumerated() {
            let workoutDatum = await convert(from: workout, at: index)
            workoutData.append(workoutDatum)
        }
        
        settingForChartView()
        self.fetchWorkoutsSuccess.send(workoutData)
        
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
              let acceleration: Double = metadata.getValue(forKey: "Acceleration"),
              let maxHeartRate: Int = metadata.getValue(forKey: "MaxHeartRate"),
              let minHeartRate: Int = metadata.getValue(forKey: "MinHeartRate")
        else { return  WorkoutData.blankExample }
        
        let velocityKMPH = Double((velocityMPS * 3.6).rounded(at: 2)) ?? 0
        
        // TODO: - badgeData를 WorkoutData로 바꾸는 정도만 해야할 듯
        // 바뀌어야 하는 이유, workoutData 가 있으면 for문 돌면서 뱃지를 계산하면 될 것
//        let matchBadge = calculateBadgeData(distance: distance, sprint: sprintCount, velocity: velocityKMPH)
        
        let displayedTime = String(Int(workout.duration)/60) + " : " + String(Int(workout.duration) % 60)
        let dotCount = routes.count
        return WorkoutData(dataID: index+1,
                           date: dateFormatter.string(from: workout.startDate),
                           time: displayedTime,
                           distance: distance,
                           sprint: sprintCount,
                           velocity: velocityKMPH, // km/h
                           acceleration: acceleration,
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
    
    private func settingForChartView() {
        let nineGames: [WorkoutData] = {
            let games = readRecentMatches(for: 9)
            return sortWorkoutsForChart(games)
        }()
        let fourGames: [WorkoutData] = {
            let games = readRecentMatches(for: 4)
            let sorted = sortWorkoutsForChart(games)
            return makeBlankWorkouts(with: sorted)
        }()
        recent4Games = fourGames
        recent9Games = nineGames
    }
    
    private func readRecentMatches(for count: Int) -> [WorkoutData] {
        guard !workoutData.isEmpty else { return [] }
        guard workoutData.count >= count  else { return workoutData }
        let startIndex = workoutData.count - count
        let lastIndex = workoutData.count-1
        var recentMatches = [WorkoutData]()
        for i in startIndex...lastIndex {
            recentMatches.append(workoutData[i])
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
}
