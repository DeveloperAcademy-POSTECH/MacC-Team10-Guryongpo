// Run: bash SoccerBeat/RouteTimelineTests/run-tests.sh
import XCTest

final class RouteTimelineTests: XCTestCase {
    private func sample(_ x: Double, _ time: Double, accuracy: Double = 5) -> HeatmapSample {
        let scale = HeatmapDensity.earthRadius * .pi / 180 * cos(41 * .pi / 180)
        return HeatmapSample(latitude: 41, longitude: 2 + x / scale,
                             timestamp: Date(timeIntervalSince1970: time), horizontalAccuracy: accuracy)
    }

    private func timeline(_ samples: [HeatmapSample], pauses: [DateInterval] = []) -> RouteTimeline {
        RouteTimeline(samples: samples, fallback: [], pauses: pauses)
    }

    @objc func testEmptyRouteAndSinglePointAreSafe() {
        XCTAssertNil(timeline([]).selection(at: 1))
        let route = timeline([sample(0, 0)])
        XCTAssertFalse(route.canSeek)
        XCTAssertEqual(route.selection(at: 1)?.point, route.points.first)
    }

    @objc func testZeroAndOneReachExactEndpoints() {
        let route = timeline([sample(0, 0), sample(10, 1)])
        XCTAssertEqual(route.selection(at: 0)?.point, route.points.first)
        XCTAssertEqual(route.selection(at: 1)?.point, route.points.last)
        XCTAssertEqual(route.selection(at: -1)?.point, route.points.first)
        XCTAssertEqual(route.selection(at: 2)?.point, route.points.last)
        XCTAssertEqual(route.selection(at: .nan)?.point, route.points.first)
    }

    @objc func testFractionalSeekInterpolatesInsteadOfSnappingToGPSFix() {
        let route = timeline([sample(0, 0), sample(10, 1)])
        let selection = route.selection(at: 0.25)!
        XCTAssertEqual(selection.point.longitude, sample(2.5, 0).longitude, accuracy: 1e-10)
        XCTAssertEqual(selection.point.timestamp!.timeIntervalSince1970, 0.25, accuracy: 1e-10)
        XCTAssertTrue(selection.hasLocation)
    }

    @objc func testIrregularSamplingUsesTimeRatherThanPointIndex() {
        let route = timeline([sample(0, 0), sample(1, 1), sample(5, 5)])
        let selection = route.selection(at: 0.5)!
        XCTAssertEqual(selection.point.longitude, sample(2.5, 0).longitude, accuracy: 1e-10)
        XCTAssertEqual(selection.point.timestamp!.timeIntervalSince1970, 2.5, accuracy: 1e-10)
    }

    @objc func testLongGPSGapDoesNotInventIntermediateLocationOrLine() {
        let route = timeline([sample(0, 0), sample(10, 11)])
        XCTAssertEqual(route.connectsToPrevious, [false, false])
        XCTAssertFalse(route.selection(at: 0.5)!.hasLocation)
        XCTAssertTrue(route.selection(at: 1)!.hasLocation)
    }

    @objc func testPauseBreaksRouteEvenWhenGapIsShort() {
        let pause = DateInterval(start: Date(timeIntervalSince1970: 0.4), end: Date(timeIntervalSince1970: 0.6))
        let route = timeline([sample(0, 0), sample(1, 1)], pauses: [pause])
        XCTAssertEqual(route.connectsToPrevious, [false, false])
        XCTAssertFalse(route.selection(at: 0.5)!.hasLocation)
    }

    @objc func testShortRejectedFixGapIsBridged() {
        let route = timeline([sample(0, 0), sample(1, 1, accuracy: 50), sample(2, 2)])
        XCTAssertEqual(route.points.count, 2)
        XCTAssertEqual(route.connectsToPrevious, [false, true])
        XCTAssertTrue(route.selection(at: 0.5)!.hasLocation)
        XCTAssertEqual(route.selection(at: 0.5)!.point.longitude, sample(1, 0).longitude, accuracy: 1e-10)
    }

    @objc func testInvalidCoordinatesAndDuplicateTimestampsAreSafe() {
        let invalid = HeatmapSample(latitude: .nan, longitude: 2,
                                    timestamp: Date(timeIntervalSince1970: 1), horizontalAccuracy: 5)
        let route = timeline([sample(2, 2), sample(0, 0), invalid, sample(2, 2)])
        XCTAssertEqual(route.points.count, 2)
        XCTAssertEqual(route.points.first?.timestamp, Date(timeIntervalSince1970: 0))
        XCTAssertEqual(route.points.last?.timestamp, Date(timeIntervalSince1970: 2))
    }

