import Foundation

enum WorkoutRecordReconciliation {
    /// Recompute from the current snapshot; repeated HealthKit refreshes must be idempotent.
    static func average(of workouts: [WorkoutData]) -> WorkoutAverageData {
        let records = workouts.filter { !$0.error }
        func mean(_ metric: WorkoutMetric, _ value: (WorkoutData) -> Double) -> Double {
            let values = records.filter { !$0.unavailableMetrics.contains(metric) }.map(value)
            return values.isEmpty ? 0 : values.reduce(0, +) / Double(values.count)
        }
        var result = WorkoutAverageData()
        result.totalDistance = mean(.distance) { $0.distance }
        result.maxVelocity = mean(.maxSpeed) { $0.velocity }
        result.sprintCount = Int(mean(.sprint) { Double($0.sprint) })
        result.calories = Int(mean(.calories) { Double($0.calories) })
        result.minHeartRate = Int(mean(.minHeartRate) { Double($0.minHeartRate) })
        result.maxHeartRate = Int(mean(.maxHeartRate) { Double($0.maxHeartRate) })
        let ranges = records.filter {
            !$0.unavailableMetrics.contains(.minHeartRate) && !$0.unavailableMetrics.contains(.maxHeartRate)
        }.map { $0.maxHeartRate - $0.minHeartRate }
        result.rangeHeartRate = ranges.isEmpty ? 0 : ranges.reduce(0, +) / ranges.count
        let powers = records.filter { $0.hasPowerData }.map { $0.power }
        result.maxPower = powers.isEmpty ? 0 : powers.reduce(0, +) / Double(powers.count)
        result.totalMatchTime = records.isEmpty ? 0 : records.map { $0.playtimeSec }.reduce(0, +) / records.count
        return result
    }

    static func metadata(workout: [String: Any], routes: [[String: Any]]) -> [String: Any] {
        var combined: [String: Any] = [:]
        for route in routes { combined.merge(route) { _, newer in newer } }
        combined.merge(workout) { _, canonical in canonical }
        return combined
    }

    static func distance(statistics: Double?, total: Double?, metadata: Double?, metadataObserved: Bool?) -> Double? {
        let measured = [statistics, total].compactMap { value -> Double? in
            guard let value, value.isFinite, value >= 0 else { return nil }
            return value
        }
        // HealthKit aggregates retain precision lost by older rounded route metadata.
        if let positive = measured.first(where: { $0 > 0 }) { return positive }
        let metadataIsValid = metadataObserved != false && metadata?.isFinite == true && (metadata ?? -1) >= 0
        if metadataIsValid, let metadata, metadata > 0 { return metadata }
        if let zero = measured.first { return zero }
        return metadataIsValid && metadataObserved == true ? metadata : nil
    }

    static func heartRates(metadata: String) -> [Int] {
        metadata.split(separator: ",").compactMap { value in
            guard let rate = Double(value.trimmingCharacters(in: .whitespaces)),
                  rate.isFinite, rate > 0, rate < Double(Int.max) else { return nil }
            return Int(rate.rounded(.toNearestOrAwayFromZero))
        }
    }
}

extension WorkoutData {
    /// A failed/empty refresh must not replace measurements already read for the same HKWorkout.
    func preservingAvailableData(from previous: WorkoutData?) -> WorkoutData {
        guard let previous, previous.id == id else { return self }
        var missing = unavailableMetrics
        func keepPrevious(_ metric: WorkoutMetric) -> Bool {
            let preserve = missing.contains(metric) && !previous.unavailableMetrics.contains(metric)
            if preserve { missing.remove(metric) }
            return preserve
        }
        let distance = keepPrevious(.distance) ? previous.distance : self.distance
        let sprint = keepPrevious(.sprint) ? previous.sprint : self.sprint
        let velocity = keepPrevious(.maxSpeed) ? previous.velocity : self.velocity
        let calories = keepPrevious(.calories) ? previous.calories : self.calories
        let minimum = keepPrevious(.minHeartRate) ? previous.minHeartRate : minHeartRate
        let maximum = keepPrevious(.maxHeartRate) ? previous.maxHeartRate : maxHeartRate
        let previousRatesHaveDates = previous.heartRateDates.count == previous.heartRates.count
        let keepRicherRates = previous.heartRates.count > heartRates.count
            && (previousRatesHaveDates || hasRetrievalFailure)
        let keepRates = !previous.heartRates.isEmpty && (heartRates.isEmpty || keepRicherRates)
        if keepRates { missing.remove(.heartRate) }
        let keepRicherRoute = previous.route.count > route.count
        let keepRoute = !previous.route.isEmpty && (routeAvailability != .available || keepRicherRoute)

        var result = WorkoutData(dataID: dataID, date: date, time: time,
                                 distance: distance, sprint: sprint, velocity: velocity,
                                 power: hasPowerData ? power : previous.power,
                                 heartRate: ["min": minimum, "max": maximum],
                                 heartRates: keepRates ? previous.heartRates : heartRates,
                                 route: keepRoute ? previous.route : route,
                                 center: keepRoute ? previous.center : center,
                                 calories: calories, vo2Max: vo2Max > 0 ? vo2Max : previous.vo2Max, error: error,
                                 heatmapSamples: keepRoute ? previous.heatmapSamples : heatmapSamples,
                                 heatmapPausedIntervals: keepRoute ? previous.heatmapPausedIntervals : heatmapPausedIntervals,
                                 hasPowerData: hasPowerData || previous.hasPowerData)
        result.id = id
        result.unavailableMetrics = missing
        result.routeAvailability = keepRoute ? .available : routeAvailability
        result.heartRateAvailability = keepRates ? .available : heartRateAvailability
        result.heartRateDates = keepRates ? previous.heartRateDates : heartRateDates
        result.hasRetrievalFailure = hasRetrievalFailure || keepRicherRoute || keepRicherRates
        return result
    }
}
