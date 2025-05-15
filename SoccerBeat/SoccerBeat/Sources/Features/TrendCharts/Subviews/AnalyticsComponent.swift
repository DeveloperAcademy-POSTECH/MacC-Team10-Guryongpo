//
//  AnalyticsComponent.swift
//  SoccerBeat
//
//  Created by Gucci on 11/20/23.
//

import SwiftUI

struct AnalyticsComponent: View {
    
    let workouts: [WorkoutData]
    let activityType: ActivityEnum
    
    private var navigationAssistantTitle: String {
        var content = ""
        switch activityType {
        case .distance:
            content = "최근 뛴 거리"
        case .sprint:
            content = "최근 스프린트"
        case .speed:
            content = "최근 최고 속도"
        }
        return content + " 보기"
    }
    private var lastGameValue: String {
        switch activityType {
        case .distance:
            if let workout = workouts.last {
                if !workout.error {
                    return "\(workout.distance.rounded(at: 1))" + " km"
                } }
            return "-- km"
        case .sprint:
            if let workout = workouts.last {
                if !workout.error {
                    return "\(workout.sprint.formatted())" + " Times"
                } }
            return "-- Times"
        case .speed:
            if let workout = workouts.last {
                if !workout.error {
                    return "\(workout.velocity.rounded(at: 0))" + " km/h"
                } }
            return "-- km/h"
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
        }
    }
    
    @ViewBuilder
    private var overview: some View {
        switch activityType {
        case .distance:
            DistanceChartOverview(workouts: workouts)
        case .sprint:
            SprintChartOverview(workouts: workouts)
        case .speed:
            SpeedChartOverview(workouts: workouts)
        }
    }
    
    var body: some View {
        ZStack {
            LightRectangleView(alpha: 0.15, color: .black, radius: 15.0)
                .frame(height: 90)
            
            HStack {
                HStack(alignment: .bottom) {
                    overview
                        .frame(height: 52)
                        .padding(.leading)
                    Image(systemName: "figure.run")
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(valueColor)
                        .frame(width: 22, height: 22)
                }
                .frame(maxWidth: 86)
                
                VStack(alignment: .leading) {
                    Text(lastGameValue)
                        .font(Font.sfProDisplay(size: 32,
                                                weight: .heavyItalic))
                    Text(LocalizedStringKey(navigationAssistantTitle))
                        .font(Font.notoSans(size: 14, weight: .regular))
                }
                .foregroundStyle(.linearGradient(colors: [.white, .white.opacity(0.6)], startPoint: .leading, endPoint: .trailing))
                .padding(.leading, 60)
                
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .resizable()
                    .foregroundStyle(valueColor)
                    .frame(width: 10, height: 18)
            }
            .padding(.horizontal)
        }
    }
}

#Preview {
    ForEach(ActivityEnum.allCases, id: \.self) { act in
        AnalyticsComponent(workouts: WorkoutData.exampleWorkouts,
                           activityType: act)
    }
    .padding(.horizontal, 16)
    
}
