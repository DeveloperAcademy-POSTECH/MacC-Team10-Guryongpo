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
    
    @AppStorage("healthAlert") var healthAlert: Bool = true
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
    
    @State var isFlipped: Bool = false
    @StateObject var viewModel = ProfileModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                if healthAlert {
                    HealthAlertView(showingAlert: $healthAlert)
                } else {
                    if workoutData == nil {
                        // No soccer data OR,
                        // User does not allow permisson.
                        NilDataView(viewModel: viewModel, maximumData: $maximumData)
                    } else {
                        MainView(userWorkouts: $userWorkouts, averageData: $averageData, maximumData: $maximumData, viewModel: viewModel)
                    }
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
                self.maximumData = healthInteractor.userMaximum
                self.userWorkouts = workoutData!
            })
            .onAppear {
                                // UserDefaults return false if no saved value.
                                // musicOff == true, music turned off
                                // musicOff == false, music turend on
                                var musicOff = UserDefaults.standard.bool(forKey: "musicOff")

                                // musicOff, isPlaying have opposite value.
                                musicOff.toggle()
                                soundManager.isPlaying = musicOff
                                if soundManager.isPlaying {
                                    soundManager.playBackground()
                                } else {
                                    soundManager.stopBackground()
                                }
                            }
        }
        .tint(.white)
    }
}

#Preview {
    ContentView(userWorkouts: [])
        .preferredColorScheme(.dark)
}
