// Run from the repository root:
// bash SoccerBeat/HeatmapDensityTests/run-tests.sh
import XCTest

final class HeatmapDensityTests: XCTestCase {
    private func sample(_ time: Double) -> HeatmapSample { sample(0, 0, time) }

    private func sample(_ x: Double, _ y: Double, _ time: Double,
                        accuracy: Double = 5, latitude: Double = 41) -> HeatmapSample {
        let scale = HeatmapDensity.earthRadius * .pi / 180
        return HeatmapSample(latitude: latitude - y / scale,
                             longitude: 2 + x / (scale * cos(latitude * .pi / 180)),
                             timestamp: Date(timeIntervalSince1970: time), horizontalAccuracy: accuracy)
    }

    private func density(_ samples: [HeatmapSample], pauses: [DateInterval] = [],
                         latitude: Double = 41) -> HeatmapDensity {
        HeatmapDensity(samples: samples, centerLatitude: latitude, centerLongitude: 2, pausedIntervals: pauses)
    }

    @objc func testEmptyAndSingleFixHaveNoInventedDuration() {
        for samples in [[], [sample(0)]] {
            let result = density(samples)
            XCTAssertEqual(result.seconds.reduce(0, +), 0)
            XCTAssertTrue(result.intensities.allSatisfy { $0 == 0 })
        }
    }

    @objc func testSampleRateDoesNotChangeStationaryOccupancy() {
        let slow = density((0...20).map { sample(Double($0)) })
        let fast = density((0...40).map { sample(Double($0) / 2) })
        XCTAssertEqual(slow.seconds.reduce(0, +), 20, accuracy: 1e-8)
        XCTAssertEqual(slow.smoothedSeconds.reduce(0, +), 20, accuracy: 1e-8)
        for (a, b) in zip(slow.smoothedSeconds, fast.smoothedSeconds) {
            XCTAssertEqual(a, b, accuracy: 1e-8)
        }
    }

    @objc func testMovingSampleRateHasNearlyIdenticalDensity() {
        let slow = density((0...20).map { sample(Double($0) * 2, 0, Double($0)) })
        let fast = density((0...40).map { sample(Double($0), 0, Double($0) / 2) })
        let difference = zip(slow.smoothedSeconds, fast.smoothedSeconds).reduce(0) { $0 + abs($1.0 - $1.1) }
        XCTAssertEqual(slow.seconds.reduce(0, +), 20, accuracy: 1e-8)
        XCTAssertLessThan(difference / 20, 0.01)
    }

    @objc func testInvalidCentreProducesNoDensity() {
        let result = density([sample(0), sample(1)], latitude: .nan)
        XCTAssertTrue(result.intensities.allSatisfy { $0 == 0 })
    }

    @objc func testMovingSegmentsDistributeTimeAcrossRoute() {
        let result = density([sample(-10, 0, 0), sample(10, 0, 4)])
        XCTAssertEqual(result.seconds.reduce(0, +), 4, accuracy: 1e-8)
        XCTAssertGreaterThan(result.seconds.filter { $0 > 0 }.count, 10)
        XCTAssertGreaterThan(result.smoothedSeconds[50 * HeatmapDensity.side + 50], 0)
    }

    @objc func testLongGPSGapAndImplausibleJumpAreNotFilled() {
        XCTAssertEqual(density([sample(0), sample(60)]).seconds.reduce(0, +), 0)
        XCTAssertEqual(density([sample(0), sample(100, 0, 1)]).seconds.reduce(0, +), 0)
    }

    @objc func testRejectedFixIsABarrierRatherThanAShortcut() {
        for accuracy in [-1.0, 21.0, Double.nan] {
            let result = density([sample(0), sample(0, 0, 1, accuracy: accuracy), sample(2)])
            XCTAssertEqual(result.seconds.reduce(0, +), 0)
        }
        let invalid = HeatmapSample(latitude: .nan, longitude: 2,
                                    timestamp: Date(timeIntervalSince1970: 1), horizontalAccuracy: 5)
        XCTAssertEqual(density([sample(0), invalid, sample(2)]).seconds.reduce(0, +), 0)
    }

    @objc func testPausesAndShortPauseCrossingsAreExcluded() {
        let pause = DateInterval(start: Date(timeIntervalSince1970: 5), end: Date(timeIntervalSince1970: 10))
        let result = density((0...20).map { sample(Double($0)) }, pauses: [pause])
        XCTAssertEqual(result.seconds.reduce(0, +), 15, accuracy: 1e-8)
        let short = DateInterval(start: Date(timeIntervalSince1970: 0.4), end: Date(timeIntervalSince1970: 0.6))
        XCTAssertEqual(density([sample(0), sample(1)], pauses: [short]).seconds.reduce(0, +), 0)
    }

    @objc func testChronologicalOrderAndDuplicateTimesAreSafe() {
        let result = density([sample(2), sample(0), sample(1), sample(1)])
        XCTAssertEqual(result.seconds.reduce(0, +), 2, accuracy: 1e-8)
    }

    @objc func testGridUsesMetresAtDifferentLatitudes() {
        let equator = density([sample(8, 6, 0, latitude: 0), sample(8, 6, 1, latitude: 0)], latitude: 0)
        let north = density([sample(8, 6, 0, latitude: 60), sample(8, 6, 1, latitude: 60)], latitude: 60)
        for (a, b) in zip(equator.smoothedSeconds, north.smoothedSeconds) {
            XCTAssertEqual(a, b, accuracy: 1e-8)
        }
    }

    @objc func testOutsideGridDoesNotTruncateIntoEdgeCell() {
        let result = density([sample(-103, 0, 0), sample(-103, 0, 1)])
        XCTAssertEqual(result.seconds.reduce(0, +), 0)
    }

    @objc func testDensityPreservesTimeRatioWithoutLogBoost() {
        let long = (0...100).map { sample(-20, 0, Double($0)) }
        let short = (200...210).map { sample(20, 0, Double($0)) }
        let result = density(long + short)
        let left = result.smoothedSeconds[50 * HeatmapDensity.side + 40]
        let right = result.smoothedSeconds[50 * HeatmapDensity.side + 60]
        XCTAssertEqual(right / left, 0.1, accuracy: 1e-6)
        XCTAssertGreaterThan(result.referenceDensity, 0)
        XCTAssertTrue(result.intensities.allSatisfy { $0.isFinite && $0 >= 0 && $0 <= 1 })
        XCTAssertEqual(result.intensities.max(), 1)
    }
}

@main
struct HeatmapTestRunner {
    static func main() {
        let suite = HeatmapDensityTests.defaultTestSuite
        precondition(suite.testCaseCount == 12)
        suite.run()
        exit(suite.testRun?.hasSucceeded == true ? 0 : 1)
    }
}
