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
        ScrollView(showsIndicators: false) {
            ZStack {
                VStack {
                    MatchTimeView(workoutData: workoutData)
                    Spacer()
                        .frame(height: 48)
                    PlayerAbilityView(workoutData: workoutData)
                        .zIndex(-1)
                    Spacer()
                        .frame(height: 100)
                    FieldRecordView(workoutData: workoutData)
                    Spacer()
                        .frame(height: 100)
                    FieldMovementView(workoutData: workoutData)
                }
                .padding()
            }
            .scrollIndicators(.hidden)
        }
    }
}

struct MatchTimeView: View {
    let workoutData: WorkoutData
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Spacer()
                .frame(minHeight: 50)
            
            HStack {
                InformationButton(message: "경기의 상세 리포트를 만나보세요.")
                Spacer()
            }
            .zIndex(1)
            
            VStack(alignment: .leading, spacing: -8) {
                Text("경기 시간 \(workoutData.time)")
            }
            .font(.matchDetailTitle)
        }
        Spacer()
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
                    
                    VStack(spacing: 6) {
                        HStack(spacing: 0) {
                            Text(" 빨간색")
                                .bold()
                                .foregroundStyle(.matchDetailViewTitleColor)
                            Text("은 이번 경기의 능력치입니다.")
                        }
                        .floatingCapsuleStyle()
                        
                        HStack(spacing: 0) {
                            Text(" 민트색")
                                .bold()
                                .foregroundStyle(.matchDetailViewAverageStatColor)
                            Text("은 경기의 평균 능력치입니다.")
                        }
                        .floatingCapsuleStyle()
                    }
                    HStack {
                        Spacer()
//                        RadarChartView(workout: workoutData)
//                            .fixedSize()
//                            .frame(width: 304, height: 348)
//                            .zIndex(-1)
                        
                        RadarChartView(workout: workoutData,width: 304, height: 348)
                            .fixedSize()
//                            .frame(width: 304, height: 348)
                            .zIndex(-1)
                        
                        Spacer()
                    }
                }
                Spacer()
            }
        }
    }
}

struct FieldRecordView: View {
    let workoutData: WorkoutData
    @State var isInfoOpen: Bool = false
    var body: some View {
        VStack {
            HStack {
                InformationButton(message: "경기의 상세 데이터에 따라 뱃지가 수여됩니다.")
                Spacer()
            }
            HStack {
                VStack(alignment: .leading) {
                    Spacer()
                    VStack(alignment: .leading, spacing: -8) {
                        Text("Field Record")
                    }
                    .font(.matchDetailTitle)
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
            FieldRecordDataView(workoutData: workoutData)
        }
    }
}

struct FieldMovementView: View {
    let workoutData: WorkoutData
    @State var isInfoOpen: Bool = false
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        InformationButton(message: "경기 중 나의 위치를 확인해 보세요.")
                        Spacer()
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Field Movement")
                            .font(.matchDetailTitle)
                    }
                }
            }
            
            HeatmapView(coordinate: CLLocationCoordinate2D(latitude: workoutData.center[0], longitude: workoutData.center[1]), polylineCoordinates: workoutData.route)
                .frame(height: 500)
                .cornerRadius(15.0)
        }
        
        Spacer()
            .frame(height: 60)
    }
}

#Preview {
    @StateObject var healthInteractor = HealthInteractor.shared
    return MatchDetailView(workoutData: WorkoutData.example)
    .environmentObject(healthInteractor)
}

struct FieldRecordDataView: View {
    let workoutData: WorkoutData
    var body: some View {
        ZStack {
            LightRectangleView(alpha: 0.4, color: .black, radius: 15)
            
            HStack(alignment: .center, spacing: 50) {
                
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading) {
                        Text("뛴 거리")
                            .font(.fieldRecordTitle)
                        HStack(alignment: .bottom, spacing: 0) {
                            Text(workoutData.distance.formatted())
                                .font(.fieldRecordMeasure)
                            Text(" km")
                                .font(.fieldRecordUnit)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("스프린트")
                            .font(.fieldRecordTitle)
                        HStack(alignment: .bottom, spacing: 0) {
                            Text(workoutData.sprint.formatted())
                                .font(.fieldRecordMeasure)
                            Text(" Times")
                                .font(.fieldRecordUnit)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("최대 심박수")
                            .font(.fieldRecordTitle)
                        HStack(alignment: .bottom, spacing: 0) {
                            Text(workoutData.maxHeartRate.formatted())
                                .font(.fieldRecordMeasure)
                            Text(" Bpm")
                                .font(.fieldRecordUnit)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading) {
                        Text("최고 속도")
                            .font(.fieldRecordTitle)
                        HStack(alignment: .bottom,spacing: 0) {
                            Text(Int(workoutData.velocity).formatted())
                                .font(.fieldRecordMeasure)
                            Text(" km/h")
                                .font(.fieldRecordUnit)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("가속도")
                            .font(.fieldRecordTitle)
                        HStack(alignment: .bottom,spacing: 0) {
                            Text(workoutData.acceleration.rounded(at: 1))
                                .font(.fieldRecordMeasure)
                            Text(" m/s")
                                .font(.fieldRecordUnit)
                            Text("2")
                                .font(.fieldRecordSquare)
                                .baselineOffset(10.0)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("최소 심박수")
                            .font(.fieldRecordTitle)
                        HStack(alignment: .bottom, spacing: 0) {
                            Text(workoutData.minHeartRate.formatted())
                                .font(.fieldRecordMeasure)
                            Text(" Bpm")
                                .font(.fieldRecordUnit)
                        }
                    }
                }
            }
            .padding(.vertical, 56)
            .padding(.horizontal, 20)
        }
        .kerning(-0.41)
    }
}
