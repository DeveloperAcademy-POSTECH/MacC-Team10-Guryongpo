import XCTest

final class SprintDetectorTests: XCTestCase {
    func testHighSpeedUnderRequiredDurationDoesNotCount() {
        var detector = SprintDetector()
        let start = Date(timeIntervalSinceReferenceDate: 1_000)

        detector.process(timestamp: start, speed: 6.0, speedAccuracy: 0.2, receivedAt: start)
        detector.process(
            timestamp: start.addingTimeInterval(0.49),
            speed: 6.0,
            speedAccuracy: 0.2,
            receivedAt: start.addingTimeInterval(0.49)
        )

        XCTAssertEqual(detector.sprintCount, 0)
        XCTAssertFalse(detector.isSprint)
    }

    func testHighSpeedForRequiredDurationCountsOnce() {
        var detector = SprintDetector()
        let start = Date(timeIntervalSinceReferenceDate: 2_000)

        detector.process(timestamp: start, speed: 6.0, speedAccuracy: 0.2, receivedAt: start)
        detector.process(
            timestamp: start.addingTimeInterval(0.5),
            speed: 6.1,
            speedAccuracy: 0.2,
            receivedAt: start.addingTimeInterval(0.5)
        )

        XCTAssertEqual(detector.sprintCount, 1)
        XCTAssertTrue(detector.isSprint)
    }

    func testSingleSpeedSpikeDoesNotRaiseConfirmedPeaks() {
        var detector = SprintDetector()
        let start = Date(timeIntervalSinceReferenceDate: 2_500)
        detector.process(timestamp: start.addingTimeInterval(-0.5), speed: 6.0,
                         speedAccuracy: 0.2, receivedAt: start.addingTimeInterval(-0.5))

        detector.process(timestamp: start, speed: 6.0, speedAccuracy: 0.2, receivedAt: start)

        let spikeTimestamp = start.addingTimeInterval(0.5)
        detector.process(
            timestamp: spikeTimestamp,
            speed: 15.42,
            speedAccuracy: 0.2,
            receivedAt: spikeTimestamp
        )
        XCTAssertEqual(detector.speedMPS, 0, accuracy: 0.001)
        XCTAssertEqual(detector.maxSpeedMPS, 6.0, accuracy: 0.001)

        let recoveryTimestamp = start.addingTimeInterval(1.0)
        detector.process(
            timestamp: recoveryTimestamp,
            speed: 6.0,
            speedAccuracy: 0.2,
            receivedAt: recoveryTimestamp
        )

        XCTAssertEqual(detector.maxSpeedMPS, 6.0, accuracy: 0.001)
        XCTAssertEqual(detector.recentSprintSpeedMPS, 6.0, accuracy: 0.001)
    }

    func testRepeatedHighSpeedPreservesConfirmedPeak() {
        var detector = SprintDetector()
        let start = Date(timeIntervalSinceReferenceDate: 2_750)

        detector.process(timestamp: start, speed: 9.33, speedAccuracy: 0.2, receivedAt: start)
        detector.process(
            timestamp: start.addingTimeInterval(0.5),
            speed: 9.33,
            speedAccuracy: 0.2,
            receivedAt: start.addingTimeInterval(0.5)
        )

        XCTAssertEqual(detector.maxSpeedMPS, 9.33, accuracy: 0.001)
        XCTAssertEqual(detector.recentSprintSpeedMPS, 9.33, accuracy: 0.001)
    }

    func testBoundaryOscillationDoesNotDuplicateSprint() {
        var detector = SprintDetector()
        let start = Date(timeIntervalSinceReferenceDate: 3_000)

        detector.process(timestamp: start, speed: 6.0, speedAccuracy: 0.2, receivedAt: start)
        detector.process(
            timestamp: start.addingTimeInterval(0.5),
            speed: 6.0,
            speedAccuracy: 0.2,
            receivedAt: start.addingTimeInterval(0.5)
        )

        [5.1, 5.55, 5.01, 5.5].enumerated().forEach { index, speed in
            let timestamp = start.addingTimeInterval(0.75 + Double(index) * 0.25)
            detector.process(
                timestamp: timestamp,
                speed: speed,
                speedAccuracy: 0.2,
                receivedAt: timestamp
            )
        }

        XCTAssertEqual(detector.sprintCount, 1)
        XCTAssertTrue(detector.isSprint)
    }

