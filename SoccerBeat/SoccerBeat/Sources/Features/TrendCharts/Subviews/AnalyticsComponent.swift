//
//  AnalyticsComponent.swift
//  SoccerBeat
//
//  Created by Gucci on 11/20/23.
//

import SwiftUI

struct AnalyticsComponent: View {
    
    let userWorkouts: [WorkoutData]
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
        case .heartrate:
            content = "최근 심박수"
        }
        return content + " 보기"
    }
    private var lastGameValue: String {
        switch activityType {
        case .distance:
            return "\(userWorkouts.last?.distance.rounded(at: 1) ?? "0.0")" + " km"
        case .sprint:
            return "\(userWorkouts.last?.sprint ?? 0)" + " Times"
        case .speed:
            return "\(userWorkouts.last?.velocity.rounded(at: 0) ?? "0")" + " km/h"
        case .heartrate:
            return "\(userWorkouts.last?.maxHeartRate ?? 0)" + " Bpm"
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
                .offset(y: 10)
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
        AnalyticsComponent(userWorkouts: WorkoutData.exampleWorkouts,
                           activityType: act)
    }
    .padding(.horizontal, 16)
    
}
