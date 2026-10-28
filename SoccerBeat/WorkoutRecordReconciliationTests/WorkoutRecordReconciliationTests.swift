import XCTest
import CoreLocation

final class WorkoutRecordReconciliationTests: XCTestCase {
    private let id = UUID(uuidString: "A9A40914-FFCF-4C2E-A383-8472D925AAAB")!

    private func record(distance: Double = 3, sprint: Int = 2, speed: Double = 20,
                        calories: Int = 100, rates: [Int] = [90, 150],
                        locations: Int = 2, time: String = "10 : 0", power: Double = 0) -> WorkoutData {
        var result = WorkoutData(dataID: 1, date: "2026-10-27T12:00:00Z", time: time,
                                 distance: distance, sprint: sprint, velocity: speed, power: power,
                                 heartRate: ["min": 90, "max": 150], heartRates: rates,
                                 route: (0..<locations).map { CLLocationCoordinate2D(latitude: 41, longitude: 2 + Double($0) * 0.00001) },
                                 center: locations > 0 ? [41, 2] : [], calories: calories, vo2Max: 0)
        result.id = id
        return result
    }

    @objc func testWorkoutMetadataWinsButRouteOnlyKeysSurvive() {
        let merged = WorkoutRecordReconciliation.metadata(workout: ["Distance": 3.0],
                                                          routes: [["Distance": 1.0, "SprintCount": 2]])
        XCTAssertEqual(merged["Distance"] as? Double, 3)
        XCTAssertEqual(merged["SprintCount"] as? Int, 2)
    }

    @objc func testAllRouteMetadataIsMergedInOrder() {
        let merged = WorkoutRecordReconciliation.metadata(workout: [:],
                                                          routes: [["a": 1, "b": 2], ["a": 3, "c": 4]])
        XCTAssertEqual(merged["a"] as? Int, 3)
        XCTAssertEqual(merged["b"] as? Int, 2)
        XCTAssertEqual(merged["c"] as? Int, 4)
    }

    @objc func testHeartRateMetadataRejectsInvalidValuesWithoutFabricatingZeros() {
        XCTAssertEqual(WorkoutRecordReconciliation.heartRates(metadata: "80,wrong,0,-1,nan,90.4,inf, 101 "), [80, 90, 101])
        XCTAssertEqual(WorkoutRecordReconciliation.heartRates(metadata: ""), [])
    }

    @objc func testFailedRefreshPreservesKnownMeasurements() {
        let previous = record()
        var incoming = record(distance: 0, sprint: 0, speed: 0, calories: 0, rates: [], locations: 0)
        incoming.unavailableMetrics = [.distance, .sprint, .maxSpeed, .calories, .heartRate, .minHeartRate, .maxHeartRate]
        incoming.routeAvailability = .failed
        incoming.heartRateAvailability = .failed
        incoming.hasRetrievalFailure = true
        let merged = incoming.preservingAvailableData(from: previous)
        XCTAssertEqual(merged.distance, 3)
        XCTAssertEqual(merged.sprint, 2)
        XCTAssertEqual(merged.velocity, 20)
        XCTAssertEqual(merged.calories, 100)
        XCTAssertEqual(merged.heartRates, [90, 150])
        XCTAssertEqual(merged.route.count, 2)
        XCTAssertTrue(merged.unavailableMetrics.isEmpty)
        XCTAssertTrue(merged.hasRetrievalFailure)
    }

    @objc func testUnknownPreviousMeasurementsAreNotPromotedToKnownZeros() {
        var previous = record(distance: 0, speed: 0)
        previous.unavailableMetrics = [.distance, .maxSpeed]
        let merged = previous.preservingAvailableData(from: previous)
        XCTAssertEqual(merged.unavailableMetrics, [.distance, .maxSpeed])
    }

    @objc func testConfirmedZeroRemainsValidAcrossFailedRefresh() {
        let previous = record(sprint: 0, speed: 0)
        var incoming = record(sprint: 0, speed: 0)
        incoming.unavailableMetrics = [.sprint, .maxSpeed]
        let merged = incoming.preservingAvailableData(from: previous)
        XCTAssertEqual(merged.sprint, 0)
        XCTAssertEqual(merged.velocity, 0)
        XCTAssertFalse(merged.unavailableMetrics.contains(.sprint))
        XCTAssertFalse(merged.unavailableMetrics.contains(.maxSpeed))
    }

    @objc func testValidNewMeasurementsReplacePreviousOnesIncludingZero() {
        let incoming = record(distance: 0, sprint: 0, speed: 0, calories: 0)
        let merged = incoming.preservingAvailableData(from: record())
        XCTAssertEqual(merged.distance, 0)
        XCTAssertEqual(merged.sprint, 0)
        XCTAssertEqual(merged.velocity, 0)
        XCTAssertEqual(merged.calories, 0)
    }