    func testExitThenReentryAddsSprint() {
        var detector = SprintDetector()
        let start = Date(timeIntervalSinceReferenceDate: 4_000)

        let samples: [(TimeInterval, Double)] = [
            (0, 6.0),
            (0.5, 6.0),
            (0.75, 4.9),
            (1.25, 4.8),
            (1.5, 6.0),
            (2.0, 6.0)
        ]

        samples.forEach { offset, speed in
            let timestamp = start.addingTimeInterval(offset)
            detector.process(
                timestamp: timestamp,
                speed: speed,
                speedAccuracy: 0.2,
                receivedAt: timestamp
            )
        }

        XCTAssertEqual(detector.sprintCount, 2)
        XCTAssertTrue(detector.isSprint)
    }

    func testInvalidStaleAndReverseSamplesAreDiscarded() {
        var detector = SprintDetector()
        let start = Date(timeIntervalSinceReferenceDate: 5_000)

        detector.process(timestamp: start, speed: -1, speedAccuracy: 0.2, receivedAt: start)
        detector.process(
            timestamp: start.addingTimeInterval(0.1),
            speed: 6.0,
            speedAccuracy: -1,
            receivedAt: start.addingTimeInterval(0.1)
        )
        detector.process(
            timestamp: start.addingTimeInterval(0.2),
            speed: 6.0,
            speedAccuracy: 0.2,
            receivedAt: start.addingTimeInterval(5.3)
        )
        detector.process(
            timestamp: start.addingTimeInterval(1.0),
            speed: 4.0,
            speedAccuracy: 0.2,
            receivedAt: start.addingTimeInterval(1.0)
        )
        detector.process(
            timestamp: start.addingTimeInterval(0.5),
            speed: 6.0,
            speedAccuracy: 0.2,
            receivedAt: start.addingTimeInterval(1.1)
        )

        XCTAssertEqual(detector.validSampleCount, 1)
        XCTAssertEqual(detector.discardedSampleCount, 4)
        XCTAssertEqual(detector.sprintCount, 0)
    }

    func testPauseAndResetRemoveCandidateState() {
        let start = Date(timeIntervalSinceReferenceDate: 6_000)
        var pausedDetector = SprintDetector()
        var resetDetector = SprintDetector()

        pausedDetector.process(timestamp: start, speed: 6.0, speedAccuracy: 0.2, receivedAt: start)
        pausedDetector.pause()
        pausedDetector.process(
            timestamp: start.addingTimeInterval(0.5),
            speed: 6.0,
            speedAccuracy: 0.2,
            receivedAt: start.addingTimeInterval(0.5)
        )

        resetDetector.process(timestamp: start, speed: 6.0, speedAccuracy: 0.2, receivedAt: start)
        resetDetector.reset()
        resetDetector.process(
            timestamp: start.addingTimeInterval(0.5),
            speed: 6.0,
            speedAccuracy: 0.2,
            receivedAt: start.addingTimeInterval(0.5)
        )

        XCTAssertEqual(pausedDetector.sprintCount, 0)
        XCTAssertFalse(pausedDetector.isSprint)
        XCTAssertEqual(pausedDetector.maxSpeedMPS, 0)
        XCTAssertEqual(resetDetector.sprintCount, 0)
        XCTAssertFalse(resetDetector.isSprint)
        XCTAssertEqual(resetDetector.maxSpeedMPS, 0)
    }

