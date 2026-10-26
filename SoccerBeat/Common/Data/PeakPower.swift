import Foundation

/// nil means no measurement, which is different from a measured zero watts.
struct PeakPower {
    private(set) var watts: Double?

    mutating func observe(_ measurement: Double?) {
        guard let measurement, measurement.isFinite, measurement >= 0 else { return }
        watts = max(watts ?? measurement, measurement)
    }
}
