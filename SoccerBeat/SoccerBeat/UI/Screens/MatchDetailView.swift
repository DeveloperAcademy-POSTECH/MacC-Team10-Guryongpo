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
    
    @Binding var averageData: WorkoutAverageData
    @Binding var maximumData: WorkoutAverageData
    
    var body: some View {
        ScrollView {
                VStack {
                    MatchTimeView(workoutData: workoutData)
                    Spacer()
                        .frame(height: 48)
                    PlayerAbilityView(averageData: $averageData, maximumData: $maximumData, workoutData: workoutData)
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

struct MatchTimeView: View {
    let workoutData: WorkoutData
    @State var isInfoOpen: Bool = false
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Spacer()
                .frame(minHeight: 50)
            
            HStack {
                Button {
                    isInfoOpen.toggle()
                } label: {
                    HStack(spacing: 0) {
                        Text(" ")
                        Image("InfoIcon")
                            .resizable()
                            .frame(width: 11, height: 15)
                        Text(" ")
                        if isInfoOpen {
                            Text(" 경기에 대한 ")
                            Text("상세한 리포트")
                                .fontWeight(.bold)
                            Text("를 확인해 볼까요?")
                        }
                    }
                    .floatingCapsuleStyle(color: isInfoOpen ? .floatingCapsuleGray : .white.opacity(0.8))
                }
                Spacer()
            }
            VStack(alignment: .leading, spacing: -8) {
                Text("경기 시간 \(workoutData.time)")
            }
            .font(.matchDetailTitle)
        }
        Spacer()
    }
}

struct PlayerAbilityView: View {
    @Binding var averageData: WorkoutAverageData
    @Binding var maximumData: WorkoutAverageData
    
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
                        
                        let averageLevel = dataConverter(totalDistance: averageData.totalDistance,
                                                         maxHeartRate: averageData.maxHeartRate,
                                                         maxVelocity: averageData.maxVelocity,
                                                         maxAcceleration: averageData.maxAcceleration,
                                                         sprintCount: averageData.sprintCount,
                                                         minHeartRate: averageData.minHeartRate,
                                                         rangeHeartRate: averageData.rangeHeartRate,
                                                         totalMatchTime: averageData.totalMatchTime)
                        let average = [(averageLevel["totalDistance"] ?? 1.0) * 0.15 + (averageLevel["maxHeartRate"] ?? 1.0) * 0.35,
                                       (averageLevel["maxVelocity"] ?? 1.0) * 0.3 + (averageLevel["maxAcceleration"] ?? 1.0) * 0.2,
                                       (averageLevel["maxVelocity"] ?? 1.0) * 0.25 + (averageLevel["sprintCount"] ?? 1.0) * 0.125 + (averageLevel["maxHeartRate"] ?? 1.0) * 0.125,
                                       (averageLevel["maxAcceleration"] ?? 1.0) * 0.4 + (averageLevel["minHeartRate"] ?? 1.0) * 0.1,
                                       (averageLevel["totalDistance"] ?? 1.0) * 0.15 + (averageLevel["rangeHeartRate"] ?? 1.0) * 0.15 + (averageLevel["totalMatchTime"] ?? 1.0) * 0.2,
                                       (averageLevel["totalDistance"] ?? 1.0) * 0.3 + (averageLevel["sprintCount"] ?? 1.0) * 0.1 + (averageLevel["maxHeartRate"] ?? 1.0) * 0.1]
                        
                        let rawTime = workoutData.time
                        let separatedTime = rawTime.components(separatedBy: ":")
                        let separatedMinutes = separatedTime[0].trimmingCharacters(in: .whitespacesAndNewlines)
                        let separatedSeconds = separatedTime[1].trimmingCharacters(in: .whitespacesAndNewlines)
                        let matchLevel = dataConverter(totalDistance: workoutData.distance,
                                                       maxHeartRate: workoutData.maxHeartRate,
                                                       maxVelocity: workoutData.velocity,
                                                       maxAcceleration: workoutData.acceleration,
                                                       sprintCount: workoutData.sprint,
                                                       minHeartRate: workoutData.minHeartRate,
                                                       rangeHeartRate: workoutData.maxHeartRate - workoutData.minHeartRate,
                                                       totalMatchTime: Int(separatedMinutes)! * 60 + Int(separatedSeconds)!)
                        let recent = [(matchLevel["totalDistance"] ?? 1.0) * 0.15 + (matchLevel["maxHeartRate"] ?? 1.0) * 0.35,
                                      (matchLevel["maxVelocity"] ?? 1.0) * 0.3 + (matchLevel["maxAcceleration"] ?? 1.0) * 0.2,
                                      (matchLevel["maxVelocity"] ?? 1.0) * 0.25 + (matchLevel["sprintCount"] ?? 1.0) * 0.125 + (matchLevel["maxHeartRate"] ?? 1.0) * 0.125,
                                      (matchLevel["maxAcceleration"] ?? 1.0) * 0.4 + (matchLevel["minHeartRate"] ?? 1.0) * 0.1,
                                      (matchLevel["totalDistance"] ?? 1.0) * 0.15 + (matchLevel["rangeHeartRate"] ?? 1.0) * 0.15 + (matchLevel["totalMatchTime"] ?? 1.0) * 0.2,
                                      (matchLevel["totalDistance"] ?? 1.0) * 0.3 + (matchLevel["sprintCount"] ?? 1.0) * 0.1 + (matchLevel["maxHeartRate"] ?? 1.0) * 0.1]
                        
                        
                        ViewControllerContainer(RadarViewController(radarAverageValue: average, radarAtypicalValue: recent))
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
                Button {
                    isInfoOpen.toggle()
                } label: {
                    HStack(spacing: 0) {
                        Text(" ")
                        Image("InfoIcon")
                            .resizable()
                            .frame(width: 11, height: 15)
                        Text(" ")
                        if isInfoOpen {
                            Text(" 좋은 경기를 플레이하면 뱃지를 드려요~")
                        }
                    }
                    .floatingCapsuleStyle(color: isInfoOpen ? .floatingCapsuleGray : .white.opacity(0.8))
                }
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
                        Button {
                            isInfoOpen.toggle()
                        } label: {
                            HStack(spacing: 0) {
                                Text(" ")
                                Image("InfoIcon")
                                    .resizable()
                                    .frame(width: 11, height: 15)
                                Text(" ")
                                if isInfoOpen {
                                    Text(" 내가 어디서 많이 뛰었나 볼까요?")
                                }
                            }
                            .floatingCapsuleStyle(color: isInfoOpen ? .floatingCapsuleGray : .white.opacity(0.8))
                        }
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
    return MatchDetailView(workoutData: fakeWorkoutData[0],
                           averageData: .constant(fakeAverageData),
                           maximumData: .constant(fakeAverageData))
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
                            Text(workoutData.maxHeartRate.formatted())
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