    @objc func testLegacyRouteKeepsEquatorAndUsesProgressWithoutFakeTimestamps() {
        let route = RouteTimeline(samples: [], fallback: [
            .init(latitude: 0, longitude: 0, timestamp: nil),
            .init(latitude: 0, longitude: 0.0001, timestamp: nil)
        ], pauses: [])
        XCTAssertFalse(route.hasTimestamps)
        XCTAssertNil(route.selection(at: 0.5)?.point.timestamp)
        XCTAssertEqual(route.selection(at: 0.5)!.point.longitude, 0.00005, accuracy: 1e-10)
    }

    @objc func testInvalidTimedDataDoesNotFallBackToFabricatedTime() {
        let route = RouteTimeline(samples: [sample(0, 0, accuracy: -1)], fallback: [
            .init(latitude: 41, longitude: 2, timestamp: nil)
        ], pauses: [])
        XCTAssertTrue(route.points.isEmpty)
    }

    @objc func testBackwardsScrubbingDoesNotDependOnPreviousSelection() {
        let route = timeline([sample(0, 0), sample(10, 1)])
        _ = route.selection(at: 0.9)
        XCTAssertEqual(route.selection(at: 0.1)!.point.longitude, sample(1, 0).longitude, accuracy: 1e-10)
    }

    @objc func testImplausibleJumpIsNotDrawnAsContinuousMovement() {
        let route = timeline([sample(0, 0), sample(1000, 1)])
        XCTAssertEqual(route.connectsToPrevious, [false, false])
        XCTAssertFalse(route.selection(at: 0.5)!.hasLocation)
    }
    @objc func testFilteredCoordinateReportsAccuracyInsteadOfMissingGPS() {
        let route = timeline([sample(0, 0), sample(1, 1, accuracy: 25), sample(2, 11)])
        XCTAssertEqual(route.selection(at: 0.5)?.gapReason, .lowAccuracy)
        XCTAssertTrue(route.selection(at: 1)!.hasLocation)
        XCTAssertNil(route.selection(at: 1)?.gapReason)
    }

    @objc func testGapReasonsDistinguishTimePauseAndJump() {
        XCTAssertEqual(timeline([sample(0, 0), sample(1, 11)]).selection(at: 0.5)?.gapReason, .sampleGap)
        XCTAssertEqual(timeline([sample(0, 0), sample(1000, 1)]).selection(at: 0.5)?.gapReason, .locationJump)
        let pause = DateInterval(start: Date(timeIntervalSince1970: 0.4), end: Date(timeIntervalSince1970: 0.6))
        XCTAssertEqual(timeline([sample(0, 0), sample(1, 1)], pauses: [pause]).selection(at: 0.5)?.gapReason, .paused)
    }

    @objc func testAccuracyAndGapBoundariesStillConnect() {
        let route = timeline([sample(0, 0, accuracy: 20), sample(1, 5, accuracy: 20)])
        XCTAssertTrue(route.selection(at: 0.5)!.hasLocation)
        XCTAssertNil(route.selection(at: 0.5)?.gapReason)
    }

    @objc func testInvalidLocationHasItsOwnReason() {
        let bad = HeatmapSample(latitude: .nan, longitude: 2,
                                timestamp: Date(timeIntervalSince1970: 1), horizontalAccuracy: 5)
        let route = timeline([sample(0, 0), bad, sample(2, 11)])
        XCTAssertEqual(route.selection(at: 0.5)?.gapReason, .invalidLocation)
    }

    @objc func testExactIsolatedFixIsVisibleAndExplicitlyIdentified() {
        let route = timeline([sample(0, 0), sample(10, 11)])
        XCTAssertTrue(route.selection(at: 0)!.hasLocation)
        XCTAssertTrue(route.selection(at: 0)!.isIsolatedFix)
        XCTAssertTrue(route.selection(at: 1)!.isIsolatedFix)
        XCTAssertFalse(route.selection(at: 0.5)!.isIsolatedFix)
        XCTAssertFalse(route.selection(at: 0.5)!.hasLocation)
    }

