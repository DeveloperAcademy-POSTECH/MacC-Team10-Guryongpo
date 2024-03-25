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
    
    @State var showingScenes = false
    @AppStorage("healthAlert") var healthAlert = true
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
    @State var maximumData: WorkoutAverageData = WorkoutAverageData(maxHeartRate: 0,
                                                                    minHeartRate: 0,
                                                                    rangeHeartRate: 0,
                                                                    totalDistance: 0.0,
                                                                    maxAcceleration: 0,
                                                                    maxVelocity: 0.0,
                                                                    sprintCount: 0,
                                                                    totalMatchTime: 0)
    
    @StateObject var viewModel = ProfileModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                if healthAlert {
                    HealthAlertView(showingAlert: $healthAlert)
                } else {
                    if showingScenes {
                        MainView(userWorkouts: $userWorkouts,
                                 averageData: $averageData,
                                 maximumData: $maximumData,
                                 viewModel: viewModel)
                    } else {
                        // No soccer data OR,
                        // User does not allow permisson.
                        EmptyDataView(viewModel: viewModel, maximumData: $maximumData)
                    }
                }
            }
            .task {
                healthInteractor.requestAuthorization()
            }
            .onReceive(healthInteractor.authSuccess) {
                Task { await healthInteractor.fetchWorkoutData() }
            }
            .onReceive(healthInteractor.fetchSuccess) {
                self.workoutData = healthInteractor.workoutData
                self.averageData = healthInteractor.userAverage
                self.maximumData = healthInteractor.userMaximum
                self.userWorkouts = workoutData!
                if !(workoutData?.isEmpty ?? true) {
                    showingScenes.toggle()
                }
            }
//            .onAppear {
//                // 음악을 틀기
//                if !soundManager.isMusicPlaying {
//                    soundManager.toggleMusic()
//                }
//            }
        }
        .tint(.white)
    }
}

#Preview {
    ContentView(userWorkouts: [])
        .preferredColorScheme(.dark)
}