    func testLongSampleGapCancelsCandidateAndKeepsConfirmedCount() {
        var detector = SprintDetector()
        let start = Date(timeIntervalSinceReferenceDate: 7_000)

        detector.process(timestamp: start, speed: 6.0, speedAccuracy: 0.2, receivedAt: start)

        let afterCandidateGap = start.addingTimeInterval(2.1)
        detector.process(
            timestamp: afterCandidateGap,
            speed: 6.0,
            speedAccuracy: 0.2,
            receivedAt: afterCandidateGap
        )
        XCTAssertEqual(detector.sprintCount, 0)
        XCTAssertEqual(detector.maxSpeedMPS, 0)

        let confirmation = afterCandidateGap.addingTimeInterval(0.5)
        detector.process(
            timestamp: confirmation,
            speed: 6.0,
            speedAccuracy: 0.2,
            receivedAt: confirmation
        )
        XCTAssertEqual(detector.sprintCount, 1)
        XCTAssertEqual(detector.maxSpeedMPS, 6.0, accuracy: 0.001)

        let afterConfirmedGap = confirmation.addingTimeInterval(2.1)
        detector.process(
            timestamp: afterConfirmedGap,
            speed: 6.0,
            speedAccuracy: 0.2,
            receivedAt: afterConfirmedGap
        )
        XCTAssertEqual(detector.sprintCount, 1)
    }
    func testWalkingWithRepeatedImpossibleSpeedsDoesNotInflateMaximum() {
        var detector = SprintDetector()
        let start = Date(timeIntervalSinceReferenceDate: 8_000)
        for (index, speed) in [1.4, 1.5, 93.1 / 3.6, 102.0 / 3.6, 102.0 / 3.6, 1.4, 1.5].enumerated() {
            let time = start.addingTimeInterval(Double(index))
            detector.process(timestamp: time, speed: speed, speedAccuracy: 0.2, receivedAt: time)
        }
        XCTAssertLessThanOrEqual(detector.maxSpeedMPS, 1.5)
        XCTAssertEqual(detector.sprintCount, 0)
        XCTAssertEqual(detector.discardedSampleCount, 3)
    }

    func testSustainedVehicleSpeedIsRejectedRatherThanClamped() {
        var detector = SprintDetector()
        let start = Date(timeIntervalSinceReferenceDate: 9_000)
        for index in 0..<10 {
            let time = start.addingTimeInterval(Double(index))
            detector.process(timestamp: time, speed: 131.15 / 3.6, speedAccuracy: 0.2, receivedAt: time)
        }
        XCTAssertEqual(detector.maxSpeedMPS, 0)
        XCTAssertEqual(detector.sprintCount, 0)
        XCTAssertEqual(detector.validSampleCount, 0)
    }

    func testAutomotiveMotionExcludesEvenHumanRangeVehicleSpeed() {
        var detector = SprintDetector()
        let start = Date(timeIntervalSinceReferenceDate: 10_000)
        for index in 0..<5 {
            let time = start.addingTimeInterval(Double(index))
            detector.process(timestamp: time, speed: 8, speedAccuracy: 0.2,
                             isAutomotive: true, receivedAt: time)
        }
        XCTAssertEqual(detector.maxSpeedMPS, 0)
        XCTAssertEqual(detector.sprintCount, 0)
    }

    func testPoorAccuracyAndNonFiniteValuesAreRejected() {
        var detector = SprintDetector()
        let start = Date(timeIntervalSinceReferenceDate: 11_000)
        detector.process(timestamp: start, speed: .infinity, speedAccuracy: 0.2, receivedAt: start)
        detector.process(timestamp: start, speed: .nan, speedAccuracy: 0.2, receivedAt: start)
        detector.process(timestamp: start, speed: 6, speedAccuracy: .infinity, receivedAt: start)
        detector.process(timestamp: start, speed: 6, speedAccuracy: 4, receivedAt: start)
        detector.process(timestamp: start, speed: 6, speedAccuracy: 0.2, horizontalAccuracy: 50, receivedAt: start)
        XCTAssertEqual(detector.validSampleCount, 0)
        XCTAssertEqual(detector.discardedSampleCount, 5)
    }

