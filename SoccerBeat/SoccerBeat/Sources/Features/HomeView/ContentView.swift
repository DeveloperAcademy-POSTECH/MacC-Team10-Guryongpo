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
    @EnvironmentObject var profileModel: ProfileModel
    @EnvironmentObject var healthInteractor: HealthInteractor
    @EnvironmentObject var soundManager: SoundManager
    
    @State var showingScenes = false
    @AppStorage("healthAlert") var healthAlert = true
    @State private var workouts: [WorkoutData] = []
    
    var body: some View {
        NavigationStack {
            if healthAlert {
                HealthAlertView(showingAlert: $healthAlert)
            } else if healthInteractor.isLoading {
                LoadingView()
            } else {
                MainView(workouts: $workouts)
            }
        }
        .onReceive(healthInteractor.fetchWorkoutsSuccess) { workouts in
            self.workouts = workouts
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
    ContentView()
        .preferredColorScheme(.dark)
        .environmentObject(ProfileModel(healthInteractor: HealthInteractor()))
        .environmentObject(SoundManager())
        .environmentObject(HealthInteractor())
}