    @objc func testConnectedFixIsNotMarkedAsIsolated() {
        let route = timeline([sample(0, 0), sample(1, 1), sample(2, 2)])
        for progress in [0.0, 0.5, 1.0] { XCTAssertFalse(route.selection(at: progress)!.isIsolatedFix) }
    }

    @objc func testShortMissingIntervalDrawsAndInterpolatesTheSameRoute() {
        let route = timeline([sample(0, 0), sample(24, 8)])
        XCTAssertEqual(route.connectsToPrevious, [false, true])
        let selection = route.selection(at: 0.5)!
        XCTAssertTrue(selection.hasLocation)
        XCTAssertNil(selection.gapReason)
        XCTAssertFalse(selection.isIsolatedFix)
        XCTAssertEqual(selection.point.longitude, sample(12, 0).longitude, accuracy: 1e-10)
        XCTAssertEqual(selection.point.timestamp, Date(timeIntervalSince1970: 4))
        XCTAssertEqual(route.points.count, 2)
    }

    @objc func testBridgeTimeAndDistanceLimits() {
        XCTAssertTrue(timeline([sample(0, 0), sample(29.99, 10)]).selection(at: 0.5)!.hasLocation)
        XCTAssertFalse(timeline([sample(0, 0), sample(20, 10.01)]).selection(at: 0.5)!.hasLocation)
        XCTAssertFalse(timeline([sample(0, 0), sample(30.01, 6)]).selection(at: 0.5)!.hasLocation)
    }

    @objc func testRejectedFixDoesNotHideAnImplausibleJump() {
        let route = timeline([sample(0, 0), sample(1, 0.5, accuracy: 40), sample(29, 1)])
        XCTAssertFalse(route.selection(at: 0.5)!.hasLocation)
        XCTAssertEqual(route.selection(at: 0.5)?.gapReason, .locationJump)
    }

    @objc func testShortInvalidFixGapUsesValidEndpointsOnly() {
        let bad = HeatmapSample(latitude: .nan, longitude: 2,
                                timestamp: Date(timeIntervalSince1970: 1), horizontalAccuracy: 5)
        let route = timeline([sample(0, 0), bad, sample(4, 2)])
        XCTAssertEqual(route.points.count, 2)
        XCTAssertTrue(route.selection(at: 0.5)!.hasLocation)
        XCTAssertEqual(route.selection(at: 0.5)!.point.longitude, sample(2, 0).longitude, accuracy: 1e-10)
    }

    @objc func testFilteredFixCannotBridgePause() {
        let pause = DateInterval(start: Date(timeIntervalSince1970: 0.5), end: Date(timeIntervalSince1970: 1.5))
        let route = timeline([sample(0, 0), sample(1, 1, accuracy: 40), sample(2, 2)], pauses: [pause])
        XCTAssertFalse(route.selection(at: 0.5)!.hasLocation)
        XCTAssertEqual(route.selection(at: 0.5)?.gapReason, .paused)
    }

    @objc func testPointerKeepsLastValidPositionAcrossLongAndRejectedGaps() {
        for samples in [
            [sample(0, 0), sample(10, 20)],
            [sample(0, 0), sample(1000, 1)],
            [sample(0, 0), sample(1, 1, accuracy: 40), sample(10, 20)]
        ] {
            let route = timeline(samples)
            for progress in [0.1, 0.9, 0.2] {
                let selection = route.selection(at: progress)!
                XCTAssertEqual(selection.point.longitude, route.points.first!.longitude)
                XCTAssertNotNil(selection.point.timestamp)
            }
            XCTAssertEqual(route.selection(at: 1)?.point, route.points.last)
        }
    }

    @objc func testPointerStaysAtLastRecordedPositionDuringPause() {
        let pause = DateInterval(start: Date(timeIntervalSince1970: 1), end: Date(timeIntervalSince1970: 9))
        let route = timeline([sample(0, 0), sample(10, 10)], pauses: [pause])
        XCTAssertEqual(route.selection(at: 0.5)?.point.longitude, route.points.first?.longitude)
        XCTAssertEqual(route.selection(at: 0.5)?.point.timestamp, Date(timeIntervalSince1970: 5))
        XCTAssertEqual(route.selection(at: 1)?.point, route.points.last)
    }

}

@main
struct RouteTimelineTestRunner {
    static func main() {
        let suite = RouteTimelineTests.defaultTestSuite
        precondition(suite.testCaseCount == 25)
        suite.run()
        exit(suite.testRun?.hasSucceeded == true ? 0 : 1)
    }
}
