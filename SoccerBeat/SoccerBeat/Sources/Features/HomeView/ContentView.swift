//
//  ContentView.swift
//  SoccerBeat
//
//  Created by daaan on 10/21/23.
//

import SkeletonUI
import SwiftUI
import HealthKit

struct ContentView: View {
    @Binding var isShowingOnboardingView : Bool
    @State var isShowingSessionView: Bool = false
    @EnvironmentObject var profileModel: ProfileModel
    @EnvironmentObject var workoutManager: WorkoutManager
    @EnvironmentObject var soundManager: SoundManager
    
    @AppStorage("healthAlert") var healthAlert = true
    @State private var workouts: [WorkoutData] = []
    
    var body: some View {
        NavigationStack {
            if healthAlert {
                HealthAlertView(showingAlert: $healthAlert)
            } else {
                MainView(isShowingOnboardingView: $isShowingOnboardingView, isShowingSessionView: $isShowingSessionView, workouts: $workouts)
            }
        }
        .onReceive(workoutManager.fetchWorkoutsSuccess) { workouts in
            self.workouts = workouts
        }
        .onReceive(workoutManager.onWorkoutRemoved) { indexSet in
            self.workouts.remove(atOffsets: indexSet)
        }
        .onAppear {
            // 음악을 틀기
            workoutManager.retrieveRemoteSession()
            if soundManager.isMusicPlaying {
                soundManager.playBackground()
            }
            
            if workoutManager.session?.state == .running {
                isShowingSessionView = true
            }
        }
        .tint(.white)
    }
}

#Preview {
    @StateObject var workoutManager = DIContianer.makeWorkoutManager()

    return
    ContentView(isShowingOnboardingView: .constant(true))        .preferredColorScheme(.dark)
        .environmentObject(ProfileModel(workoutManager: workoutManager))
        .environmentObject(SoundManager())
        .environmentObject(workoutManager)
}
