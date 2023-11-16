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
    let userWorkouts: [WorkoutData]
    
    var activityType: ActivityEnum
    
    private var navigationAssistantTitle: String {
        let seeTotal = " 전체보기"
        switch activityType {
        case .distance:
            return "뛴 거리" + seeTotal
        case .sprint:
            return "스프린트" + seeTotal
        case .speed:
            return "최고 속도" + seeTotal
        case .heartrate:
            return "심박수" + seeTotal
        }
    }
    private var value: String {
        switch activityType {
        case .distance:
            return "\(userWorkouts.last?.distance.rounded(at: 1) ?? "0.0")" + "Km"
        case .sprint:
            return "\(userWorkouts.last?.sprint ?? 0)" + "Times"
        case .speed:
            return "\(userWorkouts.last?.velocity.rounded(at: 1) ?? "0.0")" + "Km/h"
        case .heartrate:
            return "\(userWorkouts.last?.maxHeartRate ?? 0)" + "Bpm"
        }
    }
    
    private var valueColor: Color {
        switch activityType {
        case .distance:
            return .navigationSportyDistanceTitle
        case .sprint:
            return .navigationSportySprintTitle
        case .speed:
            return .navigationSportySpeedTitle
        case .heartrate:
            return .navigationSportyBPMTitle
        }
    }
    
    @ViewBuilder
    private var overview: some View {
        switch activityType {
        case .distance:
            DistanceChartOverview(workouts: userWorkouts)
        case .sprint:
            SprintChartOverview(workouts: userWorkouts)
        case .speed:
            SpeedChartOverview(workouts: userWorkouts)
        case .heartrate:
            BPMChartOverview(workouts: userWorkouts)
                .offset(y: 20)
        }
    }
    
    var body: some View {
        HStack {
            HStack(alignment: .bottom) {
                overview
                    .frame(width: 50, height: 75)
                    .padding(.leading, 8)
                
                Image("Running")
                    .resizable()
                    .frame(width: 22, height: 22)
            }
            
            Spacer()
            
            VStack(alignment: .leading) {
                Text(value)
                    .font(Font.sfProDisplay(size: 32,
                                            weight: .heavyItalic))
                Text(navigationAssistantTitle)
                    .font(Font.notoSans(size: 12, weight: .regular))
            }
            
//            Spacer(minLength: 10)
            
            Image(systemName: "chevron.right")
                .resizable()
                .foregroundStyle(valueColor)
                .frame(width: 14, height: 20)
        }
        .padding(.vertical)
        .padding(.horizontal, 18)
        .overlay {
            LightRectangleView()
        }
    }
}

#Preview {
    ActivityComponent(userWorkouts: fakeWorkoutData,
                      activityType: .distance)
}
