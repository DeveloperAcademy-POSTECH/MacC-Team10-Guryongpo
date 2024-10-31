//
//  AnalyticsView.swift
//  SoccerBeat
//
//  Created by jose Yun on 10/22/23.
//

import SwiftUI

struct AnalyticsView: View {
    @EnvironmentObject var healthInteractor: HealthInteractor
    @Binding var workouts: [WorkoutData]
    
    var body: some View {
        VStack(spacing: nil) {
            VStack(alignment: .leading) {
                
                InformationButton(message: "최근 경기 데이터의 변화를 확인해 보세요.")
                
                HStack {
                    Text("추세")
                        .font(.mainTitleText)
                    Spacer()
                }
                .padding()
            }
            
            VStack(alignment: .leading, spacing: 15) {
                ForEach(ActivityEnum.allCases, id: \.self) { activityType in
                    NavigationLink {
                        switch activityType {
                        case .distance: DistanceChartView(workouts: workouts)
                        case .heartrate: BPMChartView(workouts: workouts)
                        case .speed: SpeedChartView(workouts: workouts)
                        case .sprint: SprintChartView(workouts: workouts)
                        }
                    } label: {
                        AnalyticsComponent(workouts: healthInteractor.recent4Games, activityType: activityType)
                    }
                }
            }
        }
    }
}
#Preview {
    AnalyticsView(workouts: .constant(WorkoutData.exampleWorkouts))
        .environmentObject(ProfileModel(healthInteractor: HealthInteractor()))
        .environmentObject(HealthInteractor())
}
