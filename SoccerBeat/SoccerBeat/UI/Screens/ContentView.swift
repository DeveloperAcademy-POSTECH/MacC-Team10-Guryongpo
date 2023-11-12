//
//  ContentView.swift
//  SoccerBeat
//
//  Created by daaan on 10/21/23.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    @ObservedObject var healthInteractor = HealthInteractor.shared
    @State var userWorkouts: [WorkoutData]?
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ZStack {
                    Image("BackgroundPattern")
                        .resizable()
                        .scaledToFit()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 0)
                    
                    VStack {
                        
                        MyCardView()
                        
                        Spacer()
                            .frame(height: 114)
                        
                        // No soccer data OR,
                        // User does not allow permisson.
                        if userWorkouts == nil {
                            HStack {
                                VStack(alignment: .leading, spacing: 0.0) {
                                    Button {
                                        // healthInteractor.requestAuthorization()
                                    } label: {
                                        Text("# 헬스 정보 권한을 거절하신 건 아닌가요?")
                                            .padding(5.0)
                                            .overlay(
                                                Capsule()
                                                    .stroke(lineWidth: 1.0)
                                            )
                                    }
                                    
                                    Group {
                                        Text("워치를 차고")
                                        Text("경기를")
                                        Text("기록해 볼까요?")
                                    }
                                    .foregroundStyle(.linearGradient(colors: [.brightmint, .white], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .font(.custom("SFProText-HeavyItalic", size: 36))
                                }
                                .kerning(-1.5)
                                .padding(.leading, 10.0)
                                Spacer()
                            }
                            .padding(.top, 30)
                            .padding(.horizontal)
                        } else {
                            MatchRecapView(userWorkouts: $userWorkouts)
                        }
                        
                        Spacer()
                            .frame(height: 60)
                        
                        AnalyticsView(userWorkouts: $userWorkouts)
                        
                        Spacer()
                            .frame(height: 60)
                        
                    }
                }
            }
            .navigationTitle("")
        }
        .task {
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
            self.userWorkouts = healthInteractor.userWorkouts
        })
        .tint(.white)
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
