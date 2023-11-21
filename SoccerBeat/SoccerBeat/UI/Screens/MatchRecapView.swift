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
    @State var userName: String = ""
    
    
    var body: some View {
        VStack(spacing: 10) {
            
            Spacer()
                .frame(height: 60)
            
            Text(" 모든 경기와 그날의 스텟을 확인해보세요.")
                .floatingCapsuleStyle()
            
            HStack {
                Text("모든 경기 기록")
                    .font(.custom("NotoSansDisplay-BlackItalic", size: 24))
                Spacer()
            }
            .padding(.top, 30)
            .padding(.horizontal)
            
            HStack {
                VStack(alignment: .leading, spacing: 0.0) {
                    Text("Player, \(userName)")
                    Text("Your past games")
                }
                .foregroundStyle(.white)
                .font(.custom("SFProText-HeavyItalic", size: 36))
                .kerning(-1.5)
                .padding(.leading, 10)
                Spacer()
            }
            
            VStack {
                ForEach(userWorkouts ?? [], id: \.self) { workout in
                    NavigationLink {
                        MatchDetailView(workoutData: workout)
                    } label: {
                        MatchListItemView(workoutData: workout)
                    }
                    .padding(.vertical, 10)
                }
            }
        }
        .padding(.horizontal)
        .onAppear {
            userName = UserDefaults.standard.string(forKey: "userName") ?? ""
        }
    }
}

struct MatchListItemView: View {
    let workoutData: WorkoutData
    @State private var currentLocation = "--'--"
    
    var body: some View {
        ZStack {
            LightRectangleView(alpha: 0.2, color: .white, radius: 15)
            
            VStack {
                HStack(spacing: 0) {
                    ForEach(workoutData.matchBadge.indices, id: \.self) { index in
                        if let badgeName = BadgeImageDictionary[index][workoutData.matchBadge[index]] {
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
                    .offset(CGSize(width: 15.0, height: -20.0))
                    Spacer()
                }
                Spacer()
            }
            
            HStack {
                Spacer ()
                
                let average = [3.0, 2.4, 3.4, 3.2, 2.8, 3.3]
                let recent = [4.1, 3.0, 3.5, 3.8, 3.5, 2.8]
                ViewControllerContainer(ThumbnailViewController(radarAverageValue: average, radarAtypicalValue: recent))
                    .scaleEffect(CGSize(width: 0.4, height: 0.4))
                    .fixedSize()
                    .frame(width: 88, height: 88)
                
                VStack(alignment: .leading) {
                    Text(workoutData.date.description + " - " + currentLocation)
                        .foregroundStyle(Color.white.opacity(0.5))
                        .task {
                            currentLocation = await workoutData.location
                        }
                    Text("경기 시간 " + workoutData.time)
                        .foregroundStyle(Color.white)
                        .padding(.bottom)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text("활동량")
                            Text(String(format: "%.1f", workoutData.distance) + "km")
                        }.foregroundStyle(
                            .linearGradient(colors: [.white, .white.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .font(.custom("SFProText-HeavyItalic", size: 16))
                        
                        VStack(alignment: .leading) {
                            Text("최고 속도")
                            Text("\(workoutData.velocity.formatted()) km/h")
                        }.foregroundStyle(
                            .linearGradient(colors: [.white, .white.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .font(.custom("SFProText-HeavyItalic", size: 16))
                        
                        VStack(alignment: .leading) {
                            Text("스프린트 횟수")
                            Text("\(workoutData.sprint)회")
                        }
                        .foregroundStyle(
                            .linearGradient(colors: [.white, .white.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .font(.custom("SFProText-HeavyItalic", size: 16))
                    }
                }
                Spacer()
            }
            .padding(.vertical, 10)
        }
        .frame(height: 114)
    }
}

#Preview {
    MatchListItemView(workoutData: fakeWorkoutData[0])
        .environmentObject(HealthInteractor.shared)
}
