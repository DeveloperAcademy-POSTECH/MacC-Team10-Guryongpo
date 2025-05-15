//
//  AnalyticsView.swift
//  SoccerBeat
//
//  Created by jose Yun on 10/22/23.
//

import SwiftUI

struct AnalyticsView: View {
    @EnvironmentObject var workoutManager: WorkoutManager
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
                        case .speed: SpeedChartView(workouts: workouts)
                        case .sprint: SprintChartView(workouts: workouts)
                        }
                    } label: {
                        AnalyticsComponent(workouts: workoutManager.recent4Games, activityType: activityType)
                    }
                }
            }
        }
    }
}
#Preview {
    @StateObject var workoutManager = DIContianer.makeWorkoutManager()
    return AnalyticsView(workouts: .constant(WorkoutData.exampleWorkouts))
        .environmentObject(ProfileModel(workoutManager: workoutManager))
        .environmentObject(workoutManager)
}
