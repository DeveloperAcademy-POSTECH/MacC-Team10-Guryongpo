//
//  AnalyticsView.swift
//  SoccerBeat
//
//  Created by jose Yun on 10/22/23.
//

import SwiftUI

enum ActivityEnum {
    case distance
    case sprint
    case speed
    case heartrate
}

struct AnalyticsView: View {
    @EnvironmentObject private var healthInteractor: HealthInteractor
    
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
                        NavigationLink { AnalyticsDetailView(graphType: .distance) } label: {
                            ActivityComponent(activityType: .distance)
                        }
                        NavigationLink { AnalyticsDetailView(graphType: .sprint) } label: {
                            ActivityComponent(activityType: .sprint)
                        }
                        NavigationLink { AnalyticsDetailView(graphType: .speed) } label: {
                            ActivityComponent(activityType: .speed)
                        }
                        NavigationLink { AnalyticsDetailView(graphType: .heartrate) } label: {
                            ActivityComponent(activityType: .heartrate)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
    }
}

struct ActivityComponent: View {
    @EnvironmentObject private var healthInteractor: HealthInteractor

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
            return "\(healthInteractor.userWorkouts.first?.distance) Km"
        case .sprint:
            let sprint = healthInteractor.userWorkouts.first?.sprint
            let time = sprint! < 2 ? " Time" : " Times"
            return "\(sprint)" + time
        case .speed:
            return "\(healthInteractor.userWorkouts.first?.velocity) Km/h"
        case .heartrate:
            return "\(healthInteractor.userWorkouts.first?.heartRate) Bpm"
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

#Preview {
    AnalyticsView()
}