    @objc func testDifferentWorkoutCannotBorrowMeasurements() {
        var incoming = record(rates: [], locations: 0)
        incoming.id = UUID()
        incoming.unavailableMetrics = [.heartRate]
        incoming.routeAvailability = .unavailable
        let merged = incoming.preservingAvailableData(from: record())
        XCTAssertEqual(merged.id, incoming.id)
        XCTAssertEqual(merged.heartRates, [])
        XCTAssertEqual(merged.route.count, 0)
        XCTAssertEqual(merged.routeAvailability, .unavailable)
    }

    @objc func testNoCacheDoesNotInventData() {
        var incoming = record(rates: [], locations: 0)
        incoming.unavailableMetrics = [.heartRate]
        incoming.routeAvailability = .pending
        let merged = incoming.preservingAvailableData(from: nil)
        XCTAssertEqual(merged.route, [])
        XCTAssertEqual(merged.center, [])
        XCTAssertEqual(merged.routeAvailability, .pending)
        XCTAssertTrue(merged.unavailableMetrics.contains(.heartRate))
    }

    @objc func testCachedHeartRateDatesStayAlignedWithCachedRates() {
        var previous = record()
        previous.heartRateDates = [Date(timeIntervalSince1970: 0), Date(timeIntervalSince1970: 5)]
        var incoming = record(rates: [])
        incoming.heartRateAvailability = .failed
        incoming.unavailableMetrics = [.heartRate]
        let merged = incoming.preservingAvailableData(from: previous)
        XCTAssertEqual(merged.heartRateDates, previous.heartRateDates)
        XCTAssertEqual(merged.heartRateDates.count, merged.heartRates.count)
    }

    @objc func testNewActualSamplesReplaceRatesAndDatesTogether() {
        var incoming = record(rates: [100])
        incoming.heartRateDates = [Date(timeIntervalSince1970: 10)]
        let merged = incoming.preservingAvailableData(from: record())
        XCTAssertEqual(merged.heartRates, [100])
        XCTAssertEqual(merged.heartRateDates, incoming.heartRateDates)
    }

    @objc func testLegacyMetadataRatesKeepNoInventedDates() {
        let incoming = record(rates: [100])
        let merged = incoming.preservingAvailableData(from: nil)
        XCTAssertTrue(merged.heartRateDates.isEmpty)
    }

    @objc func testPartialRouteFailureDoesNotTruncatePreviouslyLoadedRoute() {
        var incoming = record(locations: 1)
        incoming.hasRetrievalFailure = true
        let merged = incoming.preservingAvailableData(from: record(locations: 3))
        XCTAssertEqual(merged.route.count, 3)
        XCTAssertTrue(merged.hasRetrievalFailure)
    }

    @objc func testDelayedRouteCanReplacePreviouslyMissingRoute() {
        var previous = record(locations: 0)
        previous.routeAvailability = .pending
        let incoming = record(locations: 3)
        let merged = incoming.preservingAvailableData(from: previous)
        XCTAssertEqual(merged.route.count, 3)
        XCTAssertEqual(merged.routeAvailability, .available)
        XCTAssertEqual(merged.id, id)
    }

    @objc func testMinimumAndMaximumHeartRateAvailabilityIsIndependent() {
        var incoming = record()
        incoming.heartRate = ["min": 0, "max": 160]
        incoming.unavailableMetrics = [.minHeartRate]
        let merged = incoming.preservingAvailableData(from: record())
        XCTAssertEqual(merged.minHeartRate, 90)
        XCTAssertEqual(merged.maxHeartRate, 160)
        XCTAssertTrue(merged.unavailableMetrics.isEmpty)
    }
    @objc func testFailedSampleQueryDoesNotReplaceFullChartWithShortMetadataFallback() {
        var previous = record(rates: [90, 110, 150])
        previous.heartRateDates = [0.0, 1, 2].map(Date.init(timeIntervalSince1970:))
        var incoming = record(rates: [90])
        incoming.hasRetrievalFailure = true
        let merged = incoming.preservingAvailableData(from: previous)
        XCTAssertEqual(merged.heartRates, previous.heartRates)
        XCTAssertEqual(merged.heartRateDates, previous.heartRateDates)
    }

    @objc func testHealthKitDistanceRetainsPrecisionOverLegacyRoundedMetadata() {
        let distance = WorkoutRecordReconciliation.distance(statistics: 0.177, total: 0.17, metadata: 0.1, metadataObserved: nil)
        XCTAssertEqual(distance, 0.177)
    }

