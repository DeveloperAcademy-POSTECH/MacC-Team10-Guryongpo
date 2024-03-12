//
//  GameProgressView.swift
//  SoccerBeat Watch App
//
//  Created by Gucci on 10/22/23.
//

import SwiftUI

struct GameProgressView: View {
    @EnvironmentObject var matricsIndicator: MatricsIndicator
    @EnvironmentObject var workoutManager: WorkoutManager
    @State private var isSprintSheet = false
    private var isGamePaused: Bool { workoutManager.session?.state == .paused }
    private var whenTheGameStarted: Date { workoutManager.builder?.startDate ?? Date() }
    private var distanceKM: String {
        matricsIndicator.isDistanceActive
        ? (matricsIndicator.distanceMeter / 1000).rounded(at: 2)
        : "--'--"
    }
    
    private var distanceUnit: String { matricsIndicator.isDistanceActive ? "KM" : "" }
    
    // MARK: - Body
    var body: some View {
        let timelineSchedule = ProgressTimelineSchedule(from: whenTheGameStarted,
                                                        isPaused: isGamePaused)
        return TimelineView(timelineSchedule) { context in
            VStack(alignment: .center) {
                Spacer()
                // MARK: - 경기 시간
                VStack {
                    let elapsedTime = workoutManager.builder?.elapsedTime(at: context.date) ?? 0
                    ElapsedTimeView(elapsedSec: elapsedTime)
                }
                
                Spacer()
                
                HStack {
                    // MARK: - 뛴 거리
                    VStack {
                        HStack {
                            Spacer()
                            Text("뛴 거리")
                                .font(.distanceTimeText)
                                .foregroundStyle(.ongoingText)
                        }
                        
                        HStack(alignment: .bottom) {
                            Spacer()
                            
                            Text(distanceKM)
                                .font(.distanceTimeNumber)
                                .foregroundStyle(.ongoingNumber)
                            Text(distanceUnit)
                                .font(.scaleText)
                                .foregroundStyle(.ongoingNumber)
                        }
                    }
                    
                    Spacer()
                    
                    // MARK: - 스프린트
                    VStack(alignment: .trailing) {
                        HStack {
                            Spacer()
                            Text("스프린트")
                                .font(.distanceTimeText)
                                .foregroundStyle(.ongoingText)
                        }
                        
                        HStack(alignment: .bottom) {
                            Spacer()
                            Text("\(matricsIndicator.sprintCount)")
                                .font(.distanceTimeNumber)
                                .foregroundStyle(.ongoingNumber)
                            Text("TIMES")
                                .font(.scaleText)
                                .foregroundStyle(.ongoingNumber)
                        }
                        
                    }
                }
                Spacer()
                // Sprint Gauge bar
                SprintView()
                Spacer()
            }
            .padding(.horizontal)
            .onChange(of: matricsIndicator.isSprint) { isSprint in
                if isSprint == false {
                    self.isSprintSheet.toggle()
                }
            }
            .fullScreenCover(isPresented: $isSprintSheet) {
                // 1 m/s = 3.6 km/h
                let sprintSpeedKPH = (matricsIndicator.recentSprintSpeedMPS * 3.6).rounded(at: 1)
                let unit = "km/h"
                SprintSheetView(speedKPH: sprintSpeedKPH + unit)
            }
        }
    }
}

#Preview {
    GameProgressView()
        .environmentObject(DIContianer.makeWorkoutManager())
        .environmentObject(DIContianer.makeMatricsIndicator())
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
