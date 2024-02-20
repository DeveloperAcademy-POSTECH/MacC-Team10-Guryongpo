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
    @State var updateUserWorkouts: [WorkoutData]?
    @Binding var averageData: WorkoutAverageData
    @Binding var maximumData: WorkoutAverageData
    
    @State var isFlipped: Bool = false
    @ObservedObject var viewModel: ProfileModel
    @State private var currentLocation = "---"
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                HStack {
                    Button {
                        soundManager.toggleMusic()
                    } label: {
                        HStack {
                            Image(systemName: soundManager.isMusicPlaying ? "speaker" : "speaker.slash")
                            Text(soundManager.isMusicPlaying ? "On" : "Off")
                        }
                        .padding(.horizontal)
                        .font(.mainInfoText)
                        .overlay {
                            Capsule()
                                .stroke()
                                .frame(height: 24)
                        }
                    }
                    .foregroundStyle(.white)
                    .padding(.top, 5)
                    Spacer()
                }
                .padding(.horizontal)
                
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading) {
                        Text(userWorkouts[0].yearMonthDay)
                            .font(.mainSubTitleText)
                            .opacity(0.7)
                        Text("최근 경기")
                            .font(.mainTitleText)
                    }
                    Spacer()
                    NavigationLink {
                        ProfileView(averageData: $averageData, maximumData: $maximumData, viewModel: viewModel)
                    } label: {
                        CardFront(width: 72, height: 110, degree: .constant(0), viewModel: viewModel)
                    }
                }
                .padding()
                
                NavigationLink {
                    MatchDetailView(workoutData: userWorkouts[0], averageData: $averageData, maximumData: $maximumData)
                } label: {
                    ZStack {
                        LightRectangleView(alpha: 0.6, color: .black, radius: 15)
                        HStack {
                            VStack {
                                HStack {
                                    // MARK: 프리뷰 보려면 스파이더 맵 포함 하단의 변수들 각주 처리해주세요 -
                                    let averageLevel = DataConverter.dataConverter(totalDistance: averageData.totalDistance,
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
                                    let recentLevel = DataConverter.dataConverter(totalDistance: userWorkouts[0].distance,
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
                                    
                                    // 방구석 리뷰룸 시연을 위해 작성한 코드
                                    let tripleAverage = average.map { min($0 * 3, 5.0) }
                                    let tripleRecent = recent.map { min($0 * 3, 5.0) }
                                    
                                    ViewControllerContainer(RadarViewController(radarAverageValue: tripleAverage, radarAtypicalValue: tripleRecent))
                                        .scaleEffect(CGSize(width: 0.7, height: 0.7))
                                        .fixedSize()
                                        .frame(width: 210, height: 210)
                                    Spacer()
                                    
                                    // 최근 경기 미리보기 오른쪽
                                    VStack(alignment: .trailing) {
                                        
                                        VStack(alignment: .leading) {
                                            Text(currentLocation)
                                                .font(.mainDateLocation)
                                                .foregroundStyle(.mainDateTime)
                                                .opacity(0.8)
                                                .task {
                                                    currentLocation = await userWorkouts[0].location
                                                }
                                            Group {
                                                Text("경기 시간")
                                                Text(userWorkouts[0].time)
                                            }
                                            .font(.mainTime)
                                            .foregroundStyle(.mainMatchTime)
                                        }
                                        
                                        Spacer()
                                        
                                        // 뱃지
                                        HStack {
                                            ForEach(userWorkouts[0].matchBadge.indices, id: \.self) { index in
                                                if let badgeName = ShortenedBadgeImageDictionary[index][userWorkouts[0].matchBadge[index]] {
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
                                    }
                                }
                            }
                            Spacer()
                        }
                        .padding()
                    }
                }
                
                NavigationLink {
                    ScrollView(showsIndicators: false) {
                        MatchRecapView(userWorkouts: $userWorkouts, averageData: $averageData, maximumData: $maximumData)
                    }
                } label: {
                    ZStack {
                        LightRectangleView(alpha: 0.15, color: .seeAllMatch, radius: 22)
                            .frame(height: 38)
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
                
                AnalyticsView()
            }
            .onAppear {
                if !soundManager.isMusicPlaying {
                    soundManager.toggleMusic()
                }
            }
        }
        .refreshable {
            healthInteractor.requestAuthorization()
        }
        .onReceive(healthInteractor.authSuccess, perform: {
            Task {
                print("ContentView: attempting to fetch all data..")
                await healthInteractor.fetchAllData()
            }
        })
        .onReceive(healthInteractor.fetchSuccess, perform: {
            print("ContentView: fetching user data success..")
            self.updateUserWorkouts = healthInteractor.userWorkouts
            self.averageData = healthInteractor.userAverage
            self.maximumData = healthInteractor.userMaximum
            self.userWorkouts = updateUserWorkouts!
        })
        
        .padding(.horizontal)
        .navigationTitle("")
    }
}
