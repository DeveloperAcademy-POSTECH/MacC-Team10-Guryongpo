import Foundation

/// Field Chart v2. Scores are activity indicators; rendering reserves a visible 30% radius.
final class DataConverter {
    static let version = 2
    // Clockwise order matches the existing six labels: Agility, Activity, Potential,
    // Mentality, Endurance, Explosivity. Unknown inputs remain nil until rendering.
    static let axisCount = 6
    private static let scoreAnchors = [0.0, 40, 70, 85, 100]

    static func toLevels(_ workout: WorkoutData) -> [Double] {
        displayLevels(measuredScores(workout))
    }

    static func toLevels(_ workout: WorkoutAverageData) -> [Double] {
        displayLevels(workout.fieldChartScores)
    }

    static func displayLevels(_ scores: [Double?]) -> [Double] {
        let known = scores.compactMap { $0 }.filter { $0.isFinite }
        let fallback = known.isEmpty ? 50 : min(70, known.reduce(0, +) / Double(known.count))
        return (0..<axisCount).map { index in
            let score = index < scores.count ? scores[index] : nil
            let value = score.flatMap { $0.isFinite ? $0 : nil } ?? fallback
            return 1.5 + 3.5 * min(100, max(0, value)) / 100
        }
    }

    static func averageScores(_ workouts: [WorkoutData]) -> [Double?] {
        let scores = workouts.filter { !$0.error }.map(measuredScores)
        return (0..<axisCount).map { index in
            let values = scores.compactMap { $0[index] }
            return values.isEmpty ? nil : values.reduce(0, +) / Double(values.count)
        }
    }

    static func maximumScores(_ workouts: [WorkoutData]) -> [Double?] {
        let scores = workouts.filter { !$0.error }.map(measuredScores)
        return (0..<axisCount).map { index in scores.compactMap { $0[index] }.max() }
    }

    private static func points(_ value: Double, _ thresholds: [Double]) -> Double {
        guard value > thresholds[0] else { return 0 }
        for index in 1..<thresholds.count where value <= thresholds[index] {
            let fraction = (value - thresholds[index - 1]) / (thresholds[index] - thresholds[index - 1])
            return scoreAnchors[index - 1] + fraction * (scoreAnchors[index] - scoreAnchors[index - 1])
        }
        return 100
    }

    private struct Interval {
        let start: Date
        let end: Date
        let value: Double
        var seconds: Double { end.timeIntervalSince(start) }
    }

    private static func pauses(_ workout: WorkoutData) -> [DateInterval] {
        var result: [DateInterval] = []
        for pause in workout.heatmapPausedIntervals.sorted(by: { $0.start < $1.start }) where pause.duration > 0 {
            if let last = result.last, pause.start <= last.end {
                result[result.count - 1] = DateInterval(start: last.start, end: max(last.end, pause.end))
            } else { result.append(pause) }
        }
        return result
    }

    private static func activePieces(_ interval: Interval, pauses: [DateInterval], start: Date, end: Date) -> [Interval] {
        var cursor = max(interval.start, start)
        let limit = min(interval.end, end)
        guard cursor < limit else { return [] }
        var result: [Interval] = []
        for pause in pauses where pause.end > cursor && pause.start < limit {
            if pause.start > cursor { result.append(Interval(start: cursor, end: pause.start, value: interval.value)) }
            cursor = max(cursor, pause.end)
            if cursor >= limit { return result }
        }
        if cursor < limit { result.append(Interval(start: cursor, end: limit, value: interval.value)) }
        return result
    }

    private static func fastestThreeSeconds(_ segments: [Interval]) -> Double? {
        var left = 0
        var integral = 0.0
        var best: Double?
        for index in segments.indices {
            let segment = segments[index]
            if index == 0 || abs(segment.start.timeIntervalSince(segments[index - 1].end)) > 0.001 {
                left = index
                integral = 0
            }
            integral += segment.value * segment.seconds
            let windowStart = segment.end.addingTimeInterval(-3)
            while left < index && segments[left].end <= windowStart {
                integral -= segments[left].value * segments[left].seconds
                left += 1
            }
            if windowStart >= segments[left].start {
                let partial = windowStart.timeIntervalSince(segments[left].start) * segments[left].value
                best = max(best ?? 0, (integral - partial) / 3)
            }
        }
        return best
    }

