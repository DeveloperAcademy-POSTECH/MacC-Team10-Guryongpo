//
//  MatchRecapView.swift
//  SoccerBeat
//
//  Created by Hyungmin Kim on 2023/10/22.
//

import SwiftUI

struct MatchRecapView: View {
    @State private var userName = ""
    let userWorkouts: [WorkoutData]

    var body: some View {
        VStack(spacing: 0) {
            
            Spacer()
                .frame(height: 56)
            HStack {
                InformationButton(message: "모든 경기를 한 눈에 확인해 보세요.")
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
                ForEach(userWorkouts) { workout in
                    NavigationLink {
                        MatchDetailView(workoutData: workout)
                        .toolbarRole(.editor)
                    } label: {
                        MatchListItemView(workoutData: workout)
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
    @EnvironmentObject var profileModel: ProfileModel
    @State private var currentLocation = "--'--"
    let workoutData: WorkoutData
    
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
            
                let recent = DataConverter.toLevels(workoutData)
                let average = DataConverter.toLevels(profileModel.averageAbility)
                
                ViewControllerContainer(ThumbnailViewController(radarAverageValue: average, radarAtypicalValue: recent))
                    .scaleEffect(CGSize(width: 0.4, height: 0.4))
                    .fixedSize()
                    .frame(width: 88, height: 88)
 
                VStack(alignment: .leading) {
                    Group {
                        Text(workoutData.yearMonthDay.description + " - " + currentLocation)
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

#Preview {
    MatchRecapView(userWorkouts: WorkoutData.exampleWorkouts)
}
