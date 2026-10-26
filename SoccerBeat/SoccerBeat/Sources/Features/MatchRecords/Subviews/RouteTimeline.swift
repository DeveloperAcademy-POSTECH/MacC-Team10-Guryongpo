import Foundation

/// Immutable playback data. Sample timestamps drive seeking; legacy coordinates use progress only.
struct RouteTimeline {
    struct Point: Equatable {
        let latitude: Double
        let longitude: Double
        let timestamp: Date?
    }

    enum GapReason: Equatable {
        case sampleGap, lowAccuracy, paused, locationJump, invalidLocation
    }

    struct Selection {
        let point: Point
        let hasLocation: Bool
        let gapReason: GapReason?
        let isIsolatedFix: Bool
    }

    let points: [Point]
    let connectsToPrevious: [Bool]
    let gapReasons: [GapReason?]

    var hasTimestamps: Bool { points.first?.timestamp != nil }
    var canSeek: Bool { points.count > 1 }

    init(samples: [HeatmapSample], fallback: [Point], pauses: [DateInterval]) {
        var points: [Point] = []
        var connections: [Bool] = []
        var reasons: [GapReason?] = []
        var pendingReason: GapReason?
        func valid(_ latitude: Double, _ longitude: Double) -> Bool {
            latitude.isFinite && longitude.isFinite && abs(latitude) <= 90 && abs(longitude) <= 180
        }
        if samples.isEmpty {
            for point in fallback {
                guard valid(point.latitude, point.longitude) else {
                    pendingReason = .invalidLocation
                    continue
                }
                let reason = points.isEmpty ? nil : pendingReason
                connections.append(!points.isEmpty && reason == nil)
                reasons.append(reason)
                points.append(point)
                pendingReason = nil
            }
        } else {
            for sample in samples.sorted(by: { $0.timestamp < $1.timestamp }) {
                guard valid(sample.latitude, sample.longitude), sample.timestamp.timeIntervalSince1970.isFinite else {
                    pendingReason = .invalidLocation
                    continue
                }
                if pauses.contains(where: { $0.start <= sample.timestamp && sample.timestamp < $0.end }) {
                    pendingReason = .paused
                    continue
                }
                guard sample.horizontalAccuracy.isFinite, (0...20).contains(sample.horizontalAccuracy) else {
                    pendingReason = .lowAccuracy
                    continue
                }
                if points.last?.timestamp == sample.timestamp { continue }
                var reason = points.isEmpty ? nil : pendingReason
                if let previous = points.last, let time = previous.timestamp {
                    let interval = sample.timestamp.timeIntervalSince(time)
                    guard interval > 0 else { continue }
                    let scale = HeatmapDensity.earthRadius * .pi / 180
                    let x = (sample.longitude - previous.longitude) * scale * cos(sample.latitude * .pi / 180)
                    let y = (sample.latitude - previous.latitude) * scale
                    let distance = hypot(x, y)
                    if pauses.contains(where: { max(time, $0.start) < min(sample.timestamp, $0.end) }) {
                        reason = .paused
                    } else if distance / interval > 12.5 {
                        reason = .locationJump
                    } else {
                        if reason == nil && interval > 5 { reason = .sampleGap }
                        // Bridge only short, nearby GPS gaps for display and playback.
                        // Stored samples and workout metrics remain unchanged.
                        if [.sampleGap, .lowAccuracy, .invalidLocation].contains(reason),
                           interval <= 10, distance <= 30 {
                            reason = nil
                        }
                    }
                }
                connections.append(!points.isEmpty && reason == nil)
                reasons.append(reason)
                points.append(Point(latitude: sample.latitude, longitude: sample.longitude, timestamp: sample.timestamp))
                pendingReason = nil
            }
        }
        self.points = points
        self.connectsToPrevious = connections
        self.gapReasons = reasons
    }

    func progress(at index: Int) -> Double {
        guard points.count > 1 else { return 0 }
        if let first = points.first?.timestamp, let last = points.last?.timestamp,
           let time = points[index].timestamp, last > first {
            return time.timeIntervalSince(first) / last.timeIntervalSince(first)
        }
        return Double(index) / Double(points.count - 1)
    }

    func selection(at progress: Double) -> Selection? {
        guard let first = points.first, let last = points.last else { return nil }
        let target = progress.isFinite ? min(max(progress, 0), 1) : 0
        if points.count == 1 || target == 0 { return Selection(point: first, hasLocation: true, gapReason: nil, isIsolatedFix: isIsolated(at: 0)) }
        if target == 1 { return Selection(point: last, hasLocation: true, gapReason: nil, isIsolatedFix: isIsolated(at: points.count - 1)) }
        var lower = 0
        var upper = points.count - 1
        while upper - lower > 1 {
            let middle = (lower + upper) / 2
            if self.progress(at: middle) < target { lower = middle } else { upper = middle }
        }
        let start = points[lower]
        let end = points[upper]
        let fraction = (target - self.progress(at: lower)) / (self.progress(at: upper) - self.progress(at: lower))
        let timestamp = first.timestamp.flatMap { first in
            last.timestamp.map { first.addingTimeInterval($0.timeIntervalSince(first) * target) }
        }
        let hasLocation = connectsToPrevious[upper] || fraction == 0 || fraction == 1
        let position = hasLocation ? fraction : 0
        let exactIndex = fraction == 0 ? lower : fraction == 1 ? upper : nil
        return Selection(point: Point(latitude: start.latitude + (end.latitude - start.latitude) * position,
                                      longitude: start.longitude + (end.longitude - start.longitude) * position,
                                      timestamp: timestamp), hasLocation: hasLocation,
                         gapReason: hasLocation ? nil : gapReasons[upper],
                         isIsolatedFix: exactIndex.map { isIsolated(at: $0) } ?? false)
    }

    private func isIsolated(at index: Int) -> Bool {
        !connectsToPrevious[index] && (index + 1 == points.count || !connectsToPrevious[index + 1])
    }
}