    static func measuredScores(_ workout: WorkoutData) -> [Double?] {
        guard !workout.error else { return Array(repeating: nil, count: axisCount) }
        let clock = workout.time.split(separator: ":").compactMap { Double($0.trimmingCharacters(in: .whitespaces)) }
        let duration = workout.recordedDuration ?? (clock.count == 2 ? clock[0] * 60 + clock[1] : 0)
        guard duration.isFinite, duration > 0 else { return Array(repeating: nil, count: axisCount) }
        var scores = Array<Double?>(repeating: nil, count: axisCount)
        if !workout.unavailableMetrics.contains(.distance), workout.distance.isFinite, workout.distance >= 0 {
            scores[1] = points(workout.distance * 1000 / (duration / 60), [0, 30, 55, 75, 100])
        }
        let ordered = workout.speedSamples.filter { $0.timestamp.timeIntervalSince1970.isFinite }
            .sorted { $0.timestamp < $1.timestamp }
        let start = workout.startDate ?? ordered.first?.timestamp ?? workout.heartRateDates.first
        guard let start, start.timeIntervalSince1970.isFinite else { return scores }
        let end = workout.endDate ?? start.addingTimeInterval(duration)
        guard end > start else { return scores }
        let paused = pauses(workout)
        var detector = SprintDetector()
        var previous: WorkoutSpeedSample?
        var segments: [Interval] = []
        var lastSeen: Date?
        for sample in ordered where sample.timestamp >= start && sample.timestamp <= end {
            if let lastSeen, sample.timestamp <= lastSeen { continue }
            lastSeen = sample.timestamp
            if paused.contains(where: { $0.contains(sample.timestamp) && sample.timestamp < $0.end }) {
                detector.pause()
                previous = nil
                continue
            }
            if let anchor = previous, paused.contains(where: { max(anchor.timestamp, $0.start) < min(sample.timestamp, $0.end) }) {
                detector.pause()
                previous = nil
            }
            detector.process(timestamp: sample.timestamp, speed: sample.speed, speedAccuracy: sample.speedAccuracy,
                             horizontalAccuracy: sample.horizontalAccuracy, receivedAt: sample.timestamp)
            guard detector.currentSpeed(at: sample.timestamp) != nil else { previous = nil; continue }
            if let previous {
                let gap = sample.timestamp.timeIntervalSince(previous.timestamp)
                if gap > 0 && gap <= 2 {
                    let interval = Interval(start: previous.timestamp, end: sample.timestamp, value: (previous.speed + sample.speed) / 2)
                    segments += activePieces(interval, pauses: paused, start: start, end: end)
                }
            }
            previous = sample
        }
        if let speed = fastestThreeSeconds(segments) {
            scores[0] = points(speed * 3.6, [0, 10, 16, 21, 26])
        }
        let covered = segments.reduce(0) { $0 + $1.seconds }
        if covered >= duration * 0.70 {
            let fast = segments.filter { $0.value * 3.6 >= 14 }.reduce(0) { $0 + $1.seconds }
            scores[3] = points(100 * fast / covered, [0, 1, 4, 8, 14])
            if duration >= 600, !workout.unavailableMetrics.contains(.sprint), workout.sprint >= 0 {
                // Keep the chart consistent with the Sprint count shown in the saved report.
                scores[5] = points(Double(workout.sprint) / (covered / 600), [0, 0.5, 1, 2, 3])
            }
        }
        // Compare first/last thirds in active elapsed time, without treating GPS gaps as standing still.
        if duration >= 900 {
            func offset(_ date: Date) -> Double {
                date.timeIntervalSince(start) - paused.reduce(0) { total, pause in
                    total + max(0, min(date, pause.end).timeIntervalSince(max(start, pause.start)))
                }
            }
            let third = duration / 3
            var firstTime = 0.0, lastTime = 0.0, firstDistance = 0.0, lastDistance = 0.0
            for segment in segments {
                let a = offset(segment.start), b = offset(segment.end)
                let first = max(0, min(b, third) - max(a, 0))
                let last = max(0, min(b, duration) - max(a, duration - third))
                firstTime += first; lastTime += last
                firstDistance += first * segment.value; lastDistance += last * segment.value
            }
            if firstTime >= third * 0.70, lastTime >= third * 0.70, firstDistance / firstTime * 60 >= 20 {
                scores[4] = points(100 * (lastDistance / lastTime) / (firstDistance / firstTime), [0, 50, 75, 90, 100])
            }
        }
        // Potential represents heart-rate load, using the recorded age-based reference, not this match's peak.
        if let reference = workout.heartRateReferenceMaximum, reference.isFinite, reference > 0,
           workout.heartRateDates.count == workout.heartRates.count {
            let readings = zip(workout.heartRateDates, workout.heartRates)
                .filter { $0.0.timeIntervalSince1970.isFinite }.sorted { $0.0 < $1.0 }
            var heartSegments: [Interval] = []
            for index in readings.indices.dropFirst() {
                let previous = readings[index - 1], current = readings[index]
                let gap = current.0.timeIntervalSince(previous.0)
                if gap > 0 && gap <= 15 && previous.1 > 0 && current.1 > 0 {
                    heartSegments += activePieces(Interval(start: previous.0, end: current.0,
                                                          value: (Double(previous.1) + Double(current.1)) / 2),
                                                 pauses: paused, start: start, end: end)
                }
            }
            let seconds = heartSegments.reduce(0) { $0 + $1.seconds }
            if seconds >= duration * 0.70 {
                let mean = heartSegments.reduce(0) { $0 + $1.value * $1.seconds } / seconds
                scores[2] = points(mean / reference, [0, 0.50, 0.65, 0.80, 0.90])
            }
        }
        return scores
    }
}
