//
//  AnalyticsView.swift
//  SoccerBeat
//
//  Created by jose Yun on 10/22/23.
//

import SwiftUI

enum ActivityEnum: CaseIterable {
    case distance
    case sprint
    case speed
    case heartrate
}

struct AnalyticsView: View {
    @EnvironmentObject var healthInteracter: HealthInteractor
    @State private var recent9Games = [WorkoutData]()
    @State private var recent4Games = [WorkoutData]()
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("최근 경기 분석")
                Spacer()
            }
            .padding(.leading)
            .font(.custom("NotoSansDisplay-BlackItalic", size: 24))
            
            VStack(spacing: 15) {
                HStack {
                    VStack(alignment: .leading) {
                        ForEach(ActivityEnum.allCases, id: \.self) { activityType in
                            NavigationLink {
                                switch activityType {
                                case .distance: DistanceChartView(workouts: recent9Games)
                                case .heartrate: BPMChartView(workouts: recent9Games)
                                case .speed: SpeedChartView(workouts: recent9Games)
                                case .sprint: SprintChartView(workouts: recent9Games)
                                }
                            } label: {
                                ActivityComponent(userWorkouts: recent4Games, activityType: activityType)
                            }
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
        .onReceive(healthInteracter.fetchSuccess) {
            Task {
                recent9Games = healthInteracter.readRecentMatches(for: 9)
                recent4Games = healthInteracter.readRecentMatches(for: 4)
            }
        }
    }
}

struct ActivityComponent: View {
    let userWorkouts: [WorkoutData]?
    
    var activityType: ActivityEnum
    
    private var title: String {
        switch activityType {
        case .distance:
            return "활동량 (MF)"
        case .sprint:
            return "스프린트 (FW)"
        case .speed:
            return "최고 속도 (DF)"
        case .heartrate:
            return "심박수"
        }
    }
    private var value: String {
        switch activityType {
        case .distance:
            var buffer = "\(userWorkouts?.first?.distance)"
            buffer = buffer.replacingOccurrences(of: "Optional", with: "")
            buffer = buffer.replacingOccurrences(of: "(", with: "")
            buffer = buffer.replacingOccurrences(of: ")", with: "")
            return "\(buffer) Km"
        case .sprint:
            var buffer = "\(userWorkouts?.first?.sprint)"
            buffer = buffer.replacingOccurrences(of: "Optional", with: "")
            buffer = buffer.replacingOccurrences(of: "(", with: "")
            buffer = buffer.replacingOccurrences(of: ")", with: "")
            return "\(buffer) Times"
        case .speed:
            var buffer = "\(userWorkouts?.first?.velocity)"
            buffer = buffer.replacingOccurrences(of: "Optional", with: "")
            buffer = buffer.replacingOccurrences(of: "(", with: "")
            buffer = buffer.replacingOccurrences(of: ")", with: "")
            return "\(buffer) Km/h"
        case .heartrate:
            var buffer = "\(userWorkouts?.first?.heartRate["max"])"
            buffer = buffer.replacingOccurrences(of: "Optional", with: "")
            buffer = buffer.replacingOccurrences(of: "(", with: "")
            buffer = buffer.replacingOccurrences(of: ")", with: "")
            return "\(buffer) Bpm"
        }
    }
    
    private var graphImage: String {
        switch activityType {
        case .distance:
            return "ActivityGraph"
        case .sprint:
            return "SprintGraph"
        case .speed:
            return "MaxSpeedGraph"
        case .heartrate:
            return "HeartrateGraph"
        }
    }
    
    private var valueColor: LinearGradient {
        switch activityType {
        case .distance:
            return .zone2Bpm
        case .sprint:
            return .zone3Bpm
        case .speed:
            return .zone1Bpm
        case .heartrate:
            return .zone4Bpm
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack {
                    Image("Running")
                        .resizable()
                        .frame(width: 22, height: 22)
                    Text(title)
                        .foregroundStyle(.white)
                }
                Text(value)
                    .font(.custom("SFProText-HeavyItalic", size: 32))
                    .foregroundStyle(valueColor)
            }
            Spacer()
            Image(graphImage)
        }
        .padding()
        .padding(.horizontal)
        .overlay {
            LightRectangleView()
        }
    }
}
//
//#Preview {
//    AnalyticsView()
//}