    func testConsecutiveSubCapJumpsCannotConfirmEachOther() {
        var detector = SprintDetector()
        let start = Date(timeIntervalSinceReferenceDate: 12_000)
        for (offset, speed) in [(0.0, 1.5), (0.5, 10.0), (1.0, 10.0), (1.5, 1.5)] {
            let time = start.addingTimeInterval(offset)
            detector.process(timestamp: time, speed: speed, speedAccuracy: 0.2, receivedAt: time)
        }
        XCTAssertEqual(detector.maxSpeedMPS, 1.5, accuracy: 0.001)
        XCTAssertEqual(detector.sprintCount, 0)
    }

    func testRejectedFixCannotBridgeSprintEntry() {
        var detector = SprintDetector()
        let start = Date(timeIntervalSinceReferenceDate: 12_500)
        detector.process(timestamp: start, speed: 6, speedAccuracy: 0.2, receivedAt: start)
        let bad = start.addingTimeInterval(0.25)
        detector.process(timestamp: bad, speed: 6, speedAccuracy: 4, receivedAt: bad)
        let next = start.addingTimeInterval(0.5)
        detector.process(timestamp: next, speed: 6, speedAccuracy: 0.2, receivedAt: next)
        XCTAssertEqual(detector.sprintCount, 0)
        XCTAssertEqual(detector.maxSpeedMPS, 0)
    }

    func testAccelerationUsesElapsedSeconds() {
        var detector = SprintDetector()
        let start = Date(timeIntervalSinceReferenceDate: 13_000)
        detector.process(timestamp: start, speed: 2, speedAccuracy: 0.2, receivedAt: start)
        let end = start.addingTimeInterval(0.5)
        detector.process(timestamp: end, speed: 4, speedAccuracy: 0.2, receivedAt: end)
        XCTAssertEqual(detector.maxAccelerationMPS2, 4, accuracy: 0.001)
    }

    func testUnavailableSpeedIsDistinctFromMeasuredZero() {
        var detector = SprintDetector()
        let start = Date(timeIntervalSinceReferenceDate: 14_000)
        XCTAssertNil(detector.currentSpeed(at: start))
        detector.process(timestamp: start, speed: 0, speedAccuracy: 0.2, receivedAt: start)
        XCTAssertEqual(detector.currentSpeed(at: start), 0)
        let invalid = start.addingTimeInterval(1)
        detector.process(timestamp: invalid, speed: -1, speedAccuracy: 0.2, receivedAt: invalid)
        XCTAssertNil(detector.currentSpeed(at: invalid))
    }

    func testRejectedGPSDoesNotDisplayZeroOrEraseRecordedMaximum() {
        var detector = SprintDetector()
        let start = Date(timeIntervalSinceReferenceDate: 15_000)
        for offset in [0.0, 1.0] {
            let date = start.addingTimeInterval(offset)
            detector.process(timestamp: date, speed: 3, speedAccuracy: 0.2, receivedAt: date)
        }
        let bad = start.addingTimeInterval(2)
        detector.process(timestamp: bad, speed: 3, speedAccuracy: 4, receivedAt: bad)
        XCTAssertNil(detector.currentSpeed(at: bad))
        XCTAssertEqual(detector.maxSpeedMPS, 3)
        XCTAssertTrue(detector.hasConfirmedSpeed)
        let recovered = start.addingTimeInterval(3)
        detector.process(timestamp: recovered, speed: 2, speedAccuracy: 0.2, receivedAt: recovered)
        XCTAssertEqual(detector.currentSpeed(at: recovered), 2)
        XCTAssertEqual(detector.maxSpeedMPS, 3)
    }

    func testSilentLocationStreamExpiresEvenWithoutAnotherCallback() {
        var detector = SprintDetector()
        let start = Date(timeIntervalSinceReferenceDate: 16_000)
        detector.process(timestamp: start, speed: 2, speedAccuracy: 0.2, receivedAt: start)
        XCTAssertEqual(detector.currentSpeed(at: start.addingTimeInterval(5)), 2)
        XCTAssertNil(detector.currentSpeed(at: start.addingTimeInterval(5.01)))
        let next = start.addingTimeInterval(8)
        detector.process(timestamp: next, speed: 2.5, speedAccuracy: 0.2, receivedAt: next)
        XCTAssertEqual(detector.currentSpeed(at: next), 2.5)
    }

