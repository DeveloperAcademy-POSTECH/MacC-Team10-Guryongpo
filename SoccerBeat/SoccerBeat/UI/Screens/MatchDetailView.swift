//
//  MatchDetailView.swift
//  SoccerBeat
//
//  Created by Hyungmin Kim on 2023/10/22.
//

import SwiftUI
import Charts
import CoreLocation

struct MatchDetailView: View {
    let workoutData: WorkoutData
    var body: some View {
        ScrollView {
            ZStack {
                Image("BackgroundPattern")
                    .resizable()
                    .scaledToFit()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 0)
                
                VStack {
                    MatchTimeView(workoutData: workoutData)
                    PlayerAbilityView(workoutData: workoutData)
                    FieldRecordView(workoutData: workoutData)
                    FieldMovementView(workoutData: workoutData)
                }
                .padding()
            }
        }
        .scrollIndicators(.hidden)
    }
}

struct MatchTimeView: View {
    let workoutData: WorkoutData
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                HStack(spacing: 0) {
                    Text("# 경기에 대한 ")
                    Text("상세한 리포트")
                        .fontWeight(.bold)
                    Text("를 만나보세요")
                }
                .floatingCapsuleStyle()
                
                Text("세부 리포트")
                    .font(.matchDetailSubTitle)
                    .foregroundStyle(.matchDetailViewSubTitleColor)
                
                VStack(alignment: .leading, spacing: -8) {
                    Text("경기 시간")
                    Text(workoutData.time)
                }
                .font(.matchDetailTitle)
                .foregroundStyle(.matchDetailViewTitleColor)
            }
            Spacer()
        }
    }
}
struct PlayerAbilityView: View {
    let workoutData: WorkoutData
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: -8) {
                        Text("My")
                        Text("Player Ability")
                    }
                    .font(.matchDetailTitle)
                    .foregroundStyle(.matchDetailTitle)
                    
                    HStack(spacing: 0) {
                        Text("# ")
                        Text("빨간색")
                            .foregroundStyle(.matchDetailViewTitleColor)
                        Text("은 이번 경기의 능력치입니다.")
                    }
                    .floatingCapsuleStyle()
                    
                    HStack(spacing: 0) {
                        Text("# ")
                        Text("민트색")
                            .foregroundStyle(.matchDetailViewAverageStatColor)
                        Text("은 이번 경기의 능력치입니다.")
                    }
                    .floatingCapsuleStyle()
                    
                    // MARK: - @Daaan
                    
                    // MARK: - Locate spider chart here.
                }
                Spacer()
            }
        }
    }
}

struct FieldRecordView: View {
    let workoutData: WorkoutData
    let badgeImages: [[Int: String]] = [[
        -1: "",
         0: "DistanceFirstUnlocked",
         1: "DistanceSecondUnlocked",
         2: "DistanceThirdUnlocked",
         3: "DistanceFourthUnlocked"
    ], [
        -1: "",
         0: "SprintFirstUnlocked",
         1: "SprintSecondUnlocked",
         2: "SprintThirdUnlocked",
         3: "SprintFourthUnlocked"
    ], [
        -1: "",
         0: "VelocityFirstUnlocked",
         1: "VelocitySecondUnlocked",
         2: "VelocityThirdUnlocked",
         3: "VelocityFourthUnlocked"
    ]
    ]
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: -8) {
                        Text("My")
                        Text("Field Record")
                    }
                    .font(.matchDetailTitle)
                    .foregroundStyle(.matchDetailTitle)
                }
                Spacer()
            }
            
            HStack {
                ForEach(workoutData.matchBadge.indices, id: \.self) { index in
                    if let badgeName = BadgeImageDictionary[index][workoutData.matchBadge[index]] {
                        if badgeName.isEmpty {
                            EmptyView()
                        } else {
                            Image(badgeName)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 74, height: 82)
                        }
                    } else {
                        EmptyView()
                    }
                }
            }
            Spacer()
            ZStack {
                LightRectangleView()
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack(alignment: .leading) {
                            Image("HeartbeatSign")
                            Text("뛴 거리")
                                .font(.fieldRecordTitle)
                            HStack(alignment: .bottom,spacing: 0) {
                                Text(workoutData.distance.formatted())
                                    .font(.fieldRecordMeasure)
                                Text(" km")
                                    .font(.fieldRecordUnit)
                            }
                            Spacer()
                            Image("HeartbeatSign")
                            Text("스프린트")
                                .font(.fieldRecordTitle)
                            HStack(alignment: .bottom,spacing: 0) {
                                Text(workoutData.sprint.formatted())
                                    .font(.fieldRecordMeasure)
                                Text(" Times")
                                    .font(.fieldRecordUnit)
                            }
                            Spacer()
                            Image("HeartbeatSign")
                            Text("최대 심박수")
                                .font(.fieldRecordTitle)
                            HStack(alignment: .bottom,spacing: 0) {
                                Text(workoutData.maxHeartRate.formatted())
                                    .font(.fieldRecordMeasure)
                                Text(" bpm")
                                    .font(.fieldRecordUnit)
                            }
                        }
                        Spacer()
                        VStack(alignment: .leading) {
                            Image("HeartbeatSign")
                            Text("최고 속도")
                                .font(.fieldRecordTitle)
                            HStack(alignment: .bottom,spacing: 0) {
                                Text(workoutData.velocity.formatted())
                                    .font(.fieldRecordMeasure)
                                Text(" Km/h")
                                    .font(.fieldRecordUnit)
                            }
                            Spacer()
                            Image("HeartbeatSign")
                            Text("가속도")
                                .font(.fieldRecordTitle)
                            HStack(alignment: .bottom,spacing: 0) {
                                Text(workoutData.acceleration.formatted())
                                    .font(.fieldRecordMeasure)
                                Text(" M/s")
                                    .font(.fieldRecordUnit)
                                Text("2")
                                    .font(.fieldRecordSquare)
                                    .baselineOffset(10.0)
                            }
                            Spacer()
                            Image("HeartbeatSign")
                            Text("최소 심박수")
                                .font(.fieldRecordTitle)
                            Text(workoutData.maxHeartRate.formatted() + " bpm")
                                .font(.fieldRecordMeasure)
                        }
                        Spacer()
                    }
                    Spacer()
                }
            }
            .kerning(-0.41)
        }
    }
}

struct FieldMovementView: View {
    let workoutData: WorkoutData
    var body: some View {
        VStack {
            Spacer()
            HStack {
                VStack(alignment: .leading) {
                    Text("# 터치하면 자세한 정보를 볼 수 있어요.")
                        .floatingCapsuleStyle()
                    
                    VStack(alignment: .leading, spacing: -8) {
                        Text("My")
                        Text("Field Movement")
                    }
                    .font(.matchDetailTitle)
                    .foregroundStyle(.matchDetailTitle)
                }
                Spacer()
            }
            Spacer()
            HeatmapView(coordinate: CLLocationCoordinate2D(latitude: workoutData.center[0], longitude: workoutData.center[1]), polylineCoordinates: workoutData.route)
                .frame(height: 500)
                .cornerRadius(15.0)
                .padding(.horizontal)
        }
        Spacer()
            .frame(height: 120)
    }
}

#Preview {
    MatchDetailView(workoutData: fakeWorkoutData[0])
}
