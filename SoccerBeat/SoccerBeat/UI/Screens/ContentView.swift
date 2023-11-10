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
                        
                        if userWorkouts == nil {
                            HStack {
                                VStack(alignment: .leading, spacing: 0.0) {
                                    Text("워치를 차고")
                                    Text("경기를")
                                    Text("기록해 볼까요?")
                                }
                                .foregroundStyle(.linearGradient(colors: [.brightmint, .white], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .font(.custom("SFProText-HeavyItalic", size: 36))
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
