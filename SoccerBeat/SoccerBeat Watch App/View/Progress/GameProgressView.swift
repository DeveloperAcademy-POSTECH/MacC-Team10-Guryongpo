//
//  GameProgressView.swift
//  SoccerBeat Watch App
//
//  Created by Gucci on 10/22/23.
//

import SwiftUI

struct GameProgressView: View {
    
    // MARK: - Data
    @EnvironmentObject var workoutManager: WorkoutManager

    private var zone: HeartRateZone {
        switch workoutManager.heartRate {
        case ...80: return .one
        case ...100: return .two
        case ...120: return .three
        case ...140: return .four
        default: return .five
        }
    }
    @State private var isRunning = false
    
    private var zoneBPMGradient: LinearGradient {
        switch zone {
        case .one:
            return .zone1Bpm
        case .two:
            return .zone2Bpm
        case .three:
            return .zone3Bpm
        case .four:
            return .zone4Bpm
        case .five:
            return .zone5Bpm
        }
    }
    
    private var currentZoneBarGradient: LinearGradient {
        switch zone {
        case .one:
            return .zone1CurrentZoneBar
        case .two:
            return .zone2CurrentZoneBar
        case .three:
            return .zone3CurrentZoneBar
        case .four:
            return .zone4CurrentZoneBar
        case .five:
            return .zone5CurrentZoneBar
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        TimelineView(ProgressTimelineSchedule(from: workoutManager.builder?.startDate ?? Date(),
                                              isPaused: workoutManager.session?.state == .paused)) { context in
            VStack {
                // Zone Bar
                zoneBar
                
                // Heart Rate
//                Text(workoutManager.heartRate.formatted(.number.precision(.fractionLength(0))) + " bpm")
                BPMTextView(isRunning: $isRunning,
                            textGradient: zoneBPMGradient)
                
                // Game Ongoing Information
                HStack(spacing: 30) {
                    VStack {
                        Text(Measurement(value: workoutManager.distance, unit: UnitLength.meters).formatted(.measurement(width: .abbreviated, usage: .road)))
                            .font(.caption.bold().italic())
                            .foregroundStyle(.ongoingNumber)
                        Text("뛴 거리")
                            .foregroundStyle(.ongoingText)
                    }
                    VStack {
                        ElapsedTimeView(elapsedTime: workoutManager.builder?.elapsedTime(at: context.date) ?? 0, showSubseconds: context.cadence == .live)
                            .foregroundStyle(.ongoingNumber)
                            .font(.caption.bold().italic())
                        Text("경기 시간")
                            .foregroundStyle(.ongoingText)
                    }
                }
                
                // Sprint Count Gague
                SprintStatusView(accentGradient: isRunning ? zoneBPMGradient : LinearGradient.stopBpm,
                                 sprintableCount: 5,
                                 restSprint: 4)
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    GameProgressView()
}

// MARK: - Zone Bar

extension GameProgressView {
    @ViewBuilder
    private var zoneBar: some View {
        let circleHeight = CGFloat(16.0)
        let currentZoneWidth = CGFloat(51.0)
        
        HStack {
            ForEach(1...5, id: \.self) { index in
                if zone.rawValue == index {
                    currentZone
                        .frame(width: currentZoneWidth, height: circleHeight)
                } else {
                    Circle()
                        .frame(width: circleHeight, height: circleHeight)
                        .foregroundStyle(.inactiveZone)
                }
            }
        }
    }
    
    @ViewBuilder
    private var currentZone: some View {
        let circleHeight = CGFloat(16.0)
        let strokeWidth = CGFloat(0.6)
        let roundedRectangle = RoundedRectangle(cornerRadius: circleHeight / 2)
        let text = Text(zone.text)
            .font(.system(size: 12))
            .foregroundStyle(.currentZoneText)
        
        if #available(watchOS 10.0, *) {
            roundedRectangle
                .stroke(.currentZoneStroke, lineWidth: strokeWidth)
                .fill(isRunning ? currentZoneBarGradient : LinearGradient.stopCurrentZoneBar)
                .overlay {
                    text
                }
        } else { // current watch version(9.0)
            roundedRectangle
                .strokeBorder(.currentZoneStroke, lineWidth: strokeWidth)
                .background(
                    roundedRectangle.foregroundStyle(isRunning ? currentZoneBarGradient : .stopCurrentZoneBar)
                )
                .overlay {
                    text
                }
        }
    }
}

private struct ProgressTimelineSchedule: TimelineSchedule {
    var startDate: Date
    var isPaused: Bool

    init(from startDate: Date, isPaused: Bool) {
        self.startDate = startDate
        self.isPaused = isPaused
    }

    func entries(from startDate: Date, mode: TimelineScheduleMode) -> AnyIterator<Date> {
        var baseSchedule = PeriodicTimelineSchedule(from: self.startDate,
                                                    by: (mode == .lowFrequency ? 1.0 : 1.0 / 30.0))
            .entries(from: startDate, mode: mode)
        
        return AnyIterator<Date> {
            guard !isPaused else { return nil }
            return baseSchedule.next()
        }
    }
}
