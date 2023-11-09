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
    
    // MARK: - Body
    
    var body: some View {
        TimelineView(ProgressTimelineSchedule(from: workoutManager.builder?.startDate ?? Date(),
                                              isPaused: workoutManager.session?.state == .paused)) { context in
            VStack(alignment: .leading) {
                // MARK: - 경기 시간
                VStack(alignment: .leading) {
                    Text("경기 시간")
                        .foregroundStyle(.ongoingText)
                        .font(.playTimeText)
                    GeometryReader { geo in
                        ElapsedTimeView(elapsedTime: workoutManager.builder?.elapsedTime(at: context.date) ?? 0)
                            .font(.playTimeNumber)
                            .minimumScaleFactor(0.001)
                            .frame(width: geo.size.width)
                            .foregroundStyle(.playTimeNumber)
                    }
                }
                
                HStack {
                    // MARK: - 뛴 거리
                    VStack(alignment: .leading) {
                        Text("뛴 거리")
                            .font(.distanceTimeText)
                            .foregroundStyle(.ongoingText)
                        
                        let distanceText = String(Measurement(value: workoutManager.distance,
                                                              unit: UnitLength.meters)
                            .formatted(.measurement(width: .abbreviated, usage: .road)))
                        
                        Text(workoutManager.isDistanceActive ? distanceText : "--'--")
                            .font(.distanceTimeNumber)
                            .foregroundStyle(.ongoingNumber)
                    }
                    
                    Spacer()
                    
                    // MARK: - 스프린트
                    VStack(alignment: .leading) {
                        Text("스프린트")
                            .font(.distanceTimeText)
                            .foregroundStyle(.ongoingText)
                        
                        Text("\(workoutManager.sprint) TIMES")
                            .font(.distanceTimeNumber)
                            .foregroundStyle(.ongoingNumber)
                    }
                }
            }
            .padding(.horizontal)
            .fullScreenCover(isPresented: $workoutManager.isInZone5For2Min) {
                AlertView()
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                            workoutManager.isInZone5For2Min = false
                        }
                    }
            }
        }
    }
}

#Preview {
    GameProgressView()
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
