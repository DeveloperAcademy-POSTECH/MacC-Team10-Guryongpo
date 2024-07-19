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
                    ErrorView(workoutData: workoutData)
                    PlayerAbilityView(workoutData: workoutData)
                        .zIndex(-1)
                    Spacer()
                        .frame(height: 100)
                    FieldRecordView(workoutData: workoutData)
                    Spacer()
                        .frame(height: 100)
                    FieldMovementView(workoutData: workoutData)
                        .padding()
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }

struct ErrorView: View {
    let workoutData: WorkoutData
    
    var body: some View {
        if !workoutData.error {
            EmptyView()
        } else {
            VStack {
                Image(.errormark)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 74, height: 80)
                    .padding()
                Text("데이터에 오류가 발생했습니다. ")
                    .font(.averageValue)
                    .foregroundStyle(.white)
                    .padding(2)
                Text("건강 및 위치 권한을 재확인하거나")
                Text("삭제 및 재설치를 권장드립니다.")
            }
            .font(.fieldRecordTitle)
            .foregroundStyle(.mainSubTitleColor)
            .padding(32)
        }
    }
}

struct MatchTimeView: View {
    let workoutData: WorkoutData
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                InformationButton(message: "경기의 상세 리포트를 만나보세요.")
                Spacer()
            }
            .zIndex(1)
            
            VStack(alignment: .leading, spacing: -8) {
                HStack(spacing: 0) {
                    Text("경기 시간")
                    Text(" \(workoutData.time)")
                }
            }
            .font(.matchDetailTitle)
        }
        Spacer()
    }
}

struct PlayerAbilityView: View {
    @EnvironmentObject var profileModel: ProfileModel
    let workoutData: WorkoutData
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    
                    Spacer()
                        .frame(minHeight: 30)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 0) {
                            Text("빨간색")
                                .bold()
                                .foregroundStyle(.matchDetailViewTitleColor)
                            Text("은 이번 경기의 능력치입니다.")
                        }
                        .floatingCapsuleStyle()
                        
                        HStack(spacing: 0) {
                            Text("민트색")
                                .bold()
                                .foregroundStyle(.matchDetailViewAverageStatColor)
                            Text("은 경기의 평균 능력치입니다.")
                        }
                        .floatingCapsuleStyle()
                    }
                    HStack {
                        Spacer()

                        let recent = DataConverter.toLevels(workoutData)
                        let average = DataConverter.toLevels(profileModel.averageAbility)
                        
                        ViewControllerContainer(RadarViewController(radarAverageValue: average, radarAtypicalValue: recent))
                            .scaleEffect(CGSize(width: 0.9, height: 0.9))
                            .padding()
                            .fixedSize()
                            .frame(width: 304, height: 348)
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
                if !workoutData.error {
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
                } else {
                    EmptyView()
                }
            }
            FieldRecordDataView(workoutData: workoutData)
        }
    }
}

struct FieldMovementView: View {
    let workoutData: WorkoutData
    @State var isInfoOpen: Bool = false
    @State private var slider = 0.0
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        InformationButton(message: "설정에서 '정확한 위치'를 허용하면 보다 정확한 데이터를 얻을 수 있어요.")
                        Spacer()
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Field Movement")
                            .font(.matchDetailTitle)
                    }
                }
            }
            
            HeatmapView(slider: $slider, coordinate: CLLocationCoordinate2D(latitude: workoutData.center[0], longitude: workoutData.center[1]), polylineCoordinates: workoutData.route)
                .frame(height: 500)
                .cornerRadius(15.0)
            
            Slider(
                value: $slider,
                in: 0...1
            )
            
        }
        
        Spacer()
            .frame(height: 60)
    }
}

#Preview {
    @StateObject var healthInteractor = HealthInteractor.shared
//    return MatchDetailView(workoutData: WorkoutData.example)
    return ErrorView(workoutData: WorkoutData.example)
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
                        Text("파워")
                            .font(.fieldRecordTitle)
                        HStack(alignment: .bottom,spacing: 0) {
                            Text(workoutData.power.rounded(at: 1))
                                .font(.fieldRecordMeasure)
                            Text(" w")
                                .font(.fieldRecordUnit)
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
