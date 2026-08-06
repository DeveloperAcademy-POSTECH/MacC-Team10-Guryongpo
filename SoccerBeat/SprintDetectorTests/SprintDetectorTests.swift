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
}
