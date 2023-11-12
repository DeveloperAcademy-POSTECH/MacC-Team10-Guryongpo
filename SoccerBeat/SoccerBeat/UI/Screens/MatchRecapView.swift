//
//  MatchRecapView.swift
//  SoccerBeat
//
//  Created by Hyungmin Kim on 2023/10/22.
//

import SwiftUI

struct MatchRecapView: View {
    
    @EnvironmentObject var healthInteractor: HealthInteractor
    @Binding var userWorkouts: [WorkoutData]?
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 0.0) {
                    Text("Hello, Isaac")
                    Text("Your archive")
                }
                .foregroundStyle(
                    .linearGradient(colors: [.hotpink, .white], startPoint: .topLeading, endPoint: .bottomTrailing))
                .font(.custom("SFProText-HeavyItalic", size: 36))
                .kerning(-1.5)
                .padding(.leading, 10)
                Spacer()
            }
            .padding(.top, 30)
            
            Spacer()
                .frame(height: 60)
            
            HStack {
                Text("최근 경기 기록")
                    .font(.custom("NotoSansDisplay-BlackItalic", size: 24))
                Spacer()
//                NavigationLink {
//                    MatchTotalView()
//                } label: {
//                    Text("모든 기록 보기 +")
//                }
//                .foregroundStyle(.white)
//                .font(.custom("NotoSansDisplay-BlackItalic", size: 14))
            }
            .padding(.horizontal)
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
    }
}

struct MatchListItemView: View {
    let workoutData: WorkoutData
    @State private var currentLocation = "--'--"
    
    var body: some View {
        ZStack {
            LightRectangleView()
            HStack {
                Spacer ()
                
                Image("Heatmap01")
                    .resizable()
                    .frame(width: 80, height: 120)
                    .padding(.leading, 5)
                
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
        }.frame(height: 150)
    }
}

#Preview {
    MatchListItemView(workoutData: fakeWorkoutData[0])
        .environmentObject(HealthInteractor.shared)
}
