//
//  FileLoader.swift
//  SoccerBeat
//
//  Created by Gucci on 8/17/24.
//

import Foundation

final class FileLoader {
    static private let sprintLoaded: SprintLoaded?        = load("Sprints.json")
    static private let distanceLoaded: DistanceLoaded?    = load("Distance.json")
    static private let heartRateLoaded: HeartRateLoaded?  = load("HeartRate.json")
    static private let topSpeedLoaded: TopSpeedLoaded?    = load("TopSpeed.json")

    static var sprints: [Sprints] {
        return FileLoader.sprintLoaded?.players ?? []
    }

    static var distance: [DistancePer90min] {
        return FileLoader.distanceLoaded?.players ?? []
    }

    static var heartRate: [HeartRate] {
        return FileLoader.heartRateLoaded?.players ?? []
    }

    static var topSpeed: [TopSpeed] {
        return FileLoader.topSpeedLoaded?.players ?? []
    }
}

func load<T: Codable>(_ fileName: String) -> T? {
    // JSON 파일 경로
    guard let filePath = Bundle.main.path(forResource: fileName, ofType: nil) else { return nil }

    let loadedData: Data

    do {
        loadedData = try Data(contentsOf: URL(fileURLWithPath: filePath))
    } catch {
        NSLog("Error reading JSON file: \(error)")
        return nil
    }

    do {
        return try JSONDecoder().decode(T.self, from: loadedData)
    } catch {
        NSLog("Error decoding JSON file: \(error)")
        return nil
    }
}