    @objc func testPositiveDistanceMetadataSurvivesTemporarilyZeroHealthKitAggregate() {
        XCTAssertEqual(WorkoutRecordReconciliation.distance(statistics: 0, total: nil, metadata: 0.1, metadataObserved: nil), 0.1)
        XCTAssertNil(WorkoutRecordReconciliation.distance(statistics: nil, total: nil, metadata: 0, metadataObserved: nil))
        XCTAssertEqual(WorkoutRecordReconciliation.distance(statistics: nil, total: nil, metadata: 0, metadataObserved: true), 0)
    }

    @objc func testDistanceRejectsFailedMetadataAndRecoversFromMeasuredPositiveTotal() {
        XCTAssertNil(WorkoutRecordReconciliation.distance(statistics: nil, total: nil, metadata: 3, metadataObserved: false))
        XCTAssertEqual(WorkoutRecordReconciliation.distance(statistics: 0, total: 0.177, metadata: 0.1, metadataObserved: nil), 0.177)
        XCTAssertEqual(WorkoutRecordReconciliation.distance(statistics: .nan, total: -1, metadata: 0.1, metadataObserved: nil), 0.1)
    }

    @objc func testSuccessfulPartialSyncDoesNotTruncateKnownRoute() {
        let merged = record(locations: 1).preservingAvailableData(from: record(locations: 3))
        XCTAssertEqual(merged.route.count, 3)
        XCTAssertTrue(merged.hasRetrievalFailure)
    }

    @objc func testSuccessfulPartialSyncPreservesLongerActualDatedHeartRateChart() {
        var previous = record(rates: [90, 110, 150])
        previous.heartRateDates = [0.0, 1, 2].map(Date.init(timeIntervalSince1970:))
        var incoming = record(rates: [90])
        incoming.heartRateDates = [Date(timeIntervalSince1970: 0)]
        let merged = incoming.preservingAvailableData(from: previous)
        XCTAssertEqual(merged.heartRates, previous.heartRates)
        XCTAssertEqual(merged.heartRateDates, previous.heartRateDates)
        XCTAssertTrue(merged.hasRetrievalFailure)
    }

    @objc func testActualDatedSamplesReplaceLongerLegacyMetadataArray() {
        let previous = record(rates: [90, 110, 150])
        var incoming = record(rates: [100])
        incoming.heartRateDates = [Date(timeIntervalSince1970: 10)]
        let merged = incoming.preservingAvailableData(from: previous)
        XCTAssertEqual(merged.heartRates, [100])
        XCTAssertEqual(merged.heartRateDates, incoming.heartRateDates)
    }

    @objc func testAllMeasuredZeroDistanceEvidenceStillDisplaysGenuineZero() {
        XCTAssertEqual(WorkoutRecordReconciliation.distance(statistics: 0, total: 0, metadata: 0, metadataObserved: true), 0)
    }

    @objc func testRepeatedSnapshotProducesSameAverageInsteadOfAccumulating() {
        let records = [record(distance: 2), record(distance: 4)]
        let first = WorkoutRecordReconciliation.average(of: records)
        let second = WorkoutRecordReconciliation.average(of: records)
        XCTAssertEqual(first.totalDistance, 3)
        XCTAssertEqual(second.totalDistance, first.totalDistance)
        XCTAssertEqual(second.maxHeartRate, first.maxHeartRate)
        XCTAssertEqual(second.totalMatchTime, first.totalMatchTime)
    }

    @objc func testUnknownMetricsDoNotCountAsMeasuredZeroInAverage() {
        var unavailable = record(distance: 0, sprint: 0, speed: 0, calories: 0)
        unavailable.unavailableMetrics = [.distance, .sprint, .maxSpeed, .calories]
        let average = WorkoutRecordReconciliation.average(of: [record(), unavailable])
        XCTAssertEqual(average.totalDistance, 3)
        XCTAssertEqual(average.maxVelocity, 20)
        XCTAssertEqual(average.sprintCount, 2)
        XCTAssertEqual(average.calories, 100)
        let zero = WorkoutRecordReconciliation.average(of: [record(sprint: 0), record(sprint: 2)])
        XCTAssertEqual(zero.sprintCount, 1)
    }

    @objc func testEmptySnapshotClearsAverageAndErroredRecordsAreExcluded() {
        let empty = WorkoutRecordReconciliation.average(of: [])
        XCTAssertEqual(empty.totalDistance, 0)
        XCTAssertEqual(empty.maxHeartRate, 0)
        XCTAssertEqual(empty.totalMatchTime, 0)
        var failed = record(distance: 100)
        failed.error = true
        XCTAssertEqual(WorkoutRecordReconciliation.average(of: [record(distance: 2), failed]).totalDistance, 2)
    }

