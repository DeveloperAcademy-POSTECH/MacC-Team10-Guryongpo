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
        XCTAssertEqual(resetDetector.sprintCount, 0)
        XCTAssertFalse(resetDetector.isSprint)
    }
}
