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
                    Text("를 확인해볼까요?")
                }
                .floatingCapsuleStyle()
                Spacer()
                    .frame(minHeight: 30)
                Text("세부 리포트")
                    .font(.matchDetailSubTitle)
                    .foregroundStyle(.matchDetailViewSubTitleColor)
                
                VStack(alignment: .leading, spacing: -8) {
                    Text("경기 시간: \(workoutData.time)")
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
                        .frame(minHeight: 30)
                    
                    HStack(spacing: 0) {
                        Text(" 빨간색")
                            .foregroundStyle(.matchDetailViewTitleColor)
                        Text("은 이번 경기의 능력치입니다.")
                    }
                    .floatingCapsuleStyle()
                    
                    HStack(spacing: 0) {
                        Text(" 민트색")
                            .foregroundStyle(.matchDetailViewAverageStatColor)
                        Text("은 경기 평균 능력치입니다.")
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
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    Spacer()
                    VStack(alignment: .leading, spacing: -8) {
                        Text("Field Record")
                    }
                    .font(.matchDetailTitle)
                    .foregroundStyle(.matchDetailTitle)
                }
                Spacer()
            }
            Spacer()
                .frame(minHeight: 30)
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
                .frame(minHeight: 30)
            ZStack {
                LightRectangleView(alpha: 0.4, color: .black, radius: 15)
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
                .frame(minHeight: 60)
            HStack {
                VStack(alignment: .leading) {
                    Text(" 터치하면 자세한 정보를 볼 수 있어요.")
                        .floatingCapsuleStyle()
                    Spacer()
                        .frame(minHeight: 30)
                    VStack(alignment: .leading, spacing: -8) {
                        Text("Field Movement")
                    }
                    .font(.matchDetailTitle)
                    .foregroundStyle(.matchDetailTitle)
                }
                Spacer()
            }
            Spacer()
                .frame(minHeight: 30)
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
