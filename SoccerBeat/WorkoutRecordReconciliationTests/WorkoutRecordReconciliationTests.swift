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


    private func chartRecord(duration: Int = 900, speed: Double = 1, heartRate: Int? = nil, sprints: Int = 0) -> WorkoutData {
        var result = record(distance: Double(duration) * speed / 1000, sprint: sprints, time: "\(duration / 60) : \(duration % 60)")
        let start = Date(timeIntervalSince1970: 1_000_000)
        result.startDate = start
        result.endDate = start.addingTimeInterval(Double(duration))
        result.recordedDuration = Double(duration)
        result.speedSamples = (0...duration).map {
            WorkoutSpeedSample(timestamp: start.addingTimeInterval(Double($0)), speed: speed,
                               speedAccuracy: 0.2, horizontalAccuracy: 5)
        }
        if let heartRate {
            result.heartRates = stride(from: 0, through: duration, by: 5).map { _ in heartRate }
            result.heartRateDates = stride(from: 0, through: duration, by: 5).map { start.addingTimeInterval(Double($0)) }
            result.heartRateReferenceMaximum = 200
        }
        return result
    }

    @objc func testMinimumAndMaximumFillReachThirtyAndOneHundredPercent() {
        XCTAssertEqual(DataConverter.displayLevels(Array(repeating: 0, count: 6)), Array(repeating: 1.5, count: 6))
        XCTAssertEqual(DataConverter.displayLevels(Array(repeating: 100, count: 6)), Array(repeating: 5, count: 6))
    }

    @objc func testUnknownAxesHaveVisibleDefaultAndCappedReference() {
        XCTAssertEqual(DataConverter.displayLevels([]), Array(repeating: 3.25, count: 6))
        let values = DataConverter.displayLevels([100, nil, nil, nil, nil, nil])
        XCTAssertEqual(values[0], 5)
        XCTAssertEqual(values[1], 3.95, accuracy: 0.000001)
    }

    @objc func testActivityUsesDistancePerMinuteInsteadOfTotalDistance() {
        let short = record(distance: 0.6, time: "10 : 0")
        let long = record(distance: 1.2, time: "20 : 0")
        XCTAssertEqual(DataConverter.measuredScores(short)[1]!, 73.75, accuracy: 0.000001)
        XCTAssertEqual(DataConverter.measuredScores(short)[1], DataConverter.measuredScores(long)[1])
    }

    @objc func testAxisOrderUsesUserRequestedMapping() {
        let scores = DataConverter.measuredScores(chartRecord(speed: 8, heartRate: 180))
        for index in 0...4 { XCTAssertEqual(scores[index]!, 100, accuracy: 0.000001) }
        XCTAssertLessThan(scores[5]!, 70) // One continuous sprint is not repeated sprints.
    }

    @objc func testPowerNeverChangesChart() {
        var original = chartRecord()
        let before = DataConverter.toLevels(original)
        original.hasPowerData = true
        let powered = record(power: 10000)
        XCTAssertEqual(DataConverter.toLevels(record()), DataConverter.toLevels(powered))
        XCTAssertEqual(before, DataConverter.toLevels(original))
    }

    @objc func testSpeedUsesContinuousThreeSecondAverage() {
        let scores = DataConverter.measuredScores(chartRecord(speed: 5))
        XCTAssertEqual(scores[0]!, 76, accuracy: 0.000001)
    }

    @objc func testTooShortSpeedRunIsReference() {
        XCTAssertNil(DataConverter.measuredScores(chartRecord(duration: 2, speed: 5))[0])
    }

    @objc func testGPSJumpCannotInflateSpeed() {
        var workout = chartRecord(duration: 60, speed: 1.2)
        let date = workout.speedSamples[20].timestamp
        workout.speedSamples[20] = WorkoutSpeedSample(timestamp: date, speed: 30, speedAccuracy: 0.2, horizontalAccuracy: 5)
        XCTAssertEqual(DataConverter.measuredScores(workout)[0]!, 17.28, accuracy: 0.000001)
    }

    @objc func testDuplicateSpeedSampleCannotInjectSpike() {
        var workout = chartRecord(duration: 60, speed: 1.2)
        workout.speedSamples.append(WorkoutSpeedSample(timestamp: workout.speedSamples[20].timestamp,
                                                      speed: 100, speedAccuracy: 0.2, horizontalAccuracy: 5))
        XCTAssertEqual(DataConverter.measuredScores(workout)[0]!, 17.28, accuracy: 0.000001)
    }

    @objc func testInsufficientCoverageDoesNotBecomeZeroHighSpeedOrEndurance() {
        var workout = chartRecord()
        workout.speedSamples = Array(workout.speedSamples.prefix(400))
        let scores = DataConverter.measuredScores(workout)
        XCTAssertNotNil(scores[0])
        XCTAssertNil(scores[3]); XCTAssertNil(scores[4]); XCTAssertNil(scores[5])
    }

    @objc func testMeasuredStationaryRecordStaysAtMinimumShape() {
        let workout = chartRecord(speed: 0)
        let scores = DataConverter.measuredScores(workout)
        XCTAssertEqual(scores[0], 0); XCTAssertEqual(scores[1], 0)
        XCTAssertEqual(scores[3], 0); XCTAssertEqual(scores[5], 0)
        XCTAssertEqual(DataConverter.toLevels(workout), Array(repeating: 1.5, count: 6))
    }

    @objc func testHighSpeedThresholdCountsValidTime() {
        XCTAssertEqual(DataConverter.measuredScores(chartRecord(speed: 4))[3], 100)
        XCTAssertEqual(DataConverter.measuredScores(chartRecord(speed: 3))[3], 0)
    }

    @objc func testSprintRateRequiresTenMinutes() {
        XCTAssertNil(DataConverter.measuredScores(chartRecord(duration: 599, speed: 6))[5])
        XCTAssertEqual(DataConverter.measuredScores(chartRecord(duration: 600, speed: 6, sprints: 1))[5]!, 70, accuracy: 0.000001)
    }

    @objc func testEnduranceRequiresFifteenMinutesAndRealInitialActivity() {
        XCTAssertNil(DataConverter.measuredScores(chartRecord(duration: 899))[4])
        XCTAssertNil(DataConverter.measuredScores(chartRecord(speed: 0.1))[4])
        XCTAssertEqual(DataConverter.measuredScores(chartRecord())[4], 100)
    }

    @objc func testEnduranceComparesFirstAndLastThirds() {
        var workout = chartRecord()
        for index in 600..<workout.speedSamples.count {
            let sample = workout.speedSamples[index]
            workout.speedSamples[index] = WorkoutSpeedSample(timestamp: sample.timestamp, speed: 0.5,
                                                            speedAccuracy: 0.2, horizontalAccuracy: 5)
        }
        XCTAssertEqual(DataConverter.measuredScores(workout)[4]!, 40, accuracy: 0.000001)
    }

    @objc func testPausesBreakThreeSecondRuns() {
        var workout = chartRecord(duration: 6, speed: 5)
        let start = workout.startDate!
        workout.heatmapPausedIntervals = [DateInterval(start: start.addingTimeInterval(2), end: start.addingTimeInterval(4))]
        workout.recordedDuration = 4
        XCTAssertNil(DataConverter.measuredScores(workout)[0])
    }

    @objc func testHeartLoadUsesRecordedReferenceAndTimeWeightedSamples() {
        let workout = chartRecord(heartRate: 130)
        XCTAssertEqual(DataConverter.measuredScores(workout)[2]!, 70, accuracy: 0.000001)
        var changedPeak = workout
        changedPeak.heartRate["max"] = 240
        XCTAssertEqual(DataConverter.measuredScores(workout)[2], DataConverter.measuredScores(changedPeak)[2])
    }

    @objc func testHeartLoadNeedsReferenceAndCoverage() {
        var workout = chartRecord(heartRate: 130)
        workout.heartRateReferenceMaximum = nil
        XCTAssertNil(DataConverter.measuredScores(workout)[2])
        workout.heartRateReferenceMaximum = 200
        workout.heartRateDates = Array(workout.heartRateDates.prefix(10))
        workout.heartRates = Array(workout.heartRates.prefix(10))
        XCTAssertNil(DataConverter.measuredScores(workout)[2])
    }

    @objc func testInvalidHeartSamplesCannotBridgeMissingIntervals() {
        var workout = chartRecord(heartRate: 130)
        workout.heartRates = workout.heartRates.enumerated().map { $0.offset % 2 == 0 ? 130 : 0 }
        XCTAssertNil(DataConverter.measuredScores(workout)[2])
    }

    @objc func testAverageScoresExcludeReferencesAndAverageScoresNotRawMetrics() {
        let records = [record(distance: 1, time: "10 : 0"), record(distance: 0, time: "10 : 0")]
        let average = WorkoutRecordReconciliation.average(of: records)
        XCTAssertEqual(average.fieldChartScores[1], 50)
        XCTAssertNil(average.fieldChartScores[0])
        XCTAssertEqual(DataConverter.toLevels(average)[1], 3.25)
        XCTAssertEqual(DataConverter.maximumScores(records)[1], 100)
    }

    @objc func testLegacyMetadataStillShowsChartWithoutInventingSpeedOrHeartLoad() {
        let workout = record()
        let scores = DataConverter.measuredScores(workout)
        XCTAssertNil(scores[0]); XCTAssertNil(scores[2])
        XCTAssertTrue(DataConverter.toLevels(workout).allSatisfy { (1.5...5).contains($0) })
    }

    @objc func testFailedRefreshPreservesNewChartInputs() {
        let previous = chartRecord(heartRate: 130)
        var incoming = record(locations: 0)
        incoming.id = previous.id
        let merged = incoming.preservingAvailableData(from: previous)
        XCTAssertEqual(merged.speedSamples, previous.speedSamples)
        XCTAssertEqual(merged.recordedDuration, previous.recordedDuration)
        XCTAssertEqual(merged.heartRateReferenceMaximum, previous.heartRateReferenceMaximum)
    }

    @objc func testInvalidAndMissingRecordsAlwaysHaveFiniteVisibleShape() {
        let bad = record(distance: .nan, speed: .infinity, time: "--")
        XCTAssertEqual(DataConverter.toLevels(bad), Array(repeating: 3.25, count: 6))
        let missing = DataConverter.displayLevels([.nan, .infinity, nil])
        XCTAssertTrue(missing.allSatisfy { $0.isFinite && (1.5...5).contains($0) })
    }

    @objc func testIrregularHeartSamplesAreWeightedByElapsedTime() {
        var workout = chartRecord(duration: 11)
        let start = workout.startDate!
        workout.heartRateDates = [0.0, 1, 11].map { start.addingTimeInterval($0) }
        workout.heartRates = [100, 100, 200]
        workout.heartRateReferenceMaximum = 200
        let ratio = (100.0 + 150.0 * 10) / 11 / 200
        XCTAssertEqual(DataConverter.measuredScores(workout)[2]!, 70 + (ratio - 0.65) / 0.15 * 15, accuracy: 0.000001)
    }

    @objc func testOverlappingPausesAreSubtractedOnce() {
        var workout = chartRecord(duration: 1320, heartRate: 130)
        let start = workout.startDate!
        workout.recordedDuration = 900
        workout.heatmapPausedIntervals = [DateInterval(start: start.addingTimeInterval(300), end: start.addingTimeInterval(600)),
                                         DateInterval(start: start.addingTimeInterval(450), end: start.addingTimeInterval(720))]
        let scores = DataConverter.measuredScores(workout)
        XCTAssertEqual(scores[2]!, 70, accuracy: 0.000001)
        XCTAssertEqual(scores[4]!, 100, accuracy: 0.000001)
    }

    @objc func testAllSixMeasuredGoalsCanReachTheOuterBoundary() {
        var workout = chartRecord(speed: 8, heartRate: 180, sprints: 5)
        workout.speedSamples = workout.speedSamples.enumerated().map { index, sample in
            WorkoutSpeedSample(timestamp: sample.timestamp, speed: index % 60 < 3 ? 4 : 8,
                               speedAccuracy: 0.2, horizontalAccuracy: 5)
        }
        XCTAssertEqual(DataConverter.measuredScores(workout), Array(repeating: 100, count: 6))
        XCTAssertEqual(DataConverter.toLevels(workout), Array(repeating: 5, count: 6))
    }

    @objc func testSprintAxisUsesSavedReportCountRatherThanInventingNewEvents() {
        let noSprints = chartRecord(speed: 8, sprints: 0)
        XCTAssertEqual(DataConverter.measuredScores(noSprints)[5], 0)
        var missing = noSprints
        missing.unavailableMetrics.insert(.sprint)
        XCTAssertNil(DataConverter.measuredScores(missing)[5])
    }

}

@main
struct WorkoutRecordReconciliationTestRunner {
    static func main() {
        let suite = WorkoutRecordReconciliationTests.defaultTestSuite
        precondition(suite.testCaseCount == 53)
        suite.run()
        exit(suite.testRun?.hasSucceeded == true ? 0 : 1)
    }
}
