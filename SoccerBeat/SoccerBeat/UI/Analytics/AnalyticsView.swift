//
//  AnalyticsView.swift
//  SoccerBeat
//
//  Created by jose Yun on 10/22/23.
//

import SwiftUI

struct AnalyticsView: View {
    @EnvironmentObject var healthInteractor: HealthInteractor
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading) {
                HStack(spacing: 0) {
                    Image(systemName: "info.circle")
                        .font(.mainInfoText)
                    Text(" 최근 경기에서 데이터의 변화를 볼 수 있습니다.")
                }
                .floatingCapsuleStyle()
                
                HStack {
                    Text("추세")
                        .font(.mainTitleText)
                    Spacer()
                }
                .padding()
            }
            
            VStack(spacing: 15) {
                HStack {
                    VStack(alignment: .leading) {
                        ForEach(ActivityEnum.allCases, id: \.self) { activityType in
                            NavigationLink {
                                switch activityType {
                                case .distance: DistanceChartView(workouts: healthInteractor.recent9Games)
                                case .heartrate: BPMChartView(workouts: healthInteractor.recent9Games)
                                case .speed: SpeedChartView(workouts: healthInteractor.recent9Games)
                                case .sprint: SprintChartView(workouts: healthInteractor.recent9Games)
                                }
                            } label: {
                                AnalyticsComponent(userWorkouts: healthInteractor.recent4Games, activityType: activityType)
                            }
                        }
                    }
                }
            }
        }
    }
}
