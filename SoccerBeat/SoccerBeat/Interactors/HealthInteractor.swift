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
    var workoutData: [WorkoutData] = []
    // Average of the user workout data.
    var userAverage: WorkoutAverageData = WorkoutAverageData(maxHeartRate: 0,
                                                             minHeartRate: 0,
                                                             rangeHeartRate: 0,
                                                             totalDistance: 0.0,
                                                             maxAcceleration: 0,
                                                             maxVelocity: 0.0,
                                                             sprintCount: 0,
                                                             totalMatchTime: 0)
    // Maximum of the user workout data.
    var userMaximum: WorkoutAverageData = WorkoutAverageData(maxHeartRate: 0,
                                                             minHeartRate: 0,
                                                             rangeHeartRate: 0,
                                                             totalDistance: 0.0,
                                                             maxAcceleration: 0,
                                                             maxVelocity: 0.0,
                                                             sprintCount: 0,
                                                             totalMatchTime: 0)
    
    var allMetadata: [[String : Any]] = []
    var allRoutes: [CLLocation] = []
    // Badges in ProfileView
    // Value changes when the user gets the badge
    @Published var allBadges: [[Bool]] = [[false, false, false, false],
                                          [false, false, false, false],
                                          [false, false, false, false]]
    
    // Send when permission is granted by the user.
    var authSuccess = PassthroughSubject<(), Never>()
    // Send when data fetch is successful.
    var fetchSuccess = PassthroughSubject<(), Never>()
    
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
        var workoutData = [WorkoutData]()
        for (index, workout) in workouts.enumerated() {
            let workoutDatum = await convert(from: workout, at: index)
            workoutData.append(workoutDatum)
        }
        
        await calculateAverageAndMaxAbility(workoutData)
        settingForChartView()
        
        // TODO: Combine에서 직접 전달할 방법을 찾아보기
        self.workoutData = workoutData
        self.fetchSuccess.send()
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
        guard let distance: Double = getValue(from: metadata, forKey: "Distance"),
              let sprintCount: Int = getValue(from: metadata, forKey: "SprintCount"),
              let velocityMPS: Double = getValue(from: metadata, forKey: "MaxSpeed"),
              let acceleration: Double = getValue(from: metadata, forKey: "Acceleration"),
              let maxHeartRate: Int = getValue(from: metadata, forKey: "MaxHeartRate"),
              let minHeartRate: Int = getValue(from: metadata, forKey: "MinHeartRate")
        else { return  WorkoutData.blankExample }
        
        let velocityKMPH = Double((velocityMPS * 3.6).rounded(at: 2)) ?? 0
        
        // TODO: - badgeData를 WorkoutData로 바꾸는 정도만 해야할 듯
        // 바뀌어야 하는 이유, workoutData 가 있으면 for문 돌면서 뱃지를 계산하면 될 것
        let matchBadge = calculateBadgeData(distance: distance, sprint: sprintCount, velocity: velocityKMPH)
        
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
                                    lonSum / Double(dotCount)],
                           matchBadge: matchBadge)
    }
    
    func calculateAverageAndMaxAbility(_ workouts: [WorkoutData]) async {
        guard !workouts.isEmpty else { return }

        if workoutData.isEmpty {
            for workout in workouts {
                // Calculating average value..
                let maxHeartRate = workout.heartRate["max"] ?? 0
                let minHeartRate = workout.heartRate["min"] ?? 0
                userAverage.maxHeartRate += maxHeartRate
                userAverage.minHeartRate += minHeartRate
                userAverage.rangeHeartRate += maxHeartRate - minHeartRate
                userAverage.totalDistance += workout.distance
                userAverage.maxAcceleration += workout.acceleration
                userAverage.maxVelocity += workout.velocity
                userAverage.sprintCount += workout.sprint
                let rawTime = workout.time
                let separatedTime = rawTime.components(separatedBy: ":")
                let separatedMinutes = separatedTime[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let separatedSeconds = separatedTime[1].trimmingCharacters(in: .whitespacesAndNewlines)
                let currentPlayTime = (Int(separatedMinutes) ?? 0) * 60 + (Int(separatedSeconds) ?? 0)
                userAverage.totalMatchTime += currentPlayTime
                
                // Calculating Max value..
                userMaximum.maxHeartRate = max(userMaximum.maxHeartRate, maxHeartRate)
                userMaximum.minHeartRate = min(userMaximum.minHeartRate, minHeartRate)
                userMaximum.rangeHeartRate = max(userMaximum.rangeHeartRate, maxHeartRate - minHeartRate)
                userMaximum.totalDistance = max(userMaximum.totalDistance, workout.distance)
                userMaximum.maxAcceleration = max(userMaximum.maxAcceleration, workout.acceleration)
                userMaximum.maxVelocity = max(userMaximum.maxVelocity, workout.velocity)
                userMaximum.sprintCount = max(userMaximum.sprintCount, workout.sprint)
                userMaximum.totalMatchTime = max(userMaximum.totalMatchTime, currentPlayTime)
            }
            
            // Calculating average value..
            let workoutCount = workouts.count
            userAverage.maxHeartRate /= workoutCount
            userAverage.minHeartRate /= workoutCount
            userAverage.rangeHeartRate /= workoutCount
            userAverage.totalDistance /= Double(workoutCount)
            userAverage.maxAcceleration /= Double(workoutCount)
            userAverage.maxVelocity /= Double(workoutCount)
            userAverage.sprintCount /= workoutCount
            userAverage.totalMatchTime /= workoutCount
            
        }
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

    func calculateBadgeData(distance: Double, sprint: Int, velocity: Double) -> [Int] {
        // matchBadge: [distance, sprint, velocity]
        // [nil, first trophy, second trophy, third trophy] == [-1, 0, 1, 2]
        
        // 쇼케이스 시연을 위해 기준 하향 조정
        // Distance: 1, 2, 3, 4 -> 0.2, 0.4, 0.6, 0.8
        // Sprint: 1, 3, 5, 7 -> 1, 2, 3, 4
        // Velocity: 10, 15, 20, 25
        var matchBadge: [Int] = [0, 0, 0]

        if distance < 0.2 {
            matchBadge[0] = -1
        } else if (0.2 <= distance && distance < 0.4) {
            matchBadge[0] = 0
            allBadges[0][0] = true
        } else if (0.4 <= distance && distance < 0.6) {
            matchBadge[0] = 1
            allBadges[0][1] = true
        } else if (0.6 <= distance && distance < 0.8) {
            matchBadge[0] = 2
            allBadges[0][2] = true
        } else {
            matchBadge[0] = 3
            allBadges[0][3] = true
        }

        if sprint < 1 {
            matchBadge[1] = -1
        } else if (1 <= sprint && sprint < 2) {
            matchBadge[1] = 0
            allBadges[1][0] = true
        } else if (2 <= sprint && sprint < 3) {
            matchBadge[1] = 1
            allBadges[1][1] = true
        } else if (3 <= sprint && sprint < 4) {
            matchBadge[1] = 2
            allBadges[1][2] = true
        } else {
            matchBadge[1] = 3
            allBadges[1][3] = true
        }

        if velocity < 10 {
            matchBadge[2] = -1
        } else if (10 <= velocity && velocity < 15) {
            matchBadge[2] = 0
            allBadges[2][0] = true
        } else if (15 <= velocity && velocity < 20) {
            matchBadge[2] = 1
            allBadges[2][1] = true
        } else if (20 <= velocity && velocity < 25) {
            matchBadge[2] = 2
            allBadges[2][2] = true
        } else {
            matchBadge[2] = 3
            allBadges[2][3] = true
        }

        return matchBadge
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
    
    // dictionary를 안전하게 옵셔널 언래핑하기 위한 메서드
    private func getValue<T>(from dictionary: [String: Any], forKey: String) -> T? {
        dictionary[forKey] as? T
    }
}
