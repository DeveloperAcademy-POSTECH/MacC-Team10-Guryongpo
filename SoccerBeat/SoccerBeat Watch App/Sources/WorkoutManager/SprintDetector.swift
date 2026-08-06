//
//  SprintDetector.swift
//  SoccerBeat Watch App
//

import Foundation

struct SprintDetector {
    private enum State {
        case idle
        case entering(Date)
        case sprinting
        case exiting(Date)
    }

    private static let entrySpeedMPS = 5.56
    private static let entryConfidenceFloorMPS = 5.0
    private static let exitSpeedMPS = 5.0
    private static let requiredDuration: TimeInterval = 0.5
    private static let maximumSampleGap: TimeInterval = 2.0
    private static let maximumSampleAge: TimeInterval = 5.0

    private(set) var isSprint = false
    private(set) var sprintCount = 0
    private(set) var speedMPS = 0.0
    private(set) var maxSpeedMPS = 0.0
    private(set) var recentSprintSpeedMPS = 0.0
    private(set) var validSampleCount = 0
    private(set) var discardedSampleCount = 0

    private var state = State.idle
    private var lastTimestamp: Date?
    private var candidatePeakSpeedMPS = 0.0

    // Apple: https://developer.apple.com/documentation/corelocation/cllocation/speed
    // Apple: https://developer.apple.com/documentation/corelocation/cllocation/speedaccuracy
    mutating func process(
        timestamp: Date,
        speed: Double,
        speedAccuracy: Double,
        receivedAt: Date = .now
    ) {
        let sampleAge = receivedAt.timeIntervalSince(timestamp)
        guard speed >= 0,
              speedAccuracy >= 0,
              sampleAge >= 0,
              sampleAge <= Self.maximumSampleAge else {
            discardedSampleCount += 1
            return
        }

        if let lastTimestamp {
            guard timestamp > lastTimestamp else {
                discardedSampleCount += 1
                return
            }

            if timestamp.timeIntervalSince(lastTimestamp) > Self.maximumSampleGap {
                switch state {
                case .entering:
                    state = .idle
                    candidatePeakSpeedMPS = 0
                case .exiting:
                    state = .sprinting
                case .idle, .sprinting:
                    break
                }
            }
        }

        lastTimestamp = timestamp
        validSampleCount += 1
        speedMPS = speed
        maxSpeedMPS = max(maxSpeedMPS, speed)

        let qualifiesForEntry = speed >= Self.entrySpeedMPS
            && speed - speedAccuracy >= Self.entryConfidenceFloorMPS

        switch state {
        case .idle:
            isSprint = false
            if qualifiesForEntry {
                state = .entering(timestamp)
                candidatePeakSpeedMPS = speed
            }

        case let .entering(startedAt):
            guard qualifiesForEntry else {
                state = .idle
                candidatePeakSpeedMPS = 0
                return
            }

            candidatePeakSpeedMPS = max(candidatePeakSpeedMPS, speed)
            if timestamp.timeIntervalSince(startedAt) >= Self.requiredDuration {
                state = .sprinting
                isSprint = true
                sprintCount += 1
                recentSprintSpeedMPS = candidatePeakSpeedMPS
                candidatePeakSpeedMPS = 0
            }

        case .sprinting:
            recentSprintSpeedMPS = max(recentSprintSpeedMPS, speed)
            if speed < Self.exitSpeedMPS {
                state = .exiting(timestamp)
            }

        case let .exiting(startedAt):
            recentSprintSpeedMPS = max(recentSprintSpeedMPS, speed)
            if speed < Self.exitSpeedMPS {
                if timestamp.timeIntervalSince(startedAt) >= Self.requiredDuration {
                    state = .idle
                    isSprint = false
                }
            } else {
                // 진입·종료 임계값을 분리해 GPS 경계 진동에 따른 중복 카운트를 방지한다.
                state = .sprinting
            }
        }
    }
}
