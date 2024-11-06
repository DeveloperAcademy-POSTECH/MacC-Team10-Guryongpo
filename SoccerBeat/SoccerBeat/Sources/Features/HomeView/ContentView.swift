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
    @EnvironmentObject var profileModel: ProfileModel
    @EnvironmentObject var healthInteractor: HealthInteractor
    @EnvironmentObject var soundManager: SoundManager
    
    @AppStorage("healthAlert") var healthAlert = true
    @State private var workouts: [WorkoutData] = []
    
    var body: some View {
        NavigationStack {
            if healthAlert {
                HealthAlertView(showingAlert: $healthAlert)
            } else if healthInteractor.isLoading {
                LoadingView()
            } else {
                MainView(isShowingOnboardingView: $isShowingOnboardingView, workouts: $workouts)
            }
        }
        .onReceive(healthInteractor.fetchWorkoutsSuccess) { workouts in
            self.workouts = workouts
            isShowingOnboardingView = workouts.isEmpty
        }
        .onReceive(healthInteractor.onWorkoutRemoved) { indexSet in
            self.workouts.remove(atOffsets: indexSet)
        }
        .onAppear {
            // 음악을 틀기
            if soundManager.isMusicPlaying {
                soundManager.playBackground()
            }
        }
        .tint(.white)
    }
}

#Preview {
    ContentView(isShowingOnboardingView: .constant(true))        .preferredColorScheme(.dark)
        .environmentObject(ProfileModel(healthInteractor: HealthInteractor()))
        .environmentObject(SoundManager())
        .environmentObject(HealthInteractor())
}
