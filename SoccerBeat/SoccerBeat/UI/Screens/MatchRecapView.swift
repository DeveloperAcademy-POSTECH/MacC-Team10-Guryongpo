//
//  MatchRecapView.swift
//  SoccerBeat
//
//  Created by Hyungmin Kim on 2023/10/22.
//

import SwiftUI

struct MatchRecapView: View {
    
    @EnvironmentObject var healthInteractor: HealthInteractor
    @Binding var userWorkouts: [WorkoutData]
    @Binding var averageData: WorkoutAverageData
    @Binding var maximumData: WorkoutAverageData
    @State var userName: String = ""
    @State var isInfoOpen: Bool = false
    var body: some View {
        VStack(spacing: 0) {
            
            Spacer()
                .frame(height: 56)
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
                            Text(" 모든 경기와 그날의 스탯을 확인해 보세요.")
                        }
                    }
                    .floatingCapsuleStyle(color: isInfoOpen ? .floatingCapsuleGray : .white.opacity(0.8))
                }
                .padding(.leading, 16)
                
                Spacer()
            }
            HStack {
                Text("경기 기록")
                    .font(.mainSubTitleText)
                    .foregroundStyle(.mainSubTitleColor)
                
                Spacer()
            }
            .padding(.top, 14)
            .padding(.leading, 32)
            
            HStack {
                VStack(alignment: .leading, spacing: 0.0) {
                    Text("Player, \(userName)")
                    Text("Your past games")
                }
                .font(.mainTitleText)
                .foregroundStyle(.white)
                .kerning(-1.5)
                Spacer()
            }
            .padding(.leading, 32)
            
            VStack(spacing: 15) {
                ForEach(userWorkouts ?? [], id: \.self) { workout in
                    NavigationLink {
                        MatchDetailView(workoutData: workout,
                                        averageData: $averageData,
                                        maximumData: $maximumData)
                        .toolbarRole(.editor)
                    } label: {
                        MatchListItemView(workoutData: workout, averageData: $averageData)
                    }
                }
            }
            .padding(.top, 61)
            .padding(.horizontal, 16)
        }
        .onAppear {
            userName = UserDefaults.standard.string(forKey: "userName") ?? ""
        }
    }
}

struct MatchListItemView: View {
    let workoutData: WorkoutData
    @State private var currentLocation = "--'--"
    @Binding var averageData: WorkoutAverageData
    
    var body: some View {
        ZStack {
            LightRectangleView(alpha: 0.2, color: .white, radius: 15)
            
            VStack {
                HStack(spacing: 0) {
                    ForEach(workoutData.matchBadge.indices, id: \.self) { index in
                        if let badgeName = ShortenedBadgeImageDictionary[index][workoutData.matchBadge[index]] {
                            if badgeName.isEmpty {
                                EmptyView()
                            } else {
                                Image(badgeName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 32, height: 36)
                            }
                        } else {
                            EmptyView()
                        }
                    }
                    .offset(CGSize(width: 15.0, height: -10.0))
                    Spacer()
                }
                Spacer()
            }
            
            HStack {
                Spacer ()

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
                let recentLevel = dataConverter(totalDistance: workoutData.distance,
                                                maxHeartRate: workoutData.maxHeartRate,
                                                maxVelocity: workoutData.velocity,
                                                maxAcceleration: workoutData.acceleration,
                                                sprintCount: workoutData.sprint,
                                                minHeartRate: workoutData.minHeartRate,
                                                rangeHeartRate: workoutData.maxHeartRate - workoutData.minHeartRate,
                                                totalMatchTime: Int(separatedMinutes)! * 60 + Int(separatedSeconds)!)
                let recent = [(recentLevel["totalDistance"] ?? 1.0) * 0.15 + (recentLevel["maxHeartRate"] ?? 1.0) * 0.35,
                              (recentLevel["maxVelocity"] ?? 1.0) * 0.3 + (recentLevel["maxAcceleration"] ?? 1.0) * 0.2,
                              (recentLevel["maxVelocity"] ?? 1.0) * 0.25 + (recentLevel["sprintCount"] ?? 1.0) * 0.125 + (recentLevel["maxHeartRate"] ?? 1.0) * 0.125,
                              (recentLevel["maxAcceleration"] ?? 1.0) * 0.4 + (recentLevel["minHeartRate"] ?? 1.0) * 0.1,
                              (recentLevel["totalDistance"] ?? 1.0) * 0.15 + (recentLevel["rangeHeartRate"] ?? 1.0) * 0.15 + (recentLevel["totalMatchTime"] ?? 1.0) * 0.2,
                              (recentLevel["totalDistance"] ?? 1.0) * 0.3 + (recentLevel["sprintCount"] ?? 1.0) * 0.1 + (recentLevel["maxHeartRate"] ?? 1.0) * 0.1]
                
                ViewControllerContainer(ThumbnailViewController(radarAverageValue: average, radarAtypicalValue: recent))
                    .scaleEffect(CGSize(width: 0.4, height: 0.4))
                    .fixedSize()
                    .frame(width: 88, height: 88)
 
                VStack(alignment: .leading) {
                    Group {
                        Text(workoutData.date.description + " - " + currentLocation)
                            .task {
                                currentLocation = await workoutData.location
                            }
                        Text("경기 시간 " + workoutData.time)
                        
                    }
                    .opacity(0.6)
                    .font(.matchDateLocationText)
                    
                    Spacer()
                    
                    HStack(spacing: 16) {
                        VStack(alignment: .leading) {
                            Text("뛴 거리")
                            Text(String(format: "%.1f", workoutData.distance) + "km")
                                .bold()
                        }
                        
                        VStack(alignment: .leading) {
                            Text("최고 속도")
                            Text("\(Int(workoutData.velocity).formatted()) km/h")
                                .bold()
                        }
                        
                        VStack(alignment: .leading) {
                            Text("스프린트 횟수")
                            Text("\(workoutData.sprint) 회")
                                .bold()
                        }
                    }
                    .font(.system(size: 14))
                    
                }
                .foregroundStyle(.white)
                .padding()
                
                Spacer()
            }
        }
        .frame(height: 114)
    }
}

//#Preview {
//    @StateObject var healthInteractor = HealthInteractor.shared
//    return MatchRecapView(userWorkouts: .constant(fakeWorkoutData),
//                          averageData: .constant(fakeAverageData),
//                          maximumData: .constant(fakeAverageData))
//    .environmentObject(healthInteractor)
//}
