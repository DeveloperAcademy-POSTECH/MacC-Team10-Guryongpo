import XCTest

final class WorkoutRecoveryTests: XCTestCase {
    private var directory: URL!
    private var store: WorkoutRecoveryStore!

    override func setUpWithError() throws {
        directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        store = WorkoutRecoveryStore(directory: directory)
    }

    override func tearDownWithError() throws {
        if FileManager.default.fileExists(atPath: directory.path) { try FileManager.default.removeItem(at: directory) }
    }

    private func sample(_ time: Double) -> WorkoutRouteSample {
        WorkoutRouteSample(latitude: 41, longitude: 2 + time / 100_000, altitude: 5,
                           horizontalAccuracy: 6, verticalAccuracy: 8, course: 90, speed: 3,
                           speedAccuracy: 0.5, courseAccuracy: 2, timestamp: Date(timeIntervalSince1970: time))
    }

    @objc func testJournalRoundTripKeepsStableWorkoutIdentityAndAmbiguousFinishMarkers() throws {
        var record = WorkoutRecoveryRecord(sessionID: UUID(), startDate: Date(timeIntervalSince1970: 100))
        record.endDate = Date(timeIntervalSince1970: 200)
        record.workoutID = UUID()
        record.finishAttempted = true
        record.routeFinishAttempted = true
        record.metadataStored = true
        record.routePointCount = 2
        record.metadata = try PropertyListSerialization.data(fromPropertyList: ["Distance": 0.11, "Calories": 8,
                                                                              "HasSpeedData": false], format: .binary, options: 0)
        try store.save(record)
        XCTAssertEqual(try store.records(), [record])
        let metadata = try PropertyListSerialization.propertyList(from: store.records()[0].metadata, options: [], format: nil) as! [String: Any]
        XCTAssertEqual(metadata["Distance"] as? Double, 0.11)
        XCTAssertEqual(metadata["Calories"] as? Int, 8)
        XCTAssertEqual(metadata["HasSpeedData"] as? Bool, false)
    }

    @objc func testSeparateAppendsPreserveAllActualSamplesAndAccuracy() throws {
        let id = UUID()
        try store.append([sample(1), sample(2)], to: id)
        try store.append([sample(3)], to: id)
        XCTAssertEqual(try store.samples(for: id), [sample(1), sample(2), sample(3)])
    }

    @objc func testInterruptedLastAppendKeepsPreviouslyCompleteSamples() throws {
        let id = UUID()
        try store.append([sample(1), sample(2)], to: id)
        let file = directory.appendingPathComponent("\(id.uuidString).route")
        let handle = try FileHandle(forWritingTo: file)
        try handle.seekToEnd()
        try handle.write(contentsOf: Data("{\"latitude\":".utf8))
        try handle.close()
        XCTAssertEqual(try store.samples(for: id), [sample(1), sample(2)])
    }

    @objc func testCorruptCompleteAppendIsNotSilentlyTreatedAsEmptyGPS() throws {
        let id = UUID()
        try store.append([sample(1)], to: id)
        let file = directory.appendingPathComponent("\(id.uuidString).route")
        let handle = try FileHandle(forWritingTo: file)
        try handle.seekToEnd()
        try handle.write(contentsOf: Data("not-json\n".utf8))
        try handle.close()
        XCTAssertThrowsError(try store.samples(for: id))
    }

    @objc func testSuccessfulRecoveryCleanupLeavesOtherPendingRecordsUntouched() throws {
        let saved = WorkoutRecoveryRecord(sessionID: UUID(), startDate: .now)
        let pending = WorkoutRecoveryRecord(sessionID: UUID(), startDate: .now)
        try store.save(saved)
        try store.save(pending)
        try store.append([sample(1)], to: saved.sessionID)
        try store.append([sample(2)], to: pending.sessionID)
        try store.complete(saved.sessionID)
        XCTAssertEqual(try store.records(), [pending])
        XCTAssertEqual(try store.samples(for: pending.sessionID), [sample(2)])
    }

    @objc func testUnreadableJournalIsRetainedWithoutHidingOtherPendingSessions() throws {
        let record = WorkoutRecoveryRecord(sessionID: UUID(), startDate: .now)
        try store.save(record)
        let corrupt = directory.appendingPathComponent("interrupted.json")
        try Data("{".utf8).write(to: corrupt)
        XCTAssertEqual(try store.records(), [record])
        XCTAssertTrue(FileManager.default.fileExists(atPath: corrupt.path))
    }

    @objc func testNoGPSIsAnEmptySampleListWithoutInventedCoordinates() throws {
        let record = WorkoutRecoveryRecord(sessionID: UUID(), startDate: .now)
        try store.save(record)
        XCTAssertEqual(try store.samples(for: record.sessionID), [])
        XCTAssertEqual(try store.records(), [record])
    }
    @objc func testPersistedWorkoutFinishIntentCannotBeClaimedAgainAfterRelaunch() throws {
        var record = WorkoutRecoveryRecord(sessionID: UUID(), startDate: .now)
        XCTAssertTrue(try store.claimWorkoutFinish(&record))
        var recovered = try store.records()[0]
        XCTAssertFalse(try store.claimWorkoutFinish(&recovered))
    }

    @objc func testPersistedRouteFinishIntentCannotBeClaimedAgainAfterRelaunch() throws {
        var record = WorkoutRecoveryRecord(sessionID: UUID(), startDate: .now)
        XCTAssertTrue(try store.claimRouteFinish(&record))
        var recovered = try store.records()[0]
        XCTAssertFalse(try store.claimRouteFinish(&recovered))
    }

    @objc func testFailedJournalWriteDoesNotConsumeUnattemptedFinish() throws {
        try Data().write(to: directory)
        var record = WorkoutRecoveryRecord(sessionID: UUID(), startDate: .now)
        XCTAssertThrowsError(try store.claimWorkoutFinish(&record))
        XCTAssertFalse(record.finishAttempted)
        XCTAssertThrowsError(try store.claimRouteFinish(&record))
        XCTAssertFalse(record.routeFinishAttempted)
    }

    @objc func testFailedAppendCanBeReplacedFromTheRetainedActualSamples() throws {
        let id = UUID()
        try store.append([sample(1)], to: id)
        try store.replaceSamples([sample(1), sample(2)], for: id)
        XCTAssertEqual(try store.samples(for: id), [sample(1), sample(2)])
    }

}

@main
struct WorkoutRecoveryTestRunner {
    static func main() {
        let suite = WorkoutRecoveryTests.defaultTestSuite
        precondition(suite.testCaseCount == 11)
        suite.run()
        exit(suite.testRun?.hasSucceeded == true ? 0 : 1)
    }
}
