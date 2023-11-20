//
//  AnalyticsComponent.swift
//  SoccerBeat
//
//  Created by Gucci on 11/20/23.
//

import SwiftUI

struct AnalyticsComponent: View {

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
                        .frame(height: 64)
                        .padding(.leading, 8)
                    
                    Image(systemName: "figure.run")
                        .resizable()
                        .foregroundStyle(valueColor)
                        .scaleEffect(x: -1, y: 1)
                        .frame(width: 22, height: 22)
                }
                .frame(maxWidth: 86)
                
                VStack(alignment: .leading) {
                    Text(value)
                        .font(Font.sfProDisplay(size: 28,
                                                weight: .heavyItalic))
                    Text(navigationAssistantTitle)
                        .font(Font.notoSans(size: 14, weight: .regular))
                }
                .padding(.leading, 100)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .resizable()
                    .foregroundStyle(valueColor)
                    .frame(width: 10, height: 18)
            }
            .padding(.horizontal, 11)
        }
    }
}

#Preview {
    ForEach(ActivityEnum.allCases, id: \.self) { act in
        AnalyticsComponent(userWorkouts: fakeWorkoutData,
                          activityType: act)
    }
    .padding(.horizontal, 16)
    
}
