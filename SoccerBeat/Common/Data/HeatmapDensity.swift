import Foundation

struct HeatmapSample: Hashable {
    let latitude: Double
    let longitude: Double
    let timestamp: Date
    let horizontalAccuracy: Double
}

/// Time occupancy on a local, metre-based grid. No UI or MapKit dependencies.
struct HeatmapDensity {
    static let cellSize = 2.0
    static let sigma = 4.0
    static let maximumGap = 5.0
    static let maximumAccuracy = 20.0
    static let maximumSpeed = 12.0 // m/s; reject implausible GPS jumps.
    static let side = 100 // 200 m square around the match centre.
    static let earthRadius = 6_378_137.0

    let seconds: [Double]
    let smoothedSeconds: [Double]
    let referenceDensity: Double

    var intensities: [Double] {
        guard referenceDensity > 0 else { return Array(repeating: 0, count: seconds.count) }
        let threshold = displayThreshold
        return smoothedSeconds.map { $0 >= threshold ? min($0 / referenceDensity, 1) : 0 }
    }

    private var displayThreshold: Double {
        max((smoothedSeconds.max() ?? 0) * 0.01, 0.001)
    }

    init(samples: [HeatmapSample], centerLatitude: Double, centerLongitude: Double,
         pausedIntervals: [DateInterval] = []) {
        let count = Self.side * Self.side
        var grid = Array(repeating: 0.0, count: count)
        guard centerLatitude.isFinite, centerLongitude.isFinite,
              abs(centerLatitude) < 90, abs(centerLongitude) <= 180 else {
            seconds = grid
            smoothedSeconds = grid
            referenceDensity = 0
            return
        }
        let metresPerDegree = Self.earthRadius * .pi / 180
        let longitudeScale = metresPerDegree * cos(centerLatitude * .pi / 180)
        let ordered = samples.sorted { $0.timestamp < $1.timestamp }

        func valid(_ sample: HeatmapSample) -> Bool {
            sample.latitude.isFinite && sample.longitude.isFinite &&
            abs(sample.latitude) <= 90 && abs(sample.longitude) <= 180 &&
            sample.horizontalAccuracy.isFinite && sample.horizontalAccuracy >= 0 &&
            sample.horizontalAccuracy <= Self.maximumAccuracy
        }

        // Keep invalid samples as barriers: never connect across a rejected GPS fix.
        for (start, end) in zip(ordered, ordered.dropFirst()) {
            let duration = end.timestamp.timeIntervalSince(start.timestamp)
            guard valid(start), valid(end), duration > 0, duration <= Self.maximumGap,
                  !pausedIntervals.contains(where: {
                      max(start.timestamp, $0.start) < min(end.timestamp, $0.end)
                  }) else { continue }
            let x0 = (start.longitude - centerLongitude) * longitudeScale
            let y0 = (centerLatitude - start.latitude) * metresPerDegree
            let x1 = (end.longitude - centerLongitude) * longitudeScale
            let y1 = (centerLatitude - end.latitude) * metresPerDegree
            let distance = hypot(x1 - x0, y1 - y0)
            guard distance / duration <= Self.maximumSpeed else { continue }

            // Distribute elapsed time along short, valid segments, at <= 1 s / 2 m steps.
            let steps = max(1, Int(ceil(max(duration, distance / Self.cellSize))))
            for step in 0..<steps {
                let fraction = (Double(step) + 0.5) / Double(steps)
                let x = (x0 + (x1 - x0) * fraction) / Self.cellSize + Double(Self.side) / 2 - 0.5
                let y = (y0 + (y1 - y0) * fraction) / Self.cellSize + Double(Self.side) / 2 - 0.5
                // Bilinear deposition avoids jumps at cell boundaries.
                let col = Int(floor(x))
                let row = Int(floor(y))
                for dy in 0...1 {
                    for dx in 0...1 where (0..<Self.side).contains(col + dx) && (0..<Self.side).contains(row + dy) {
                        let weightX = dx == 0 ? 1 - (x - Double(col)) : x - Double(col)
                        let weightY = dy == 0 ? 1 - (y - Double(row)) : y - Double(row)
                        grid[(row + dy) * Self.side + col + dx] += duration / Double(steps) * weightX * weightY
                    }
                }
            }
        }

        seconds = grid
        let smoothed = Self.smooth(grid)
        smoothedSeconds = smoothed
        // Exclude empty cells and the very small Gaussian tails from the P98 reference.
        let threshold = max((smoothed.max() ?? 0) * 0.01, 0.001)
        let active = smoothed.filter { $0 >= threshold }.sorted()
        if active.isEmpty {
            referenceDensity = 0
        } else {
            let index = Double(active.count - 1) * 0.98
            let lower = Int(floor(index))
            let upper = Int(ceil(index))
            referenceDensity = active[lower] + (active[upper] - active[lower]) * (index - Double(lower))
        }
    }

    private static func smooth(_ grid: [Double]) -> [Double] {
        let sigmaCells = sigma / cellSize
        let radius = Int(ceil(3 * sigmaCells))
        let weights = (-radius...radius).map { exp(-Double($0 * $0) / (2 * sigmaCells * sigmaCells)) }
        let sum = weights.reduce(0, +)
        let kernel = weights.map { $0 / sum }
        var horizontal = Array(repeating: 0.0, count: grid.count)
        var result = horizontal
        for row in 0..<side {
            for col in 0..<side {
                for offset in -radius...radius {
                    if (0..<side).contains(col + offset) {
                        horizontal[row * side + col] += grid[row * side + col + offset] * kernel[offset + radius]
                    }
                }
            }
        }
        for row in 0..<side {
            for col in 0..<side {
                for offset in -radius...radius where (0..<side).contains(row + offset) {
                    result[row * side + col] += horizontal[(row + offset) * side + col] * kernel[offset + radius]
                }
            }
        }
        return result
    }
}
