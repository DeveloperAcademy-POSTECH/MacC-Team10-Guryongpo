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
        VStack(spacing: 20) {
            HStack {
                Text("추세")
                Spacer()
            }
            .padding(.leading)
            .font(.custom("NotoSansDisplay-BlackItalic", size: 36))
            
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
        .padding(.horizontal)
    }
}
