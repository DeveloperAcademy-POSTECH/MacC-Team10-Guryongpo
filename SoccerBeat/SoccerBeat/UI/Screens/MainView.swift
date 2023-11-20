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
                                HStack {
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
                                ProfileView()
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
                                            let average = [3.0, 2.4, 3.4, 3.2, 2.8, 3.3]
                                            let recent = [4.1, 3.0, 3.5, 3.8, 3.5, 2.8]
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
                                MatchRecapView(userWorkouts: $userWorkouts)
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

#Preview {
    @StateObject var healthInteractor = HealthInteractor.shared
    return MainView(userWorkouts: .constant(fakeWorkoutData))
        .environmentObject(healthInteractor)
}