    func testDelayedDeliveryUsesMeasurementTimeForFreshness() {
        var detector = SprintDetector()
        let start = Date(timeIntervalSinceReferenceDate: 17_000)
        detector.process(timestamp: start, speed: 2, speedAccuracy: 0.2, receivedAt: start.addingTimeInterval(4))
        XCTAssertEqual(detector.currentSpeed(at: start.addingTimeInterval(4)), 2)
        XCTAssertNil(detector.currentSpeed(at: start.addingTimeInterval(5.01)))
    }

    func testOldCallbackAfterRejectedSampleCannotRestartMeasurement() {
        var detector = SprintDetector()
        let start = Date(timeIntervalSinceReferenceDate: 18_000)
        detector.process(timestamp: start, speed: 2, speedAccuracy: 0.2, receivedAt: start)
        let invalid = start.addingTimeInterval(2)
        detector.process(timestamp: invalid, speed: -1, speedAccuracy: -1, receivedAt: invalid)
        detector.process(timestamp: start.addingTimeInterval(1), speed: 2, speedAccuracy: 0.2, receivedAt: invalid)
        XCTAssertNil(detector.currentSpeed(at: invalid))
        XCTAssertEqual(detector.validSampleCount, 1)
        let next = start.addingTimeInterval(3)
        detector.process(timestamp: next, speed: 2, speedAccuracy: 0.2, receivedAt: next)
        XCTAssertEqual(detector.currentSpeed(at: next), 2)
    }

    func testFutureTimestampCannotBlockSubsequentNormalSample() {
        var detector = SprintDetector()
        let start = Date(timeIntervalSinceReferenceDate: 19_000)
        detector.process(timestamp: start.addingTimeInterval(100), speed: 2, speedAccuracy: 0.2, receivedAt: start)
        detector.process(timestamp: start, speed: 2, speedAccuracy: 0.2, receivedAt: start)
        XCTAssertEqual(detector.currentSpeed(at: start), 2)
    }

    func testIsolatedFixesDoNotClaimAConfirmedZeroMaximum() {
        var detector = SprintDetector()
        let start = Date(timeIntervalSinceReferenceDate: 20_000)
        detector.process(timestamp: start, speed: 0, speedAccuracy: 0.2, receivedAt: start)
        let isolated = start.addingTimeInterval(10)
        detector.process(timestamp: isolated, speed: 0, speedAccuracy: 0.2, receivedAt: isolated)
        XCTAssertFalse(detector.hasConfirmedSpeed)
        let paired = isolated.addingTimeInterval(1)
        detector.process(timestamp: paired, speed: 0, speedAccuracy: 0.2, receivedAt: paired)
        XCTAssertTrue(detector.hasConfirmedSpeed)
        XCTAssertEqual(detector.maxSpeedMPS, 0)
        detector.pause()
        XCTAssertNil(detector.currentSpeed(at: paired))
        XCTAssertTrue(detector.hasConfirmedSpeed)
        detector.reset()
        XCTAssertFalse(detector.hasConfirmedSpeed)
    }

}


final class PeakPowerTests: XCTestCase {
    func testMissingMeasurementIsNotZeroWatts() {
        var power = PeakPower()
        power.observe(nil)
        power.observe(.nan)
        power.observe(.infinity)
        power.observe(-1)
        XCTAssertNil(power.watts)
    }

    func testMaximumSurvivesLowerAndMissingSamples() {
        var power = PeakPower()
        for value in [120.0, 300.0, 150.0, 0.0] { power.observe(value) }
        power.observe(nil)
        XCTAssertEqual(power.watts, 300)
    }

    func testResetDoesNotCarryPowerToNextMatch() {
        var power = PeakPower()
        power.observe(300)
        power = PeakPower()
        XCTAssertNil(power.watts)
        power.observe(100)
        XCTAssertEqual(power.watts, 100)
    }

    func testActualZeroIsAValidMeasurement() {
        var power = PeakPower()
        power.observe(0)
        XCTAssertEqual(power.watts, 0)
    }
}
