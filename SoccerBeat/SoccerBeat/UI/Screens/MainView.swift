//
//  MainView.swift
//  SoccerBeat
//
//  Created by daaan on 11/16/23.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var healthInteractor: HealthInteractor
    @EnvironmentObject var soundManager: SoundManager
    
    @Binding var userWorkouts: [WorkoutData]
    @Binding var averageData: WorkoutAverageData
    @Binding var maximumData: WorkoutAverageData
    
    @State var isFlipped: Bool = false
    @StateObject var viewModel = ProfileModel()
    @State private var currentLocation = "--'--"
    
    var body: some View {
            ScrollView {
                ZStack {
                    BackgroundImageView()
                    
                    VStack {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading) {
                                HStack(spacing: 0) {
                                    Text("# 가장 최근에 기록한 ")
                                    Text("경기")
                                        .bold()
                                    Text("를 만나보세요.")
                                }
                                .floatingCapsuleStyle()
                                
                                Text("최근 경기")
                                    .font(.custom("NotoSansDisplay-BlackItalic", size: 24))
                                Text("2023/11/23")
                                    .opacity(0.7)
                            }
                            
                            Spacer()
                            
                            NavigationLink {
                                ProfileView(averageData: $averageData, maximumData: $maximumData)
                            } label: {
                                Image(systemName: "person.circle")
                                    .font(.title)
                            }
                        }.padding()
                        
                        NavigationLink {
                            MatchDetailView(workoutData: userWorkouts[0])
                        } label: {
                            ZStack {
                                LightRectangleView(alpha: 0.6, color: .black, radius: 15)
                                HStack {
                                    VStack {
                                        HStack {
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
                                            
                                            let rawTime = userWorkouts[0].time
                                            let separatedTime = rawTime.components(separatedBy: ":")
                                            let separatedMinutes = separatedTime[0].trimmingCharacters(in: .whitespacesAndNewlines)
                                            let separatedSeconds = separatedTime[1].trimmingCharacters(in: .whitespacesAndNewlines)
                                            let recentLevel = dataConverter(totalDistance: userWorkouts[0].distance,
                                                                            maxHeartRate: userWorkouts[0].maxHeartRate,
                                                                            maxVelocity: userWorkouts[0].velocity,
                                                                            maxAcceleration: userWorkouts[0].acceleration,
                                                                            sprintCount: userWorkouts[0].sprint,
                                                                            minHeartRate: userWorkouts[0].minHeartRate,
                                                                            rangeHeartRate: userWorkouts[0].maxHeartRate - userWorkouts[0].minHeartRate,
                                                                            totalMatchTime: Int(separatedMinutes)! * 60 + Int(separatedSeconds)!)
                                            let recent = [(recentLevel["totalDistance"] ?? 1.0) * 0.15 + (recentLevel["maxHeartRate"] ?? 1.0) * 0.35,
                                                           (recentLevel["maxVelocity"] ?? 1.0) * 0.3 + (recentLevel["maxAcceleration"] ?? 1.0) * 0.2,
                                                           (recentLevel["maxVelocity"] ?? 1.0) * 0.25 + (recentLevel["sprintCount"] ?? 1.0) * 0.125 + (recentLevel["maxHeartRate"] ?? 1.0) * 0.125,
                                                           (recentLevel["maxAcceleration"] ?? 1.0) * 0.4 + (recentLevel["minHeartRate"] ?? 1.0) * 0.1,
                                                           (recentLevel["totalDistance"] ?? 1.0) * 0.15 + (recentLevel["rangeHeartRate"] ?? 1.0) * 0.15 + (recentLevel["totalMatchTime"] ?? 1.0) * 0.2,
                                                           (recentLevel["totalDistance"] ?? 1.0) * 0.3 + (recentLevel["sprintCount"] ?? 1.0) * 0.1 + (recentLevel["maxHeartRate"] ?? 1.0) * 0.1]
                                            
                                            
                                            ViewControllerContainer(RadarViewController(radarAverageValue: average, radarAtypicalValue: recent))
                                                .scaleEffect(CGSize(width: 0.7, height: 0.7))
                                                .fixedSize()
                                                .frame(width: 210, height: 210)
                                            Spacer()
                                            VStack(alignment: .trailing) {
                                                Spacer()
                                                HStack {
                                                    ForEach(userWorkouts[0].matchBadge.indices, id: \.self) { index in
                                                        if let badgeName = BadgeImageDictionary[index][userWorkouts[0].matchBadge[index]] {
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
                                                }
                                                HStack {
                                                    Text(userWorkouts[0].date)
                                                    Text(" - ")
                                                    Text(currentLocation)
                                                        .task {
                                                            currentLocation = await userWorkouts[0].location
                                                        }
                                                }
                                                .font(.mainDateLocation)
                                                .foregroundStyle(.mainDateTime)
                                                HStack {
                                                    Text("경기 시간")
                                                    Text(userWorkouts[0].time)
                                                }
                                                .font(.mainTime)
                                            }
                                        }
                                    }
                                    Spacer()
                                }
                                .padding()
                            }
                        }
                        
                        NavigationLink {
                            ScrollView {
                                MatchRecapView(userWorkouts: $userWorkouts, averageData: $averageData)
                            }
                        } label: {
                            ZStack {
                                LightRectangleView(alpha: 0.15, color: .seeAllMatch, radius: 15)
                                HStack {
                                    Spacer()
                                    
                                    Image(systemName: "soccerball")
                                    Text("모든 경기 보기 +")
                                    
                                    Spacer()
                                }
                                .padding()
                            }
                        }
                        
                        Spacer()
                            .frame(height: 80)
                        
                        HStack {
                            Text("# 경기당 기록을 비교합니다.")
                                .floatingCapsuleStyle()
                                .padding(.horizontal)
                            
                            Spacer()
                        }
                        
                        AnalyticsView()
                            .environmentObject(healthInteractor)
                    }
                }
            }
            .navigationTitle("")
    }
}

//#Preview {
//    @StateObject var healthInteractor = HealthInteractor.shared
//    return MainView(userWorkouts: .constant(fakeWorkoutData))
//        .environmentObject(healthInteractor)
//}
