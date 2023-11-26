//
//  AnalyticsView.swift
//  SoccerBeat
//
//  Created by jose Yun on 10/22/23.
//

import SwiftUI

struct AnalyticsView: View {
    @EnvironmentObject var healthInteractor: HealthInteractor
    @State var isInfoOpen: Bool = false
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading) {
                Button {
                    isInfoOpen.toggle()
                } label: {
                    if !isInfoOpen {
                        HStack(spacing: 0) {
                            Text(" ")
                            Image("InfoIcon")
                                .resizable()
                                .frame(width: 11, height: 15)
                            Text(" ")
                        }
                        .floatingCapsuleStyle(color: .white.opacity(0.8))
                    } else {
                        HStack(spacing: 0) {
                            Text(" ")
                            Image("InfoIcon")
                                .resizable()
                                .frame(width: 11, height: 15)
                            Text(" ")
                                Text(" 최근 경기에서 데이터의 변화를 볼 수 있습니다.")
                        }
                        .floatingCapsuleStyle()
                    }
                }
                
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
