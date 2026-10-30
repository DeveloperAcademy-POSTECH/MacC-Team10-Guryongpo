import XCTest

@MainActor
final class MatricsIndicatorTests: XCTestCase {
    @objc func testFieldChartVersionDoesNotInventPersonalHeartRateReference() {
        let metrics = MatricsIndicator()
        XCTAssertEqual(metrics.getMetadata()["FieldChartVersion"] as? Int, 2)
        XCTAssertNil(metrics.getMetadata()["FieldChartHeartRateReference"])
        metrics.reset()
        XCTAssertNil(metrics.getMetadata()["FieldChartHeartRateReference"])
    }

    @objc func testAbsentMeasurementsAreNotSerializedAsZero() {
        let metrics = MatricsIndicator()
        let metadata = metrics.getMetadata()
        for key in ["Distance", "Calories", "HeartRates", "MinHeartRate", "MaxHeartRate"] {
            XCTAssertNil(metadata[key])
        }
        for key in ["HasDistanceData", "HasCaloriesData", "HasHeartRateData"] {
            XCTAssertEqual(metadata[key] as? Bool, false)
        }
    }

    @objc func testNumericCaloriesDoNotUseStringRoundingOverload() {
        let metrics = MatricsIndicator()
        metrics.updateCalories(8.4)
        XCTAssertEqual(metrics.getMetadata()["Calories"] as? Int, 8)
        XCTAssertEqual(metrics.energy, 8.4)
        XCTAssertTrue(metrics.hasCaloriesData)
    }

    @objc func testDistancePersistencePreservesMeasuredPrecision() {
        let metrics = MatricsIndicator()
        metrics.updateDistance(177.5)
        XCTAssertEqual(metrics.getMetadata()["Distance"] as? Double, 0.1775)
        XCTAssertEqual(metrics.distanceMeter, 177.5)
    }

    @objc func testRealZeroQuantitiesAreAvailable() {
        let metrics = MatricsIndicator()
        metrics.updateDistance(0)
        metrics.updateCalories(0)
        XCTAssertTrue(metrics.hasDistanceData)
        XCTAssertTrue(metrics.hasCaloriesData)
        XCTAssertTrue(metrics.isDistanceActive)
        XCTAssertEqual(metrics.getMetadata()["Calories"] as? Int, 0)
        XCTAssertEqual(metrics.getMetadata()["Distance"] as? Double, 0)
    }

    @objc func testMissingAndInvalidCumulativeSamplesPreserveCollectedValues() {
        let metrics = MatricsIndicator()
        metrics.updateDistance(177.5)
        metrics.updateCalories(8.4)
        for value: Double? in [nil, .nan, .infinity, -1, 0] {
            metrics.updateDistance(value)
            metrics.updateCalories(value)
        }
        XCTAssertEqual(metrics.distanceMeter, 177.5)
        XCTAssertEqual(metrics.energy, 8.4)
        let empty = MatricsIndicator()
        empty.updateDistance(nil)
        empty.updateCalories(.nan)
        XCTAssertFalse(empty.hasDistanceData)
        XCTAssertFalse(empty.hasCaloriesData)
    }

    @objc func testMetadataSurvivesPropertyListRoundTrip() throws {
        let metrics = MatricsIndicator()
        metrics.updateDistance(177.5)
        metrics.updateCalories(8.4)
        metrics.heartRate = 92
        metrics.updatePower(123.45)
        let metadata = metrics.getMetadata()
        XCTAssertTrue(PropertyListSerialization.propertyList(metadata, isValidFor: .binary))
        let data = try PropertyListSerialization.data(fromPropertyList: metadata, format: .binary, options: 0)
        let restored = try XCTUnwrap(PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any])
        XCTAssertEqual(restored["Calories"] as? Int, 8)
        XCTAssertEqual(restored["Distance"] as? Double, 0.1775)
        XCTAssertEqual(restored["Power"] as? Double, 123.45)
        XCTAssertEqual(restored["HeartRates"] as? String, "92")
    }

    @objc func testResetDoesNotRequireBirthDateAndClearsMeasurementAvailability() {
        let metrics = MatricsIndicator()
        metrics.heartRate = 120
        metrics.heartRate = 90
        metrics.heartRate = 0
        XCTAssertEqual(metrics.saveMinHeartRate, 90)
        XCTAssertEqual(metrics.saveMaxHeartRate, 120)
        XCTAssertEqual(metrics.saveHeartRates, [120, 90])
        metrics.updateDistance(177.5)
        metrics.updateCalories(8.4)
        metrics.reset()
        XCTAssertFalse(metrics.hasHeartRateData)
        XCTAssertFalse(metrics.hasDistanceData)
        XCTAssertFalse(metrics.hasCaloriesData)
        XCTAssertTrue(metrics.saveHeartRates.isEmpty)
        XCTAssertNil(metrics.getMetadata()["MinHeartRate"])
    }
}

@main
struct MatricsIndicatorTestRunner {
    @MainActor
    static func main() {
        let suite = MatricsIndicatorTests.defaultTestSuite
        precondition(suite.testCaseCount == 8)
        suite.run()
        exit(suite.testRun?.hasSucceeded == true ? 0 : 1)
    }
}
