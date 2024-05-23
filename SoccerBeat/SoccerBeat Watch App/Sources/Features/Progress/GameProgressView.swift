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
    
    private var distanceUnit: String { matricsIndicator.isDistanceActive ? "KM" : ""
    }
    
    // MARK: - Body
    var body: some View {
        GeometryReader { proxy in
            TabView {
                Group {
                    progressView
                        .offset(y: 10)
                    
                    VStack {
                            zoneBar
                                .offset(y: 25)
                        BPMView()
                    }
                }
                .frame(
                    width: proxy.size.width - 10,
                    height: proxy.size.height - 10
                )
                .padding()
            }
            .tabViewStyle(.carousel)
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
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

extension GameProgressView {
    @ViewBuilder
    var progressView: some View {
        let timelineSchedule = ProgressTimelineSchedule(from: whenTheGameStarted,
                                                        isPaused: isGamePaused)
        TimelineView(timelineSchedule) { context in
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
                // MARK: - Sprint Gauge bar
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

extension GameProgressView {
    enum HeartRateZone: Int {
        case one = 1, two, three, four, five
        
        var text: String {
            return "zone".uppercased() + "\(self.rawValue)"
        }
    }
    
    private var zone: HeartRateZone {
        switch matricsIndicator.heartZone {
        case 1: return .one
        case 2: return .two
        case 3: return .three
        case 4: return .four
        default: return .five
        }
    }
    
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
    
    @ViewBuilder
    private var zoneBar: some View {

            let circleHeight = 16.0
            let currentZoneWidth = 50.0
            
            HStack(alignment: .center, spacing: 4) {
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
        let roundedRectangle = RoundedRectangle(cornerRadius: 8)
        let text = Text(zone.text)
            .font(.zoneCapsule)
            .foregroundStyle(.currentZoneText)
        
        if #available(watchOS 10.0, *) {
            roundedRectangle
                .stroke(.currentZoneStroke, lineWidth: strokeWidth)
                .fill(workoutManager.running ? currentZoneBarGradient : LinearGradient.stopCurrentZoneBar)
                .overlay {
                    text
                }
        } else { // current watch version(9.0)
            roundedRectangle
                .strokeBorder(.currentZoneStroke, lineWidth: strokeWidth)
                .background(
                    roundedRectangle.foregroundStyle(workoutManager.running ? currentZoneBarGradient : .stopCurrentZoneBar)
                )
                .overlay {
                    text
                }
        }
    }
}

#Preview {
    GameProgressView()
        .environmentObject(DIContianer.makeWorkoutManager())
        .environmentObject(DIContianer.makeMatricsIndicator())
}
