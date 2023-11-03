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
                        
                        MatchRecapView(userWorkouts: $userWorkouts)
                        
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