    @objc func testAbilityKeepsExistingThresholdsAndScaleWithoutPower() {
        let levels = DataConverter.toLevels(record())
        let expected = [1.2, 2.25, 1.6875, 0.75, 1.2, 1.8]
        for (actual, value) in zip(levels, expected) { XCTAssertEqual(actual, value, accuracy: 0.000001) }
    }

    @objc func testPowerDoesNotAffectWorkoutOrAverageAbilities() {
        let original = record()
        var powered = record(power: 10000)
        powered.hasPowerData = true
        XCTAssertEqual(DataConverter.toLevels(original), DataConverter.toLevels(powered))
        var average = WorkoutRecordReconciliation.average(of: [original])
        let before = DataConverter.toLevels(average)
        average.maxPower = 10000
        XCTAssertEqual(before, DataConverter.toLevels(average))
    }

    @objc func testPartialAbilityUsesKnownInputsAndRedistributesWeights() {
        var partial = record(sprint: 999, speed: 999)
        partial.unavailableMetrics = [.sprint, .maxSpeed, .minHeartRate, .maxHeartRate]
        let levels = DataConverter.toLevels(partial)
        XCTAssertEqual(levels[0], 2.25, accuracy: 0.000001)
        XCTAssertEqual(levels[1], 1.5, accuracy: 0.000001)
        XCTAssertEqual(levels[2], 1.5, accuracy: 0.000001)
        XCTAssertEqual(levels[3], 1.5, accuracy: 0.000001)
        XCTAssertEqual(levels[4], (3 * 0.15 + 0.2) / 0.35 * 0.75, accuracy: 0.000001)
        XCTAssertEqual(levels[5], 2.25, accuracy: 0.000001)
    }

    @objc func testMeasuredZeroSprintIsDifferentFromUnavailableSprintInAbility() {
        let zero = record(sprint: 0, speed: 25)
        var unknown = zero
        unknown.unavailableMetrics.insert(.sprint)
        XCTAssertLessThan(DataConverter.toLevels(zero)[2], DataConverter.toLevels(unknown)[2])
    }

    @objc func testZeroMinimumHeartRateNeverProducesTopMentalityLevel() {
        var zero = record()
        zero.heartRate["min"] = 0
        var unknown = record()
        unknown.unavailableMetrics.insert(.minHeartRate)
        XCTAssertEqual(DataConverter.toLevels(zero), DataConverter.toLevels(unknown))
    }

    @objc func testNoKnownInputReturnsCenterInsteadOfInventedLevels() {
        var missing = record(time: "0 : 0")
        missing.unavailableMetrics = [.distance, .sprint, .maxSpeed, .minHeartRate, .maxHeartRate]
        XCTAssertEqual(DataConverter.toLevels(missing), Array(repeating: 0, count: 6))
    }

    @objc func testThreeMinutesAloneCanProducePartialAbilityChart() {
        var partial = record(time: "3 : 0")
        partial.unavailableMetrics = [.distance, .sprint, .maxSpeed, .minHeartRate, .maxHeartRate]
        XCTAssertEqual(DataConverter.toLevels(partial), Array(repeating: 0.75, count: 6))
    }

    @objc func testAverageRetainsMissingInputsForSamePartialAbilityPolicy() {
        var partial = record()
        partial.unavailableMetrics = [.sprint, .maxSpeed, .minHeartRate, .maxHeartRate]
        let average = WorkoutRecordReconciliation.average(of: [partial])
        XCTAssertTrue(average.unavailableMetrics.contains(.maxSpeed))
        XCTAssertFalse(average.unavailableMetrics.contains(.distance))
        XCTAssertEqual(DataConverter.toLevels(average), DataConverter.toLevels(partial))
    }

    @objc func testMissingCaloriesOrRouteDoesNotChangeAbility() {
        let original = record()
        var missing = original
        missing.unavailableMetrics = [.calories, .heartRate]
        missing.route = []
        missing.routeAvailability = .unavailable
        XCTAssertEqual(DataConverter.toLevels(original), DataConverter.toLevels(missing))
    }

    @objc func testNonfiniteInputsCannotMakeNonfiniteOrOutOfRangeChart() {
        let invalid = record(distance: .nan, speed: .infinity)
        let levels = DataConverter.toLevels(invalid)
        XCTAssertEqual(levels.count, 6)
        XCTAssertTrue(levels.allSatisfy { $0.isFinite && (0...3.75).contains($0) })
    }

}

@main
struct WorkoutRecordReconciliationTestRunner {
    static func main() {
        let suite = WorkoutRecordReconciliationTests.defaultTestSuite
        precondition(suite.testCaseCount == 36)
        suite.run()
        exit(suite.testRun?.hasSucceeded == true ? 0 : 1)
    }
}
