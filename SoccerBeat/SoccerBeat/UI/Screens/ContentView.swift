//
//  ContentView.swift
//  SoccerBeat
//
//  Created by daaan on 10/21/23.
//

import SwiftUI
import HealthKit

struct ContentView: View {
    @EnvironmentObject var healthInteractor: HealthInteractor
    @EnvironmentObject var soundManager: SoundManager
    
    @State var workoutData: [WorkoutData]?
    @State var userWorkouts: [WorkoutData] = []
    @State var averageData: WorkoutAverageData = WorkoutAverageData(maxHeartRate: 0,
                                                                    minHeartRate: 0,
                                                                    rangeHeartRate: 0,
                                                                    totalDistance: 0.0,
                                                                    maxAcceleration: 0,
                                                                    maxVelocity: 0.0,
                                                                    sprintCount: 0,
                                                                    totalMatchTime: 0)
    
    @State var isFlipped: Bool = false
    @StateObject var viewModel = ProfileModel()
    
    var body: some View {
        ZStack {
            if workoutData == nil {
                // No soccer data OR,
                // User does not allow permisson.
                NilDataView()
            } else {
                MainView(userWorkouts: $userWorkouts, averageData: $averageData)
            }
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
            self.workoutData = healthInteractor.userWorkouts
            self.averageData = healthInteractor.userAverage
            self.userWorkouts = workoutData!
        })
        .tint(.white)
        .onAppear {
            // 시끄러우면 각주 처리해주세요 -호제가-
            soundManager.playBackground()
        }
    }
}

#Preview {
    ContentView(userWorkouts: [])
        .preferredColorScheme(.dark)
}
